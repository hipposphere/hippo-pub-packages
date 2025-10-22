#include "desktop_autopaste_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <sstream>

namespace desktop_autopaste {

// static
void DesktopAutopastePlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "desktop_autopaste",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<DesktopAutopastePlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

DesktopAutopastePlugin::DesktopAutopastePlugin() {}

DesktopAutopastePlugin::~DesktopAutopastePlugin() {}

void DesktopAutopastePlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (method_call.method_name().compare("pasteIntoCursor") == 0) {
    const auto *args =
        std::get_if<flutter::EncodableMap>(method_call.arguments());
    if (!args) {
      result->Error("BAD_ARGS", "Missing arguments", nullptr);
      return;
    }
    auto it = args->find(flutter::EncodableValue("text"));
    if (it == args->end() || !std::holds_alternative<std::string>(it->second)) {
      result->Error("BAD_ARGS", "Missing text", nullptr);
      return;
    }
    std::string text = std::get<std::string>(it->second);
    std::wstring wtext = Utf8ToWide(text);
    
    bool ok = AutoPasteText(wtext);
    ok = AutoPasteTextViaClipboard(wtext);
    result->Success(flutter::EncodableValue(ok));
  } else if (method_call.method_name().compare("pasteIntoCursorViaClipboard") == 0) {
   const auto *args =
        std::get_if<flutter::EncodableMap>(method_call.arguments());
    if (!args) {
      result->Error("BAD_ARGS", "Missing arguments", nullptr);
      return;
    }
    auto it = args->find(flutter::EncodableValue("text"));
    if (it == args->end() || !std::holds_alternative<std::string>(it->second)) {
      result->Error("BAD_ARGS", "Missing text", nullptr);
      return;
    }
    std::string text = std::get<std::string>(it->second);
    std::wstring wtext = Utf8ToWide(text);
    
    bool ok = AutoPasteTextViaClipboard(wtext);
    result->Success(flutter::EncodableValue(ok));
  } else {
    result->NotImplemented();
  }
}

}  // namespace desktop_autopaste
