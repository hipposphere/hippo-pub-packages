#ifndef FLUTTER_PLUGIN_HOTKEY_API_PLUGIN_H_
#define FLUTTER_PLUGIN_HOTKEY_API_PLUGIN_H_

#include <flutter/event_channel.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace hotkey_api {

class HotkeyApiPlugin : public flutter::Plugin,
                      public flutter::StreamHandler<flutter::EncodableValue> {
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
           std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> &&events)
      override;

  std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
  OnCancel(const flutter::EncodableValue *arguments) override;

  static LRESULT CALLBACK KeyboardProc(int nCode, WPARAM wParam, LPARAM lParam);
};

}  // namespace hotkey_api

#endif  // FLUTTER_PLUGIN_HOTKEY_API_PLUGIN_H_
