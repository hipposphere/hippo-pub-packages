#include "hotkey_api_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

#include <flutter/event_channel.h>
#include <flutter/event_stream_handler.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <map>
#include <memory>
#include <sstream>

namespace hotkey_api {

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

HotkeyApiPlugin::HotkeyApiPlugin() {}

HotkeyApiPlugin::~HotkeyApiPlugin() {}

void HotkeyApiPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  result->NotImplemented();
}

std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
HotkeyApiPlugin::OnListen(
    const flutter::EncodableValue* arguments,
    std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&& events) {
  event_sink_ = std::move(events);

  keyboard_hook_ = SetWindowsHookEx(WH_KEYBOARD_LL, KeyboardProc,
                                    GetModuleHandle(nullptr), 0);

  return nullptr;
}

std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
HotkeyApiPlugin::OnCancel(const flutter::EncodableValue* arguments) {
  event_sink_ = nullptr;

  if (keyboard_hook_) {
    UnhookWindowsHookEx(keyboard_hook_);
    keyboard_hook_ = nullptr;
  }

  return nullptr;
}

LRESULT CALLBACK HotkeyApiPlugin::KeyboardProc(int nCode, WPARAM wParam,
                                               LPARAM lParam) {
  if (nCode == HC_ACTION) {
    KBDLLHOOKSTRUCT* pkbhs = (KBDLLHOOKSTRUCT*)lParam;
    if (pkbhs) {
      flutter::EncodableMap event;
      event[flutter::EncodableValue("key")] =
          flutter::EncodableValue((int)pkbhs->vkCode);

      if (wParam == WM_KEYDOWN || wParam == WM_SYSKEYDOWN) {
        event[flutter::EncodableValue("type")] =
            flutter::EncodableValue("down");
      } else if (wParam == WM_KEYUP || wParam == WM_SYSKEYUP) {
        event[flutter::EncodableValue("type")] =
            flutter::EncodableValue("up");
      }

      // event_sink_->Success(event);
    }
  }

  return CallNextHookEx(nullptr, nCode, wParam, lParam);
}

}  // namespace hotkey_api

