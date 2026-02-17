#include "desktop_autopaste_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

#include "autopaste_text.h"
#include "focused_text_field_context.h"

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <algorithm>
#include <memory>
#include <sstream>

// Helper to convert UTF-8 std::string to UTF-16 std::wstring.
static std::wstring Utf8ToWide(const std::string &utf8) {
  if (utf8.empty())
    return std::wstring();
  int size_needed =
      MultiByteToWideChar(CP_UTF8, 0, utf8.c_str(), -1, nullptr, 0);
  if (size_needed <= 0)
    return std::wstring();
  std::wstring wstr(size_needed, 0);
  MultiByteToWideChar(CP_UTF8, 0, utf8.c_str(), -1, wstr.data(), size_needed);
  wstr.resize(size_needed - 1); // remove NUL terminator
  return wstr;
}

static int ReadIntArg(
    const flutter::EncodableMap* args,
    const char* key,
    int fallback) {
  if (args == nullptr) {
    return fallback;
  }

  const auto it = args->find(flutter::EncodableValue(key));
  if (it == args->end()) {
    return fallback;
  }

  if (const auto* value = std::get_if<int32_t>(&it->second)) {
    return *value;
  }
  if (const auto* value = std::get_if<int64_t>(&it->second)) {
    return static_cast<int>(*value);
  }
  if (const auto* value = std::get_if<double>(&it->second)) {
    return static_cast<int>(*value);
  }

  return fallback;
}

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
    
    bool ok = AutoPasteTextViaClipboardAuto(wtext);
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
  } else if (method_call.method_name().compare("getFocusedTextFieldContext") == 0) {
    const auto* args =
        std::get_if<flutter::EncodableMap>(method_call.arguments());
    const int max_chars_before =
        std::max(0, ReadIntArg(args, "maxCharsBefore", 120));
    const int max_chars_after =
        std::max(0, ReadIntArg(args, "maxCharsAfter", 120));

    const auto context =
        GetFocusedTextFieldContext(max_chars_before, max_chars_after);
    result->Success(flutter::EncodableValue(context));
  } else {
    result->NotImplemented();
  }
}

}  // namespace desktop_autopaste
