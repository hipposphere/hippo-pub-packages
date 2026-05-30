#include "desktop_autopaste_ffi.h"

#include <X11/Xatom.h>
#include <X11/Xlib.h>
#include <X11/extensions/XTest.h>
#include <X11/keysym.h>

#include <algorithm>
#include <chrono>
#include <cstring>
#include <future>
#include <string>
#include <thread>
#include <utility>
#include <vector>

namespace {

constexpr int32_t kOk = 0;
constexpr int32_t kError = 1;
constexpr int32_t kInvalidArgument = 2;
constexpr int32_t kUnsupported = 3;
constexpr int kPostPasteServeMs = 1200;
constexpr int kSelectionReadTimeoutMs = 350;
constexpr int kClipboardOwnerReadyTimeoutMs = 150;
constexpr int kEventPollIntervalMs = 5;

struct ClipboardAtoms {
  Atom clipboard = None;
  Atom targets = None;
  Atom utf8_string = None;
  Atom text = None;
  Atom text_plain_utf8 = None;
  Atom text_plain = None;
  Atom multiple = None;
  Atom timestamp = None;
  Atom integer = None;
};

enum class PasteShortcut {
  kCtrlV,
  kShiftInsert,
};

class ScopedDisplay {
 public:
  explicit ScopedDisplay(Display* display) : display_(display) {}

  ScopedDisplay(const ScopedDisplay&) = delete;
  ScopedDisplay& operator=(const ScopedDisplay&) = delete;

  ~ScopedDisplay() {
    if (display_ != nullptr) {
      XCloseDisplay(display_);
    }
  }

  Display* get() const { return display_; }

 private:
  Display* display_ = nullptr;
};

void WriteUtf8(char* buffer, uint32_t capacity, const std::string& value) {
  if (buffer == nullptr || capacity == 0) {
    return;
  }

  const size_t copy_length = std::min<size_t>(value.size(), capacity - 1);
  if (copy_length > 0) {
    std::memcpy(buffer, value.data(), copy_length);
  }
  buffer[copy_length] = '\0';
}

ClipboardAtoms InternClipboardAtoms(Display* display) {
  ClipboardAtoms atoms;
  atoms.clipboard = XInternAtom(display, "CLIPBOARD", False);
  atoms.targets = XInternAtom(display, "TARGETS", False);
  atoms.utf8_string = XInternAtom(display, "UTF8_STRING", False);
  atoms.text = XInternAtom(display, "TEXT", False);
  atoms.text_plain_utf8 =
      XInternAtom(display, "text/plain;charset=utf-8", False);
  atoms.text_plain = XInternAtom(display, "text/plain", False);
  atoms.multiple = XInternAtom(display, "MULTIPLE", False);
  atoms.timestamp = XInternAtom(display, "TIMESTAMP", False);
  atoms.integer = XInternAtom(display, "INTEGER", False);
  return atoms;
}

PasteShortcut ParsePasteShortcut(int32_t raw_shortcut) {
  switch (raw_shortcut) {
    case 0:
      return PasteShortcut::kCtrlV;
    case 1:
      return PasteShortcut::kShiftInsert;
    default:
      return PasteShortcut::kShiftInsert;
  }
}

int NormalizeDelayMs(int32_t delay_ms) {
  if (delay_ms <= 0) {
    return 0;
  }
  return delay_ms;
}

bool IsTextTarget(Atom target, const ClipboardAtoms& atoms) {
  return target == atoms.utf8_string || target == XA_STRING ||
         target == atoms.text || target == atoms.text_plain_utf8 ||
         target == atoms.text_plain;
}

std::vector<Atom> SupportedTargets(const ClipboardAtoms& atoms) {
  return {
      atoms.targets,
      atoms.utf8_string,
      atoms.text_plain_utf8,
      atoms.text_plain,
      atoms.text,
      XA_STRING,
      atoms.timestamp,
      atoms.multiple,
  };
}

bool WriteTargetProperty(Display* display,
                         Window requestor,
                         Atom property,
                         Atom target,
                         const ClipboardAtoms& atoms,
                         const std::string& text) {
  if (property == None) {
    return false;
  }

  if (target == atoms.targets) {
    auto targets = SupportedTargets(atoms);
    XChangeProperty(display,
                    requestor,
                    property,
                    XA_ATOM,
                    32,
                    PropModeReplace,
                    reinterpret_cast<const unsigned char*>(targets.data()),
                    static_cast<int>(targets.size()));
    return true;
  }

  if (target == atoms.timestamp) {
    const long timestamp = CurrentTime;
    XChangeProperty(display,
                    requestor,
                    property,
                    atoms.integer,
                    32,
                    PropModeReplace,
                    reinterpret_cast<const unsigned char*>(&timestamp),
                    1);
    return true;
  }

  if (IsTextTarget(target, atoms)) {
    const Atom property_type = target == XA_STRING ? XA_STRING : target;
    XChangeProperty(display,
                    requestor,
                    property,
                    property_type,
                    8,
                    PropModeReplace,
                    reinterpret_cast<const unsigned char*>(text.data()),
                    static_cast<int>(text.size()));
    return true;
  }

  return false;
}

void SendSelectionNotify(Display* display,
                         const XSelectionRequestEvent& request,
                         Atom property) {
  XSelectionEvent event = {};
  event.type = SelectionNotify;
  event.display = request.display;
  event.requestor = request.requestor;
  event.selection = request.selection;
  event.target = request.target;
  event.property = property;
  event.time = request.time;

  XSendEvent(display,
             request.requestor,
             False,
             0,
             reinterpret_cast<XEvent*>(&event));
  XFlush(display);
}

void HandleMultipleTargetRequest(Display* display,
                                 const XSelectionRequestEvent& request,
                                 const ClipboardAtoms& atoms,
                                 const std::string& text) {
  Atom actual_type = None;
  int actual_format = 0;
  unsigned long item_count = 0;
  unsigned long bytes_after = 0;
  unsigned char* raw_data = nullptr;

  const int status = XGetWindowProperty(display,
                                        request.requestor,
                                        request.property,
                                        0,
                                        1024,
                                        False,
                                        XA_ATOM,
                                        &actual_type,
                                        &actual_format,
                                        &item_count,
                                        &bytes_after,
                                        &raw_data);

  if (status != Success || raw_data == nullptr || actual_format != 32 ||
      item_count % 2 != 0) {
    if (raw_data != nullptr) {
      XFree(raw_data);
    }
    SendSelectionNotify(display, request, None);
    return;
  }

  auto* pairs = reinterpret_cast<Atom*>(raw_data);
  for (unsigned long index = 0; index < item_count; index += 2) {
    const Atom target = pairs[index];
    const Atom property = pairs[index + 1];
    if (!WriteTargetProperty(display,
                             request.requestor,
                             property,
                             target,
                             atoms,
                             text)) {
      pairs[index + 1] = None;
    }
  }

  XChangeProperty(display,
                  request.requestor,
                  request.property,
                  XA_ATOM,
                  32,
                  PropModeReplace,
                  raw_data,
                  static_cast<int>(item_count));
  XFree(raw_data);
  SendSelectionNotify(display, request, request.property);
}

void HandleSelectionRequest(Display* display,
                            const XSelectionRequestEvent& request,
                            const ClipboardAtoms& atoms,
                            const std::string& text) {
  if (request.selection != atoms.clipboard) {
    SendSelectionNotify(display, request, None);
    return;
  }

  if (request.target == atoms.multiple) {
    if (request.property == None) {
      SendSelectionNotify(display, request, None);
      return;
    }
    HandleMultipleTargetRequest(display, request, atoms, text);
    return;
  }

  const Atom property =
      request.property == None ? request.target : request.property;
  if (WriteTargetProperty(display,
                          request.requestor,
                          property,
                          request.target,
                          atoms,
                          text)) {
    SendSelectionNotify(display, request, property);
    return;
  }

  SendSelectionNotify(display, request, None);
}

bool WaitForSelectionNotify(Display* display,
                            Window window,
                            Atom property,
                            std::chrono::milliseconds timeout,
                            XSelectionEvent* result) {
  const auto deadline = std::chrono::steady_clock::now() + timeout;
  while (std::chrono::steady_clock::now() < deadline) {
    while (XPending(display) > 0) {
      XEvent event = {};
      XNextEvent(display, &event);
      if (event.type == SelectionNotify &&
          event.xselection.requestor == window &&
          event.xselection.property == property) {
        if (result != nullptr) {
          *result = event.xselection;
        }
        return true;
      }
    }

    std::this_thread::sleep_for(
        std::chrono::milliseconds(kEventPollIntervalMs));
  }
  return false;
}

class X11ClipboardSession {
 public:
  explicit X11ClipboardSession(Display* display)
      : display_(display), atoms_(InternClipboardAtoms(display)) {}

  X11ClipboardSession(const X11ClipboardSession&) = delete;
  X11ClipboardSession& operator=(const X11ClipboardSession&) = delete;

  ~X11ClipboardSession() {
    if (window_ != None) {
      XDestroyWindow(display_, window_);
      XFlush(display_);
    }
  }

  bool Initialize() {
    window_ = XCreateSimpleWindow(display_,
                                  DefaultRootWindow(display_),
                                  0,
                                  0,
                                  1,
                                  1,
                                  0,
                                  0,
                                  0);
    XFlush(display_);
    return window_ != None;
  }

  bool ReadCurrentClipboardText(std::string* text) {
    if (text == nullptr ||
        XGetSelectionOwner(display_, atoms_.clipboard) == None) {
      return false;
    }

    const Atom property =
        XInternAtom(display_, "DESKTOP_AUTOPASTE_CLIPBOARD_READ", False);
    const Atom targets[] = {
        atoms_.utf8_string,
        atoms_.text_plain_utf8,
        atoms_.text_plain,
        atoms_.text,
        XA_STRING,
    };

    for (const Atom target : targets) {
      XDeleteProperty(display_, window_, property);
      XConvertSelection(
          display_, atoms_.clipboard, target, property, window_, CurrentTime);
      XFlush(display_);

      XSelectionEvent selection_event = {};
      if (!WaitForSelectionNotify(
              display_,
              window_,
              property,
              std::chrono::milliseconds(kSelectionReadTimeoutMs),
              &selection_event)) {
        continue;
      }
      if (selection_event.property == None) {
        continue;
      }

      Atom actual_type = None;
      int actual_format = 0;
      unsigned long item_count = 0;
      unsigned long bytes_after = 0;
      unsigned char* raw_data = nullptr;
      const int status = XGetWindowProperty(display_,
                                            window_,
                                            property,
                                            0,
                                            1024 * 1024,
                                            True,
                                            AnyPropertyType,
                                            &actual_type,
                                            &actual_format,
                                            &item_count,
                                            &bytes_after,
                                            &raw_data);

      if (status == Success && raw_data != nullptr && actual_format == 8) {
        text->assign(reinterpret_cast<const char*>(raw_data), item_count);
        XFree(raw_data);
        return true;
      }
      if (raw_data != nullptr) {
        XFree(raw_data);
      }
    }

    return false;
  }

  bool OwnClipboardText(std::string text) {
    text_ = std::move(text);
    XSetSelectionOwner(display_, atoms_.clipboard, window_, CurrentTime);
    XFlush(display_);
    return XGetSelectionOwner(display_, atoms_.clipboard) == window_;
  }

  void ServeRequestsFor(std::chrono::milliseconds duration) {
    const auto deadline = std::chrono::steady_clock::now() + duration;
    while (std::chrono::steady_clock::now() < deadline) {
      if (!ServePendingRequests()) {
        return;
      }
      std::this_thread::sleep_for(
          std::chrono::milliseconds(kEventPollIntervalMs));
    }
  }

  void ServeRequestsUntilSelectionClear() {
    while (true) {
      XEvent event = {};
      XNextEvent(display_, &event);
      if (!HandleEvent(event)) {
        return;
      }
    }
  }

 private:
  bool ServePendingRequests() {
    while (XPending(display_) > 0) {
      XEvent event = {};
      XNextEvent(display_, &event);
      if (!HandleEvent(event)) {
        return false;
      }
    }
    return true;
  }

  bool HandleEvent(const XEvent& event) {
    if (event.type == SelectionClear) {
      return false;
    }
    if (event.type == SelectionRequest) {
      HandleSelectionRequest(display_, event.xselectionrequest, atoms_, text_);
    }
    return true;
  }

  Display* display_ = nullptr;
  ClipboardAtoms atoms_;
  Window window_ = None;
  std::string text_;
};

void RunPersistentClipboardOwner(
    std::string text,
    std::shared_ptr<std::promise<bool>> ready_signal) {
  ScopedDisplay display(XOpenDisplay(nullptr));
  if (display.get() == nullptr) {
    ready_signal->set_value(false);
    return;
  }

  X11ClipboardSession session(display.get());
  if (!session.Initialize() || !session.OwnClipboardText(std::move(text))) {
    ready_signal->set_value(false);
    return;
  }

  ready_signal->set_value(true);
  session.ServeRequestsUntilSelectionClear();
}

void StartPersistentClipboardOwner(std::string text, bool xlib_threading) {
  if (!xlib_threading) {
    return;
  }

  auto ready_signal = std::make_shared<std::promise<bool>>();
  auto ready_future = ready_signal->get_future();
  std::thread(RunPersistentClipboardOwner, std::move(text), ready_signal)
      .detach();
  ready_future.wait_for(
      std::chrono::milliseconds(kClipboardOwnerReadyTimeoutMs));
}

bool SendKey(Display* display, KeySym key_sym, bool down) {
  const KeyCode key_code = XKeysymToKeycode(display, key_sym);
  if (key_code == 0) {
    return false;
  }
  return XTestFakeKeyEvent(display, key_code, down ? True : False, CurrentTime) !=
         0;
}

bool SendPasteShortcut(Display* display, PasteShortcut shortcut) {
  int event_base = 0;
  int error_base = 0;
  int major = 0;
  int minor = 0;
  if (!XTestQueryExtension(display, &event_base, &error_base, &major, &minor)) {
    return false;
  }

  bool ok = false;
  switch (shortcut) {
    case PasteShortcut::kCtrlV:
      ok = SendKey(display, XK_Control_L, true) &&
           SendKey(display, XK_v, true) &&
           SendKey(display, XK_v, false) &&
           SendKey(display, XK_Control_L, false);
      break;
    case PasteShortcut::kShiftInsert:
      ok = SendKey(display, XK_Shift_L, true) &&
           SendKey(display, XK_Insert, true) &&
           SendKey(display, XK_Insert, false) &&
           SendKey(display, XK_Shift_L, false);
      break;
  }

  XFlush(display);
  return ok;
}

int32_t PasteViaX11Clipboard(const std::string& text,
                             int32_t pre_paste_delay_ms,
                             PasteShortcut shortcut,
                             std::string* error_message) {
  if (text.empty()) {
    return kOk;
  }

  const bool xlib_threading = XInitThreads() != 0;

  ScopedDisplay display(XOpenDisplay(nullptr));
  if (display.get() == nullptr) {
    *error_message =
        "Linux auto paste requires an X11 DISPLAY with the XTEST extension";
    return kUnsupported;
  }

  X11ClipboardSession session(display.get());
  if (!session.Initialize()) {
    *error_message = "Failed to initialize X11 clipboard window";
    return kError;
  }

  std::string previous_clipboard_text;
  const bool has_previous_clipboard_text =
      session.ReadCurrentClipboardText(&previous_clipboard_text);

  if (!session.OwnClipboardText(text)) {
    *error_message = "Failed to publish X11 clipboard text";
    return kError;
  }

  const int delay_ms = NormalizeDelayMs(pre_paste_delay_ms);
  if (delay_ms > 0) {
    std::this_thread::sleep_for(std::chrono::milliseconds(delay_ms));
  }

  if (!SendPasteShortcut(display.get(), shortcut)) {
    *error_message =
        "Failed to send paste shortcut through the XTEST extension";
    return kError;
  }

  session.ServeRequestsFor(std::chrono::milliseconds(kPostPasteServeMs));
  StartPersistentClipboardOwner(
      has_previous_clipboard_text ? previous_clipboard_text : text,
      xlib_threading);
  return kOk;
}

int32_t PasteCurrentX11Clipboard(int32_t pre_paste_delay_ms,
                                 PasteShortcut shortcut,
                                 std::string* error_message) {
  ScopedDisplay display(XOpenDisplay(nullptr));
  if (display.get() == nullptr) {
    *error_message =
        "Linux clipboard paste requires an X11 DISPLAY with the XTEST extension";
    return kUnsupported;
  }

  const int delay_ms = NormalizeDelayMs(pre_paste_delay_ms);
  if (delay_ms > 0) {
    std::this_thread::sleep_for(std::chrono::milliseconds(delay_ms));
  }

  if (!SendPasteShortcut(display.get(), shortcut)) {
    *error_message =
        "Failed to send paste shortcut through the XTEST extension";
    return kError;
  }

  return kOk;
}

}  // namespace

extern "C" DESKTOP_AUTOPASTE_FFI_EXPORT int32_t
desktop_autopaste_paste_into_cursor_via_clipboard(
    const char* text_utf8,
    int32_t pre_paste_delay_ms,
    int32_t paste_shortcut,
    char* error_utf8,
    uint32_t error_utf8_capacity) {
  if (text_utf8 == nullptr) {
    WriteUtf8(error_utf8, error_utf8_capacity, "Missing text");
    return kInvalidArgument;
  }

  std::string error_message;
  const int32_t code = PasteViaX11Clipboard(std::string(text_utf8),
                                            pre_paste_delay_ms,
                                            ParsePasteShortcut(paste_shortcut),
                                            &error_message);
  WriteUtf8(error_utf8, error_utf8_capacity, error_message);
  return code;
}

extern "C" DESKTOP_AUTOPASTE_FFI_EXPORT int32_t
desktop_autopaste_paste_from_clipboard(
    int32_t pre_paste_delay_ms,
    int32_t paste_shortcut,
    char* error_utf8,
    uint32_t error_utf8_capacity) {
  std::string error_message;
  const int32_t code = PasteCurrentX11Clipboard(
      pre_paste_delay_ms,
      ParsePasteShortcut(paste_shortcut),
      &error_message);
  WriteUtf8(error_utf8, error_utf8_capacity, error_message);
  return code;
}

extern "C" DESKTOP_AUTOPASTE_FFI_EXPORT int32_t
desktop_autopaste_get_focused_text_field_context_json(
    int32_t max_chars_before,
    int32_t max_chars_after,
    int32_t enable_screen_reader,
    char* context_json_utf8,
    uint32_t context_json_utf8_capacity,
    char* error_utf8,
    uint32_t error_utf8_capacity) {
  (void)max_chars_before;
  (void)max_chars_after;
  (void)enable_screen_reader;

  if (context_json_utf8 == nullptr || context_json_utf8_capacity == 0) {
    WriteUtf8(error_utf8, error_utf8_capacity, "Missing output buffer");
    return kInvalidArgument;
  }

  WriteUtf8(context_json_utf8,
            context_json_utf8_capacity,
            "{\"available\":false,\"reason\":\"unsupportedOnLinux\"}");
  WriteUtf8(error_utf8, error_utf8_capacity, "");
  return kOk;
}

extern "C" DESKTOP_AUTOPASTE_FFI_EXPORT int32_t
desktop_autopaste_edit_focused_text_field(
    const desktop_autopaste_text_edit_operation_t* operations,
    uint32_t operation_count,
    char* error_utf8,
    uint32_t error_utf8_capacity) {
  (void)operations;
  (void)operation_count;
  WriteUtf8(error_utf8, error_utf8_capacity, "unsupportedOnLinux");
  return kUnsupported;
}
