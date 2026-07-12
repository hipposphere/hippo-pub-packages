#include "hotkey_api_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

#include <flutter/event_channel.h>
#include <flutter/event_stream_handler_functions.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <map>
#include <memory>
#include <vector>

namespace hotkey_api {

namespace {

constexpr UINT kDispatchQueuedEventsMessage = WM_APP + 0x4A11;
constexpr wchar_t kMessageWindowClassName[] =
    L"HotkeyApiPluginMessageWindow";

const char* EventTypeName(QueuedHotkeyEventType type) {
  switch (type) {
    case QueuedHotkeyEventType::kDown:
      return "down";
    case QueuedHotkeyEventType::kUp:
      return "up";
    case QueuedHotkeyEventType::kRepeat:
      return "repeat";
  }
  return "repeat";
}

bool IsKeyDownMessage(WPARAM wparam) {
  return wparam == WM_KEYDOWN || wparam == WM_SYSKEYDOWN;
}

bool IsKeyUpMessage(WPARAM wparam) {
  return wparam == WM_KEYUP || wparam == WM_SYSKEYUP;
}

}  // namespace

// Static instance pointer
HotkeyApiPlugin* HotkeyApiPlugin::instance_ = nullptr;

// static
void HotkeyApiPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows* registrar) {
  auto method_channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "hotkey_api/methods",
          &flutter::StandardMethodCodec::GetInstance());

  auto event_channel =
      std::make_unique<flutter::EventChannel<flutter::EncodableValue>>(
          registrar->messenger(), "hotkey_api/events",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<HotkeyApiPlugin>();

  method_channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto& call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  auto handler = std::make_unique<
      flutter::StreamHandlerFunctions<flutter::EncodableValue>>(
      [plugin_pointer =
           plugin.get()](const flutter::EncodableValue* arguments,
                         std::unique_ptr<flutter::EventSink<>>&& events)
          -> std::unique_ptr<flutter::StreamHandlerError<>> {
        return plugin_pointer->OnListen(arguments, std::move(events));
      },
      [plugin_pointer = plugin.get()](const flutter::EncodableValue* arguments)
          -> std::unique_ptr<flutter::StreamHandlerError<>> {
        return plugin_pointer->OnCancel(arguments);
      });

  event_channel->SetStreamHandler(std::move(handler));

  registrar->AddPlugin(std::move(plugin));
}

HotkeyApiPlugin::HotkeyApiPlugin() {
  instance_ = this;
}

HotkeyApiPlugin::~HotkeyApiPlugin() {
  OnCancel(nullptr);
  DestroyMessageWindow();

  if (instance_ == this) {
    instance_ = nullptr;
  }
}

void HotkeyApiPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  result->NotImplemented();
}

std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
HotkeyApiPlugin::OnListen(
    const flutter::EncodableValue* arguments,
    std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&& events) {
  is_listening_.store(false, std::memory_order_release);
  if (keyboard_hook_) {
    UnhookWindowsHookEx(keyboard_hook_);
    keyboard_hook_ = nullptr;
  }

  EnsureMessageWindow();
  if (message_window_ == nullptr) {
    return std::make_unique<flutter::StreamHandlerError<flutter::EncodableValue>>(
        "message_window_unavailable",
        "Failed to create hotkey event dispatch window",
        nullptr);
  }

  {
    std::lock_guard<std::mutex> lock(state_mutex_);
    event_sink_ = std::move(events);
    pressed_keys_.fill(false);
    ClearQueuedEventsLocked();
  }

  is_listening_.store(true, std::memory_order_release);

  keyboard_hook_ = SetWindowsHookEx(WH_KEYBOARD_LL, KeyboardProc,
                                    GetModuleHandle(nullptr), 0);
  if (keyboard_hook_ == nullptr) {
    is_listening_.store(false, std::memory_order_release);
    {
      std::lock_guard<std::mutex> lock(state_mutex_);
      event_sink_ = nullptr;
      pressed_keys_.fill(false);
      ClearQueuedEventsLocked();
    }
    DestroyMessageWindow();
    return std::make_unique<flutter::StreamHandlerError<flutter::EncodableValue>>(
        "keyboard_hook_unavailable",
        "Failed to install Windows low-level keyboard hook",
        nullptr);
  }

  return nullptr;
}

std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
HotkeyApiPlugin::OnCancel(const flutter::EncodableValue* arguments) {
  is_listening_.store(false, std::memory_order_release);

  if (keyboard_hook_) {
    UnhookWindowsHookEx(keyboard_hook_);
    keyboard_hook_ = nullptr;
  }

  {
    std::lock_guard<std::mutex> lock(state_mutex_);
    event_sink_ = nullptr;
    pressed_keys_.fill(false);
    ClearQueuedEventsLocked();
  }

  DestroyMessageWindow();

  return nullptr;
}

LRESULT CALLBACK HotkeyApiPlugin::KeyboardProc(int nCode, WPARAM wParam,
                                               LPARAM lParam) {
  if (nCode == HC_ACTION && instance_ &&
      instance_->is_listening_.load(std::memory_order_acquire)) {
    KBDLLHOOKSTRUCT* pkbhs = (KBDLLHOOKSTRUCT*)lParam;
    if (pkbhs) {
      if (pkbhs->flags & LLKHF_INJECTED) {
        // Ignore the complete injected sequence. Tracking an injected key-up
        // without its ignored key-down corrupts pressed-key state and can
        // release an active physical hotkey prematurely.
        return CallNextHookEx(nullptr, nCode, wParam, lParam);
      }

      if (IsKeyDownMessage(wParam) || IsKeyUpMessage(wParam)) {
        instance_->QueueKeyboardEvent(*pkbhs, wParam);
      }
    }
  }

  return CallNextHookEx(nullptr, nCode, wParam, lParam);
}

LRESULT CALLBACK HotkeyApiPlugin::MessageWindowProc(HWND hwnd,
                                                    UINT message,
                                                    WPARAM wparam,
                                                    LPARAM lparam) {
  if (message == WM_NCCREATE) {
    auto* create_struct = reinterpret_cast<CREATESTRUCTW*>(lparam);
    SetWindowLongPtr(
        hwnd,
        GWLP_USERDATA,
        reinterpret_cast<LONG_PTR>(create_struct->lpCreateParams));
    return TRUE;
  }

  auto* plugin = reinterpret_cast<HotkeyApiPlugin*>(
      GetWindowLongPtr(hwnd, GWLP_USERDATA));
  if (plugin && message == kDispatchQueuedEventsMessage) {
    plugin->DispatchQueuedEvents();
    return 0;
  }

  if (message == WM_NCDESTROY) {
    SetWindowLongPtr(hwnd, GWLP_USERDATA, 0);
  }

  return DefWindowProc(hwnd, message, wparam, lparam);
}

void HotkeyApiPlugin::EnsureMessageWindow() {
  if (message_window_ != nullptr) {
    return;
  }

  WNDCLASSW window_class = {};
  window_class.lpfnWndProc = HotkeyApiPlugin::MessageWindowProc;
  window_class.hInstance = GetModuleHandle(nullptr);
  window_class.lpszClassName = kMessageWindowClassName;

  if (!RegisterClassW(&window_class) &&
      GetLastError() != ERROR_CLASS_ALREADY_EXISTS) {
    return;
  }

  message_window_ = CreateWindowExW(
      0,
      kMessageWindowClassName,
      L"",
      0,
      0,
      0,
      0,
      0,
      HWND_MESSAGE,
      nullptr,
      GetModuleHandle(nullptr),
      this);
}

void HotkeyApiPlugin::DestroyMessageWindow() {
  if (message_window_ == nullptr) {
    return;
  }

  DestroyWindow(message_window_);
  message_window_ = nullptr;
}

void HotkeyApiPlugin::QueueKeyboardEvent(const KBDLLHOOKSTRUCT& event,
                                         WPARAM wparam) {
  const bool is_key_down = IsKeyDownMessage(wparam);
  const bool is_key_up = IsKeyUpMessage(wparam);
  if (!is_key_down && !is_key_up) {
    return;
  }

  bool should_post_dispatch = false;
  {
    std::lock_guard<std::mutex> lock(state_mutex_);
    if (!event_sink_ || !is_listening_.load(std::memory_order_acquire)) {
      return;
    }

    QueuedHotkeyEvent queued_event = {};
    queued_event.vk_code = static_cast<int>(event.vkCode);
    queued_event.flags = event.flags;

    const bool can_track_pressed_state =
        queued_event.vk_code >= 0 &&
        queued_event.vk_code < static_cast<int>(pressed_keys_.size());
    const auto pressed_state_index = can_track_pressed_state
                                         ? static_cast<std::size_t>(
                                               queued_event.vk_code)
                                         : 0;

    if (is_key_down) {
      if (can_track_pressed_state && pressed_keys_[pressed_state_index]) {
        queued_event.type = QueuedHotkeyEventType::kRepeat;
      } else {
        if (can_track_pressed_state) {
          pressed_keys_[pressed_state_index] = true;
        }
        queued_event.type = QueuedHotkeyEventType::kDown;
      }
    } else {
      if (can_track_pressed_state) {
        pressed_keys_[pressed_state_index] = false;
      }
      queued_event.type = QueuedHotkeyEventType::kUp;
    }

    EnqueueEventLocked(queued_event);
    if (!dispatch_scheduled_) {
      dispatch_scheduled_ = true;
      should_post_dispatch = true;
    }
  }

  if (should_post_dispatch &&
      !PostMessage(message_window_, kDispatchQueuedEventsMessage, 0, 0)) {
    std::lock_guard<std::mutex> lock(state_mutex_);
    dispatch_scheduled_ = false;
  }
}

void HotkeyApiPlugin::DispatchQueuedEvents() {
  std::vector<QueuedHotkeyEvent> events;
  {
    std::lock_guard<std::mutex> lock(state_mutex_);
    dispatch_scheduled_ = false;
    if (!event_sink_ || !is_listening_.load(std::memory_order_acquire)) {
      ClearQueuedEventsLocked();
      return;
    }

    events.reserve(queue_size_);
    for (std::size_t i = 0; i < queue_size_; ++i) {
      const std::size_t index = (queue_head_ + i) % kMaxQueuedEvents;
      events.push_back(queued_events_[index]);
    }
    queue_head_ = 0;
    queue_size_ = 0;
  }

  for (const auto& queued_event : events) {
    if (!event_sink_) {
      break;
    }

    flutter::EncodableMap event;
    event[flutter::EncodableValue("key")] =
        flutter::EncodableValue(queued_event.vk_code);
    event[flutter::EncodableValue("type")] =
        flutter::EncodableValue(EventTypeName(queued_event.type));
    event[flutter::EncodableValue("flags")] =
        flutter::EncodableValue(static_cast<int>(queued_event.flags));

    event_sink_->Success(event);
  }
}

void HotkeyApiPlugin::ClearQueuedEventsLocked() {
  queue_head_ = 0;
  queue_size_ = 0;
  dispatch_scheduled_ = false;
}

void HotkeyApiPlugin::EnqueueEventLocked(const QueuedHotkeyEvent& event) {
  if (queue_size_ > 0) {
    const std::size_t last_index =
        (queue_head_ + queue_size_ - 1) % kMaxQueuedEvents;
    QueuedHotkeyEvent& last_event = queued_events_[last_index];
    if (event.type == QueuedHotkeyEventType::kRepeat &&
        last_event.type == QueuedHotkeyEventType::kRepeat &&
        last_event.vk_code == event.vk_code) {
      last_event = event;
      return;
    }
  }

  if (queue_size_ == kMaxQueuedEvents) {
    queue_head_ = (queue_head_ + 1) % kMaxQueuedEvents;
    --queue_size_;
  }

  const std::size_t tail_index =
      (queue_head_ + queue_size_) % kMaxQueuedEvents;
  queued_events_[tail_index] = event;
  ++queue_size_;
}

}  // namespace hotkey_api
