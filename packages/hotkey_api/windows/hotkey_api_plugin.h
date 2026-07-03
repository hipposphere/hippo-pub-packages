#ifndef FLUTTER_PLUGIN_HOTKEY_API_PLUGIN_H_
#define FLUTTER_PLUGIN_HOTKEY_API_PLUGIN_H_

#include <flutter/event_channel.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <array>
#include <atomic>
#include <cstddef>
#include <memory>
#include <mutex>

namespace hotkey_api {

enum class QueuedHotkeyEventType {
  kDown,
  kUp,
  kRepeat,
};

struct QueuedHotkeyEvent {
  int vk_code = 0;
  DWORD flags = 0;
  QueuedHotkeyEventType type = QueuedHotkeyEventType::kDown;
};

class HotkeyApiPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  HotkeyApiPlugin();

  virtual ~HotkeyApiPlugin();

  // Disallow copy and assign.
  HotkeyApiPlugin(const HotkeyApiPlugin&) = delete;
  HotkeyApiPlugin& operator=(const HotkeyApiPlugin&) = delete;

 private:
  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> event_sink_;
  HHOOK keyboard_hook_ = nullptr;

  std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
  OnListen(const flutter::EncodableValue *arguments,
           std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> &&events);

  std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
  OnCancel(const flutter::EncodableValue *arguments);

  static LRESULT CALLBACK KeyboardProc(int nCode, WPARAM wParam, LPARAM lParam);
  static LRESULT CALLBACK MessageWindowProc(HWND hwnd,
                                            UINT message,
                                            WPARAM wparam,
                                            LPARAM lparam);

  void EnsureMessageWindow();
  void DestroyMessageWindow();
  void QueueKeyboardEvent(const KBDLLHOOKSTRUCT &event, WPARAM wparam);
  void DispatchQueuedEvents();
  void ClearQueuedEventsLocked();
  void EnqueueEventLocked(const QueuedHotkeyEvent &event);

  // Static instance pointer for the callback
  static HotkeyApiPlugin* instance_;

  static constexpr std::size_t kMaxQueuedEvents = 256;
  static constexpr std::size_t kPressedKeyStateSize = 256;

  std::array<bool, kPressedKeyStateSize> pressed_keys_ = {};
  std::array<QueuedHotkeyEvent, kMaxQueuedEvents> queued_events_;
  std::size_t queue_head_ = 0;
  std::size_t queue_size_ = 0;
  bool dispatch_scheduled_ = false;

  std::mutex state_mutex_;
  std::atomic_bool is_listening_{false};
  HWND message_window_ = nullptr;
};

}  // namespace hotkey_api

#endif  // FLUTTER_PLUGIN_HOTKEY_API_PLUGIN_H_
