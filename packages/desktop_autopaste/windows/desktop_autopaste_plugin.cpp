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
#include <optional>
#include <sstream>
#include <variant>
#include <vector>

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

static std::optional<int> TryReadIntArg(
    const flutter::EncodableMap* args,
    const char* key) {
  if (args == nullptr) {
    return std::nullopt;
  }

  const auto it = args->find(flutter::EncodableValue(key));
  if (it == args->end()) {
    return std::nullopt;
  }

  if (std::holds_alternative<std::monostate>(it->second)) {
    return std::nullopt;
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

  return std::nullopt;
}

static bool ReadBoolArg(
    const flutter::EncodableMap* args,
    const char* key,
    bool fallback) {
  if (args == nullptr) {
    return fallback;
  }

  const auto it = args->find(flutter::EncodableValue(key));
  if (it == args->end()) {
    return fallback;
  }

  if (const auto* value = std::get_if<bool>(&it->second)) {
    return *value;
  }

  return fallback;
}

static std::vector<desktop_autopaste::TextEditOperation> ReadEditOperationsArg(
    const flutter::EncodableMap* args,
    const char* key) {
  std::vector<desktop_autopaste::TextEditOperation> operations;
  if (args == nullptr) {
    return operations;
  }

  const auto it = args->find(flutter::EncodableValue(key));
  if (it == args->end()) {
    return operations;
  }

  const auto* operation_list = std::get_if<flutter::EncodableList>(&it->second);
  if (operation_list == nullptr) {
    return operations;
  }

  for (const auto& item : *operation_list) {
    const auto* operation_map = std::get_if<flutter::EncodableMap>(&item);
    if (operation_map == nullptr) {
      continue;
    }

    const auto start = TryReadIntArg(operation_map, "start");
    const auto end = TryReadIntArg(operation_map, "end");
    const auto replacement_it =
        operation_map->find(flutter::EncodableValue("replacement"));
    if (!start.has_value() || !end.has_value() ||
        replacement_it == operation_map->end()) {
      continue;
    }
    const auto* replacement = std::get_if<std::string>(&replacement_it->second);
    if (replacement == nullptr) {
      continue;
    }

    desktop_autopaste::TextEditOperation operation;
    operation.start = *start;
    operation.end = *end;
    operation.replacement = Utf8ToWide(*replacement);
    operations.push_back(operation);
  }

  return operations;
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
  if (method_call.method_name().compare("pasteIntoCursorViaClipboard") == 0) {
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
    const bool enable_screen_reader =
        ReadBoolArg(args, "enableScreenReader", false);
    if (!enable_screen_reader) {
      flutter::EncodableMap context;
      context[flutter::EncodableValue("available")] = flutter::EncodableValue(false);
      context[flutter::EncodableValue("reason")] =
          flutter::EncodableValue("screenReaderDisabled");
      result->Success(flutter::EncodableValue(context));
      return;
    }

    const bool has_before =
        args != nullptr && args->find(flutter::EncodableValue("maxCharsBefore")) != args->end();
    const bool has_after =
        args != nullptr && args->find(flutter::EncodableValue("maxCharsAfter")) != args->end();

    const auto before = TryReadIntArg(args, "maxCharsBefore");
    const auto after = TryReadIntArg(args, "maxCharsAfter");

    const int max_chars_before = has_before
        ? (before.has_value() ? std::max(0, *before) : -1)
        : 120;
    const int max_chars_after = has_after
        ? (after.has_value() ? std::max(0, *after) : -1)
        : 120;

    const auto context =
        GetFocusedTextFieldContext(max_chars_before, max_chars_after);
    result->Success(flutter::EncodableValue(context));
  } else if (method_call.method_name().compare("editFocusedTextField") == 0) {
    const auto *args =
        std::get_if<flutter::EncodableMap>(method_call.arguments());
    if (!args) {
      result->Error("BAD_ARGS", "Missing arguments", nullptr);
      return;
    }

    const auto operations = ReadEditOperationsArg(args, "operations");
    if (operations.empty()) {
      result->Error(
          "BAD_ARGS",
          "Missing or invalid 'operations' list",
          nullptr);
      return;
    }

    const bool ok = EditFocusedTextField(operations);
    result->Success(flutter::EncodableValue(ok));
  } else {
    result->NotImplemented();
  }
}

}  // namespace desktop_autopaste
