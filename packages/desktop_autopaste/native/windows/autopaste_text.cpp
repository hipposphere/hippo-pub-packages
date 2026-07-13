#include "autopaste_text.h"

#include <ole2.h>
#include <windows.h>
#include <wrl/client.h>

#include <algorithm>
#include <array>
#include <cstring>
#include <cwctype>
#include <future>
#include <limits>
#include <memory>
#include <mutex>
#include <string>
#include <thread>
#include <utility>
#include <vector>

namespace desktop_autopaste {

namespace {

using Microsoft::WRL::ComPtr;

constexpr int kClipboardOpenRetries = 20;
constexpr int kClipboardOpenRetryDelayMs = 10;
constexpr int kClipboardRenderRequestTimeoutMs = 5000;
constexpr int kClipboardConsumerReleaseTimeoutMs = 1000;
constexpr int kPostRenderGraceDelayMs = 250;
constexpr int kPreRenderedPostPasteHoldMs = 1500;
constexpr DWORD kPostPasteInputIdleTimeoutMs = 1000;
constexpr UINT kMessageTimeoutMs = 300;
constexpr wchar_t kDelayedClipboardWindowClassName[] =
    L"HippoDesktopAutopasteDelayedClipboardOwner";
std::mutex g_clipboard_paste_mutex;

class ScopedOleInitialization {
 public:
  ScopedOleInitialization() : result_(::OleInitialize(nullptr)) {}

  ~ScopedOleInitialization() {
    if (result_ == S_OK || result_ == S_FALSE) {
      ::OleUninitialize();
    }
  }

  bool IsUsable() const { return result_ == S_OK || result_ == S_FALSE; }

 private:
  HRESULT result_;
};

struct ClipboardSnapshot {
  ComPtr<IDataObject> data_object;
  bool was_empty = false;
};

struct DelayedClipboardRenderState {
  explicit DelayedClipboardRenderState(std::wstring value)
      : text(std::move(value)) {}

  std::wstring text;
  bool render_requested = false;
  bool render_succeeded = false;
  bool ownership_lost = false;
};

class PasteInjectionReporter {
 public:
  explicit PasteInjectionReporter(
      std::shared_ptr<std::promise<bool>> promise)
      : promise_(std::move(promise)) {}

  ~PasteInjectionReporter() { Report(false); }

  void Report(bool injected) noexcept {
    if (reported_) {
      return;
    }
    reported_ = true;
    try {
      promise_->set_value(injected);
    } catch (...) {
      // The waiting FFI call may already be unwinding during process teardown.
    }
  }

 private:
  std::shared_ptr<std::promise<bool>> promise_;
  bool reported_ = false;
};

constexpr std::array<UINT, 8> kModifierVirtualKeys = {
    VK_LWIN,
    VK_RWIN,
    VK_LCONTROL,
    VK_RCONTROL,
    VK_LMENU,
    VK_RMENU,
    VK_LSHIFT,
    VK_RSHIFT,
};

std::mutex g_paste_shortcut_mutex;

struct ProcessTopLevelWindowSearchContext {
  DWORD process_id = 0;
  HWND best_window = nullptr;
  HWND fallback_window = nullptr;
};

BOOL CALLBACK FindProcessTopLevelWindowCallback(HWND hwnd, LPARAM lparam) {
  auto* context =
      reinterpret_cast<ProcessTopLevelWindowSearchContext*>(lparam);
  if (context == nullptr) {
    return FALSE;
  }

  DWORD window_process_id = 0;
  ::GetWindowThreadProcessId(hwnd, &window_process_id);
  if (window_process_id != context->process_id) {
    return TRUE;
  }

  if (::GetAncestor(hwnd, GA_ROOT) != hwnd) {
    return TRUE;
  }

  if (context->fallback_window == nullptr) {
    context->fallback_window = hwnd;
  }

  if (::GetWindow(hwnd, GW_OWNER) != nullptr || !::IsWindowVisible(hwnd)) {
    return TRUE;
  }

  context->best_window = hwnd;
  return FALSE;
}

HWND GetFocusedWindowHandle() {
  GUITHREADINFO thread_info = {};
  thread_info.cbSize = sizeof(GUITHREADINFO);
  if (::GetGUIThreadInfo(0, &thread_info) && thread_info.hwndFocus != nullptr) {
    return thread_info.hwndFocus;
  }
  return ::GetForegroundWindow();
}

HWND GetClipboardOwnerWindowHandle() {
  ProcessTopLevelWindowSearchContext context = {};
  context.process_id = ::GetCurrentProcessId();
  ::EnumWindows(&FindProcessTopLevelWindowCallback,
                reinterpret_cast<LPARAM>(&context));
  if (context.best_window != nullptr) {
    return context.best_window;
  }
  return context.fallback_window;
}

std::wstring GetWindowClassName(HWND hwnd) {
  if (hwnd == nullptr) {
    return std::wstring();
  }

  wchar_t class_name[256] = {0};
  const int size = ::GetClassNameW(hwnd, class_name, 255);
  if (size <= 0) {
    return std::wstring();
  }
  return std::wstring(class_name, size);
}

bool IsLikelyEditControl(const std::wstring& class_name) {
  if (class_name.empty()) {
    return false;
  }

  std::wstring upper = class_name;
  std::transform(
      upper.begin(),
      upper.end(),
      upper.begin(),
      [](wchar_t c) { return static_cast<wchar_t>(::towupper(c)); });

  return upper.find(L"EDIT") != std::wstring::npos ||
         upper.find(L"RICHEDIT") != std::wstring::npos;
}

bool SendMessageTimeoutLResult(
    HWND hwnd,
    UINT msg,
    WPARAM wparam,
    LPARAM lparam,
    LRESULT* out_result) {
  if (out_result == nullptr || hwnd == nullptr) {
    return false;
  }

  DWORD_PTR result = 0;
  const LRESULT ok = ::SendMessageTimeoutW(
      hwnd,
      msg,
      wparam,
      lparam,
      SMTO_ABORTIFHUNG | SMTO_BLOCK,
      kMessageTimeoutMs,
      &result);
  if (ok == 0) {
    return false;
  }

  *out_result = static_cast<LRESULT>(result);
  return true;
}

bool TryGetEditSelection(HWND hwnd, int* out_start, int* out_end) {
  if (out_start == nullptr || out_end == nullptr || hwnd == nullptr) {
    return false;
  }

  DWORD start = 0;
  DWORD end = 0;
  LRESULT ignored = 0;
  if (!SendMessageTimeoutLResult(
          hwnd,
          EM_GETSEL,
          reinterpret_cast<WPARAM>(&start),
          reinterpret_cast<LPARAM>(&end),
          &ignored)) {
    return false;
  }

  const DWORD kBadPos = static_cast<DWORD>(-1);
  if (start == kBadPos || end == kBadPos) {
    return false;
  }

  start = std::min(start, static_cast<DWORD>(std::numeric_limits<int>::max()));
  end = std::min(end, static_cast<DWORD>(std::numeric_limits<int>::max()));

  *out_start = static_cast<int>(start);
  *out_end = static_cast<int>(end);
  return true;
}

bool TryGetEditTextLength(HWND hwnd, int* out_length) {
  if (out_length == nullptr || hwnd == nullptr) {
    return false;
  }

  LRESULT result = 0;
  if (!SendMessageTimeoutLResult(hwnd, WM_GETTEXTLENGTH, 0, 0, &result)) {
    return false;
  }
  if (result < 0) {
    return false;
  }

  result = std::min<LRESULT>(result, std::numeric_limits<int>::max());
  *out_length = static_cast<int>(result);
  return true;
}

bool TryReplaceSelectionViaEmReplaceSel(HWND hwnd, const std::wstring& text) {
  LRESULT ignored = 0;
  return SendMessageTimeoutLResult(
      hwnd,
      EM_REPLACESEL,
      TRUE,
      reinterpret_cast<LPARAM>(text.c_str()),
      &ignored);
}

bool TryGetFocusedWin32TextFieldHandle(HWND* out_hwnd) {
  if (out_hwnd == nullptr) {
    return false;
  }
  *out_hwnd = nullptr;

  const HWND focused_hwnd = GetFocusedWindowHandle();
  if (focused_hwnd == nullptr) {
    return false;
  }

  const std::wstring class_name = GetWindowClassName(focused_hwnd);
  if (!IsLikelyEditControl(class_name)) {
    return false;
  }

  // Probe an edit-specific message so we only use direct insertion when the
  // focused control behaves like a Win32 Edit/RichEdit field.
  int selection_start = 0;
  int selection_end = 0;
  int text_length = 0;
  if (!TryGetEditSelection(focused_hwnd, &selection_start, &selection_end) &&
      !TryGetEditTextLength(focused_hwnd, &text_length)) {
    return false;
  }

  *out_hwnd = focused_hwnd;
  return true;
}

bool OpenClipboardWithRetries(HWND owner_hwnd) {
  for (int i = 0; i < kClipboardOpenRetries; ++i) {
    if (::OpenClipboard(owner_hwnd)) {
      return true;
    }
    ::Sleep(kClipboardOpenRetryDelayMs);
  }
  return false;
}

bool SetClipboardUnicodeText(const std::wstring& text) {
  HGLOBAL clipboard_text =
      ::GlobalAlloc(GMEM_MOVEABLE, (text.length() + 1) * sizeof(wchar_t));
  if (clipboard_text == nullptr) {
    return false;
  }

  wchar_t* buffer = static_cast<wchar_t*>(::GlobalLock(clipboard_text));
  if (buffer == nullptr) {
    ::GlobalFree(clipboard_text);
    return false;
  }

  std::memcpy(buffer, text.c_str(), text.length() * sizeof(wchar_t));
  buffer[text.length()] = L'\0';
  ::GlobalUnlock(clipboard_text);

  if (::SetClipboardData(CF_UNICODETEXT, clipboard_text) == nullptr) {
    ::GlobalFree(clipboard_text);
    return false;
  }
  return true;
}

DelayedClipboardRenderState* GetDelayedClipboardRenderState(HWND hwnd) {
  return reinterpret_cast<DelayedClipboardRenderState*>(
      ::GetWindowLongPtrW(hwnd, GWLP_USERDATA));
}

LRESULT CALLBACK DelayedClipboardWindowProc(
    HWND hwnd,
    UINT message,
    WPARAM wparam,
    LPARAM lparam) {
  if (message == WM_NCCREATE) {
    const auto* create = reinterpret_cast<const CREATESTRUCTW*>(lparam);
    ::SetWindowLongPtrW(
        hwnd,
        GWLP_USERDATA,
        reinterpret_cast<LONG_PTR>(create->lpCreateParams));
    return TRUE;
  }

  DelayedClipboardRenderState* state =
      GetDelayedClipboardRenderState(hwnd);
  switch (message) {
    case WM_RENDERFORMAT:
      if (state != nullptr && wparam == CF_UNICODETEXT) {
        state->render_requested = true;
        // The requesting process currently has the clipboard open. Windows
        // requires the owner to render without calling OpenClipboard here.
        state->render_succeeded = SetClipboardUnicodeText(state->text);
      }
      return 0;
    case WM_RENDERALLFORMATS:
      if (state != nullptr && ::GetClipboardOwner() == hwnd &&
          ::OpenClipboard(hwnd)) {
        if (::GetClipboardOwner() == hwnd &&
            ::IsClipboardFormatAvailable(CF_UNICODETEXT)) {
          (void)SetClipboardUnicodeText(state->text);
        }
        ::CloseClipboard();
      }
      return 0;
    case WM_DESTROYCLIPBOARD:
      if (state != nullptr) {
        state->ownership_lost = true;
      }
      return 0;
    case WM_NCDESTROY:
      ::SetWindowLongPtrW(hwnd, GWLP_USERDATA, 0);
      break;
  }

  return ::DefWindowProcW(hwnd, message, wparam, lparam);
}

bool EnsureDelayedClipboardWindowClass() {
  static const bool registered = []() {
    WNDCLASSW window_class = {};
    window_class.lpfnWndProc = &DelayedClipboardWindowProc;
    window_class.hInstance = ::GetModuleHandleW(nullptr);
    window_class.lpszClassName = kDelayedClipboardWindowClassName;
    if (::RegisterClassW(&window_class) != 0) {
      return true;
    }
    return ::GetLastError() == ERROR_CLASS_ALREADY_EXISTS;
  }();
  return registered;
}

HWND CreateDelayedClipboardWindow(DelayedClipboardRenderState* state) {
  if (state == nullptr || !EnsureDelayedClipboardWindowClass()) {
    return nullptr;
  }

  return ::CreateWindowExW(
      0,
      kDelayedClipboardWindowClassName,
      L"",
      0,
      0,
      0,
      0,
      0,
      HWND_MESSAGE,
      nullptr,
      ::GetModuleHandleW(nullptr),
      state);
}

bool PublishDelayedClipboardUnicodeText(HWND owner_hwnd) {
  if (owner_hwnd == nullptr || !OpenClipboardWithRetries(owner_hwnd)) {
    return false;
  }

  bool published = false;
  if (::EmptyClipboard()) {
    // A null handle advertises the format without materializing it. Windows
    // will send WM_RENDERFORMAT to owner_hwnd when a consumer requests it.
    ::SetLastError(ERROR_SUCCESS);
    const HANDLE result = ::SetClipboardData(CF_UNICODETEXT, nullptr);
    published = result != nullptr || ::GetLastError() == ERROR_SUCCESS;
  }
  ::CloseClipboard();

  return published && ::GetClipboardOwner() == owner_hwnd &&
         ::IsClipboardFormatAvailable(CF_UNICODETEXT);
}

bool CaptureClipboardSnapshot(
    HWND owner_hwnd,
    ClipboardSnapshot* out_snapshot) {
  if (out_snapshot == nullptr) {
    return false;
  }
  *out_snapshot = ClipboardSnapshot{};

  if (!OpenClipboardWithRetries(owner_hwnd)) {
    return false;
  }

  ::SetLastError(ERROR_SUCCESS);
  const UINT first_format = ::EnumClipboardFormats(0);
  const DWORD enumeration_error = ::GetLastError();
  ::CloseClipboard();

  if (first_format == 0 && enumeration_error == ERROR_SUCCESS) {
    out_snapshot->was_empty = true;
    return true;
  }

  if (first_format == 0) {
    return false;
  }

  return SUCCEEDED(::OleGetClipboard(
      out_snapshot->data_object.ReleaseAndGetAddressOf()));
}

bool RestoreClipboardSnapshot(
    HWND owner_hwnd,
    const ClipboardSnapshot& snapshot) {
  if (snapshot.was_empty) {
    if (!OpenClipboardWithRetries(owner_hwnd)) {
      return false;
    }
    const bool cleared = ::EmptyClipboard() != FALSE;
    ::CloseClipboard();
    return cleared;
  }

  if (!snapshot.data_object) {
    return false;
  }

  const HRESULT restore_result = ::OleSetClipboard(snapshot.data_object.Get());
  if (FAILED(restore_result)) {
    return false;
  }

  // Materialize delayed formats so the restored clipboard does not depend on
  // this process remaining alive after the paste operation completes.
  (void)::OleFlushClipboard();
  return true;
}

void PumpMessagesFor(int duration_ms);

bool RestoreClipboardSnapshotIfStillOwned(
    HWND delayed_owner_hwnd,
    HWND restore_owner_hwnd,
    const ClipboardSnapshot& snapshot) {
  if (delayed_owner_hwnd == nullptr) {
    return false;
  }

  for (int i = 0; i < kClipboardOpenRetries; ++i) {
    if (::GetClipboardOwner() != delayed_owner_hwnd) {
      // Another process published newer clipboard data. Preserving it is a
      // successful finalization even though the original snapshot is skipped.
      return true;
    }

    // This check and the OLE restore cannot be made atomic, but repeating the
    // ownership test minimizes the race and prevents known newer data from
    // being overwritten.
    if (::GetClipboardOwner() == delayed_owner_hwnd &&
        RestoreClipboardSnapshot(restore_owner_hwnd, snapshot)) {
      return true;
    }
    PumpMessagesFor(kClipboardOpenRetryDelayMs);
  }
  return ::GetClipboardOwner() != delayed_owner_hwnd;
}

INPUT MakeScanCodeInput(UINT virtual_key, bool key_up) {
  INPUT input = {};
  input.type = INPUT_KEYBOARD;
  input.ki.wVk = 0;
  input.ki.wScan = static_cast<WORD>(::MapVirtualKeyExW(
      virtual_key,
      MAPVK_VK_TO_VSC_EX,
      ::GetKeyboardLayout(0)));
  input.ki.dwFlags = KEYEVENTF_SCANCODE;
  if ((input.ki.wScan & 0xFF00) != 0) {
    input.ki.dwFlags |= KEYEVENTF_EXTENDEDKEY;
  }
  input.ki.wScan = static_cast<WORD>(input.ki.wScan & 0xFF);
  if (key_up) {
    input.ki.dwFlags |= KEYEVENTF_KEYUP;
  }
  return input;
}

void ReleaseShortcutKeysAfterFailedInjection() {
  std::vector<INPUT> cleanup_inputs;
  cleanup_inputs.reserve(kModifierVirtualKeys.size() + 2);
  cleanup_inputs.push_back(MakeScanCodeInput('V', true));
  cleanup_inputs.push_back(MakeScanCodeInput(VK_INSERT, true));
  for (const UINT modifier : kModifierVirtualKeys) {
    cleanup_inputs.push_back(MakeScanCodeInput(modifier, true));
  }

  ::SendInput(
      static_cast<UINT>(cleanup_inputs.size()),
      cleanup_inputs.data(),
      sizeof(INPUT));
}

bool SendPasteShortcut(ClipboardPasteShortcut shortcut) {
  std::lock_guard<std::mutex> lock(g_paste_shortcut_mutex);

  std::vector<INPUT> inputs;
  inputs.reserve(kModifierVirtualKeys.size() + 4);

  // SendInput does not reset existing keyboard state. In particular, an
  // Office/Copilot key or a programmable HID can leave Ctrl+Alt+Shift+Win
  // logically pressed and turn normal letters into application-launch
  // shortcuts. Neutralize only modifiers that Windows currently reports as
  // down before sending the paste chord.
  for (const UINT modifier : kModifierVirtualKeys) {
    if ((::GetAsyncKeyState(static_cast<int>(modifier)) & 0x8000) != 0) {
      inputs.push_back(MakeScanCodeInput(modifier, true));
    }
  }

  switch (shortcut) {
    case ClipboardPasteShortcut::kCtrlV:
      inputs.push_back(MakeScanCodeInput(VK_LCONTROL, false));
      inputs.push_back(MakeScanCodeInput('V', false));
      inputs.push_back(MakeScanCodeInput('V', true));
      inputs.push_back(MakeScanCodeInput(VK_LCONTROL, true));
      break;
    case ClipboardPasteShortcut::kShiftInsert:
      inputs.push_back(MakeScanCodeInput(VK_LSHIFT, false));
      inputs.push_back(MakeScanCodeInput(VK_INSERT, false));
      inputs.push_back(MakeScanCodeInput(VK_INSERT, true));
      inputs.push_back(MakeScanCodeInput(VK_LSHIFT, true));
      break;
  }

  const UINT expected_sent = static_cast<UINT>(inputs.size());
  const UINT sent = ::SendInput(expected_sent, inputs.data(), sizeof(INPUT));
  if (sent == expected_sent) {
    return true;
  }

  // A partial SendInput result can otherwise leave the shortcut key or one of
  // its modifiers down indefinitely. Best-effort key-up events are safe even
  // when the original events were not inserted.
  ReleaseShortcutKeysAfterFailedInjection();
  return false;
}

void PumpPendingMessages() {
  MSG msg;
  while (::PeekMessage(&msg, nullptr, 0, 0, PM_REMOVE)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }
}

void PumpMessagesFor(int duration_ms) {
  if (duration_ms <= 0) {
    PumpPendingMessages();
    return;
  }

  const ULONGLONG deadline =
      ::GetTickCount64() + static_cast<ULONGLONG>(duration_ms);
  while (::GetTickCount64() < deadline) {
    PumpPendingMessages();
    const ULONGLONG now = ::GetTickCount64();
    if (now >= deadline) {
      break;
    }
    const ULONGLONG remaining = deadline - now;
    const DWORD wait_ms = static_cast<DWORD>(
        std::min<ULONGLONG>(remaining, 50));
    (void)::MsgWaitForMultipleObjectsEx(
        0,
        nullptr,
        wait_ms,
        QS_ALLINPUT,
        MWMO_INPUTAVAILABLE);
  }
  PumpPendingMessages();
}

bool WaitForDelayedClipboardRender(
    HWND owner_hwnd,
    DelayedClipboardRenderState* state,
    int timeout_ms) {
  if (state == nullptr) {
    return false;
  }

  const ULONGLONG deadline =
      ::GetTickCount64() + static_cast<ULONGLONG>(std::max(0, timeout_ms));
  while (!state->render_requested && !state->ownership_lost &&
         ::GetClipboardOwner() == owner_hwnd &&
         ::GetTickCount64() < deadline) {
    PumpMessagesFor(25);
  }
  PumpPendingMessages();
  return state->render_requested && state->render_succeeded &&
         !state->ownership_lost && ::GetClipboardOwner() == owner_hwnd;
}

void WaitForClipboardConsumerRelease(HWND owner_hwnd, int timeout_ms) {
  const ULONGLONG deadline =
      ::GetTickCount64() + static_cast<ULONGLONG>(std::max(0, timeout_ms));
  while (::GetClipboardOwner() == owner_hwnd &&
         ::GetTickCount64() < deadline) {
    if (::OpenClipboard(owner_hwnd)) {
      ::CloseClipboard();
      return;
    }
    PumpMessagesFor(kClipboardOpenRetryDelayMs);
  }
}

void WaitForWindowProcessInputIdle(HWND hwnd) {
  if (hwnd == nullptr) {
    return;
  }

  DWORD process_id = 0;
  const HWND root_hwnd = ::GetAncestor(hwnd, GA_ROOT);
  ::GetWindowThreadProcessId(
      root_hwnd == nullptr ? hwnd : root_hwnd,
      &process_id);
  if (process_id == 0 || process_id == ::GetCurrentProcessId()) {
    return;
  }

  HANDLE process = ::OpenProcess(SYNCHRONIZE, FALSE, process_id);
  if (process == nullptr) {
    return;
  }

  ::WaitForInputIdle(process, kPostPasteInputIdleTimeoutMs);
  ::CloseHandle(process);
}

int NormalizePrePasteDelayMs(int pre_paste_delay_ms) {
  if (pre_paste_delay_ms < 0) {
    return 0;
  }
  return pre_paste_delay_ms;
}

}  // namespace

bool AutoPasteTextViaWin32Messages(const std::wstring& text) {
  if (text.empty()) {
    return true;
  }

  HWND focused_hwnd = nullptr;
  if (!TryGetFocusedWin32TextFieldHandle(&focused_hwnd)) {
    return false;
  }

  int selection_start = 0;
  int selection_end = 0;
  const bool has_selection_before =
      TryGetEditSelection(focused_hwnd, &selection_start, &selection_end);

  int text_length_before = 0;
  const bool has_length_before =
      TryGetEditTextLength(focused_hwnd, &text_length_before);

  if (!TryReplaceSelectionViaEmReplaceSel(focused_hwnd, text)) {
    return false;
  }

  // If we cannot read state, we still consider a successful message dispatch
  // as a likely success for Edit/RichEdit controls.
  int selection_start_after = 0;
  int selection_end_after = 0;
  const bool has_selection_after = TryGetEditSelection(
      focused_hwnd, &selection_start_after, &selection_end_after);

  int text_length_after = 0;
  const bool has_length_after =
      TryGetEditTextLength(focused_hwnd, &text_length_after);

  if (has_length_before && has_length_after && has_selection_before) {
    const int removed_length = std::max(0, selection_end - selection_start);
    const int expected_length =
        text_length_before - removed_length + static_cast<int>(text.length());
    if (text_length_after == expected_length) {
      return true;
    }
  }

  if (has_selection_before && has_selection_after) {
    const int expected_caret =
        selection_start + static_cast<int>(text.length());
    if (selection_start_after == selection_end_after &&
        selection_start_after == expected_caret) {
      return true;
    }
  }

  return has_selection_before || has_length_before;
}

bool AutoPasteTextViaClipboard(const std::wstring& text,
                               ClipboardPasteShortcut shortcut,
                               int pre_paste_delay_ms) {
  return AutoPasteTextViaClipboardWithShortcut(text,
                                               shortcut,
                                               pre_paste_delay_ms);
}

bool PasteFromClipboard(ClipboardPasteShortcut shortcut,
                        int pre_paste_delay_ms) {
  std::lock_guard<std::mutex> paste_lock(g_clipboard_paste_mutex);

  const int effective_pre_paste_delay_ms =
      NormalizePrePasteDelayMs(pre_paste_delay_ms);
  if (effective_pre_paste_delay_ms > 0) {
    ::Sleep(effective_pre_paste_delay_ms);
  }

  const HWND target_hwnd = GetFocusedWindowHandle();
  if (!SendPasteShortcut(shortcut)) {
    return false;
  }

  WaitForWindowProcessInputIdle(target_hwnd);
  PumpPendingMessages();
  return true;
}

void RunAutoPasteTextViaClipboardTransaction(
    const std::wstring& text,
    ClipboardPasteShortcut shortcut,
    int pre_paste_delay_ms,
    PasteInjectionReporter* injection_reporter) {
  if (injection_reporter == nullptr) {
    return;
  }

  // The Windows clipboard is process-global. Serialize transactions across
  // Dart isolates so each call snapshots external clipboard state rather than
  // another in-flight paste's temporary text.
  std::lock_guard<std::mutex> paste_lock(g_clipboard_paste_mutex);

  ScopedOleInitialization ole;
  if (!ole.IsUsable()) {
    injection_reporter->Report(false);
    return;
  }

  const HWND clipboard_owner_hwnd = GetClipboardOwnerWindowHandle();
  ClipboardSnapshot previous_clipboard;
  if (!CaptureClipboardSnapshot(clipboard_owner_hwnd, &previous_clipboard)) {
    injection_reporter->Report(false);
    return;
  }

  DelayedClipboardRenderState render_state(text);
  const HWND delayed_owner_hwnd =
      CreateDelayedClipboardWindow(&render_state);
  if (delayed_owner_hwnd == nullptr) {
    injection_reporter->Report(false);
    return;
  }

  if (!PublishDelayedClipboardUnicodeText(delayed_owner_hwnd)) {
    RestoreClipboardSnapshotIfStillOwned(
        delayed_owner_hwnd,
        clipboard_owner_hwnd,
        previous_clipboard);
    ::DestroyWindow(delayed_owner_hwnd);
    injection_reporter->Report(false);
    return;
  }

  const int effective_pre_paste_delay_ms =
      NormalizePrePasteDelayMs(pre_paste_delay_ms);
  if (effective_pre_paste_delay_ms > 0) {
    // The owner must continue processing WM_RENDERFORMAT while waiting. A
    // plain Sleep would block Citrix or another consumer that requests data.
    PumpMessagesFor(effective_pre_paste_delay_ms);
  }

  if (render_state.ownership_lost ||
      ::GetClipboardOwner() != delayed_owner_hwnd) {
    ::DestroyWindow(delayed_owner_hwnd);
    injection_reporter->Report(false);
    return;
  }

  if (!SendPasteShortcut(shortcut)) {
    RestoreClipboardSnapshotIfStillOwned(
        delayed_owner_hwnd,
        clipboard_owner_hwnd,
        previous_clipboard);
    ::DestroyWindow(delayed_owner_hwnd);
    injection_reporter->Report(false);
    return;
  }

  // Let the Dart hotkey callback return immediately. Some global hotkey and
  // remote-session stacks do not dispatch the synthetic paste chord until the
  // originating callback unwinds. Clipboard ownership and message pumping stay
  // alive on this transaction thread until consumption/restoration completes.
  injection_reporter->Report(true);

  // Wait until a consumer actually asks Windows to materialize the text. This
  // is the point at which Citrix's clipboard virtual channel fetches the
  // payload for the remote paste. If it already requested during pre-delay,
  // keep the payload available for a grace period after shortcut injection.
  const bool rendered_before_shortcut = render_state.render_requested;
  const bool consumed = rendered_before_shortcut
      ? render_state.render_succeeded
      : WaitForDelayedClipboardRender(
            delayed_owner_hwnd,
            &render_state,
            kClipboardRenderRequestTimeoutMs);

  if (consumed) {
    // WM_RENDERFORMAT completes before the requester necessarily finishes
    // copying from the clipboard. Wait for it to close the clipboard, then
    // leave a small grace interval for remote-channel processing.
    WaitForClipboardConsumerRelease(
        delayed_owner_hwnd,
        kClipboardConsumerReleaseTimeoutMs);
    PumpMessagesFor(
        rendered_before_shortcut
            ? kPreRenderedPostPasteHoldMs
            : kPostRenderGraceDelayMs);
  }

  (void)RestoreClipboardSnapshotIfStillOwned(
      delayed_owner_hwnd,
      clipboard_owner_hwnd,
      previous_clipboard);
  ::DestroyWindow(delayed_owner_hwnd);
}

bool AutoPasteTextViaClipboardWithShortcut(const std::wstring& text,
                                           ClipboardPasteShortcut shortcut,
                                           int pre_paste_delay_ms) {
  if (text.empty()) {
    return true;
  }

  try {
    auto promise = std::make_shared<std::promise<bool>>();
    std::future<bool> injection_result = promise->get_future();
    std::thread(
        [text, shortcut, pre_paste_delay_ms, promise = std::move(promise)]() {
          PasteInjectionReporter reporter(std::move(promise));
          try {
            RunAutoPasteTextViaClipboardTransaction(
                text,
                shortcut,
                pre_paste_delay_ms,
                &reporter);
          } catch (...) {
            reporter.Report(false);
          }
        })
        .detach();
    return injection_result.get();
  } catch (...) {
    return false;
  }
}

}  // namespace desktop_autopaste
