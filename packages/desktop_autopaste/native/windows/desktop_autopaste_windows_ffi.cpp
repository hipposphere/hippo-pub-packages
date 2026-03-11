#include "desktop_autopaste_ffi.h"

#include "autopaste_text.h"
#include "focused_text_field_context.h"

#include <windows.h>

#include <algorithm>
#include <cstdint>
#include <cstring>
#include <optional>
#include <string>
#include <vector>

#include <rapidjson/stringbuffer.h>
#include <rapidjson/writer.h>

namespace {

desktop_autopaste::ClipboardPasteShortcut ParseClipboardPasteShortcut(
    int32_t raw_shortcut) {
  switch (raw_shortcut) {
    case 0:
      return desktop_autopaste::ClipboardPasteShortcut::kCtrlV;
    case 1:
      return desktop_autopaste::ClipboardPasteShortcut::kShiftInsert;
    default:
      return desktop_autopaste::ClipboardPasteShortcut::kShiftInsert;
  }
}

std::wstring Utf8ToWide(const char* utf8) {
  if (utf8 == nullptr || utf8[0] == '\0') {
    return std::wstring();
  }

  const int size_needed =
      ::MultiByteToWideChar(CP_UTF8, 0, utf8, -1, nullptr, 0);
  if (size_needed <= 0) {
    return std::wstring();
  }

  std::wstring wide(size_needed, 0);
  ::MultiByteToWideChar(CP_UTF8, 0, utf8, -1, wide.data(), size_needed);
  wide.resize(size_needed - 1);
  return wide;
}

void WriteUtf8(char* buffer, uint32_t capacity, const std::string& value) {
  if (buffer == nullptr || capacity == 0) {
    return;
  }

  const size_t copy_length = std::min<size_t>(value.size(), capacity - 1);
  std::memcpy(buffer, value.data(), copy_length);
  buffer[copy_length] = '\0';
}

void AppendOptionalJsonStringField(
    rapidjson::Writer<rapidjson::StringBuffer>& writer,
    const char* key,
    const std::optional<std::string>& value) {
  if (!value.has_value()) {
    return;
  }
  writer.Key(key);
  writer.String(
      value->c_str(),
      static_cast<rapidjson::SizeType>(value->size()));
}

void AppendOptionalJsonIntField(
    rapidjson::Writer<rapidjson::StringBuffer>& writer,
    const char* key,
    const std::optional<int>& value) {
  if (!value.has_value()) {
    return;
  }
  writer.Key(key);
  writer.Int(*value);
}

void AppendOptionalJsonBoolField(
    rapidjson::Writer<rapidjson::StringBuffer>& writer,
    const char* key,
    const std::optional<bool>& value) {
  if (!value.has_value()) {
    return;
  }
  writer.Key(key);
  writer.Bool(*value);
}

std::string ContextToJson(
    const desktop_autopaste::FocusedTextFieldContextData& context) {
  rapidjson::StringBuffer buffer;
  rapidjson::Writer<rapidjson::StringBuffer> writer(buffer);
  writer.StartObject();
  writer.Key("available");
  writer.Bool(context.available);

  if (!context.reason.empty()) {
    writer.Key("reason");
    writer.String(
        context.reason.c_str(),
        static_cast<rapidjson::SizeType>(context.reason.size()));
  }

  AppendOptionalJsonStringField(writer, "appIdentifier", context.app_identifier);
  AppendOptionalJsonStringField(writer, "appName", context.app_name);
  AppendOptionalJsonStringField(writer, "role", context.role);
  AppendOptionalJsonStringField(writer, "subrole", context.subrole);
  AppendOptionalJsonBoolField(writer, "isEditable", context.is_editable);
  AppendOptionalJsonBoolField(writer, "isSecure", context.is_secure);
  AppendOptionalJsonIntField(writer, "selectionStart", context.selection_start);
  AppendOptionalJsonIntField(writer, "selectionLength", context.selection_length);
  AppendOptionalJsonStringField(writer, "selectedText", context.selected_text);
  AppendOptionalJsonStringField(
      writer,
      "textBeforeSelection",
      context.text_before_selection);
  AppendOptionalJsonStringField(
      writer,
      "textAfterSelection",
      context.text_after_selection);
  AppendOptionalJsonIntField(writer, "fullTextLength", context.full_text_length);

  writer.EndObject();
  return std::string(buffer.GetString(), buffer.GetSize());
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
    return 2;
  }

  const bool ok = desktop_autopaste::AutoPasteTextViaClipboard(
      Utf8ToWide(text_utf8),
      ParseClipboardPasteShortcut(paste_shortcut),
      pre_paste_delay_ms);
  if (!ok) {
    WriteUtf8(error_utf8, error_utf8_capacity, "Auto paste failed");
    return 1;
  }

  WriteUtf8(error_utf8, error_utf8_capacity, "");
  return 0;
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
  if (context_json_utf8 == nullptr || context_json_utf8_capacity == 0) {
    WriteUtf8(error_utf8, error_utf8_capacity, "Missing output buffer");
    return 2;
  }

  if (enable_screen_reader == 0) {
    WriteUtf8(
        context_json_utf8,
        context_json_utf8_capacity,
        "{\"available\":false,\"reason\":\"screenReaderDisabled\"}");
    WriteUtf8(error_utf8, error_utf8_capacity, "");
    return 0;
  }

  const auto context = desktop_autopaste::GetFocusedTextFieldContext(
      static_cast<int>(max_chars_before),
      static_cast<int>(max_chars_after));
  const auto json = ContextToJson(context);
  WriteUtf8(context_json_utf8, context_json_utf8_capacity, json);
  WriteUtf8(error_utf8, error_utf8_capacity, "");
  return 0;
}

extern "C" DESKTOP_AUTOPASTE_FFI_EXPORT int32_t desktop_autopaste_edit_focused_text_field(
    const desktop_autopaste_text_edit_operation_t* operations,
    uint32_t operation_count,
    char* error_utf8,
    uint32_t error_utf8_capacity) {
  if (operations == nullptr || operation_count == 0) {
    WriteUtf8(error_utf8, error_utf8_capacity, "Missing edit operations");
    return 2;
  }

  std::vector<desktop_autopaste::TextEditOperation> parsed;
  parsed.reserve(operation_count);
  for (uint32_t i = 0; i < operation_count; ++i) {
    const auto& op = operations[i];
    if (op.replacement_utf8 == nullptr) {
      WriteUtf8(error_utf8, error_utf8_capacity, "Invalid replacement text");
      return 2;
    }

    desktop_autopaste::TextEditOperation value;
    value.start = op.start;
    value.end = op.end;
    value.replacement = Utf8ToWide(op.replacement_utf8);
    parsed.push_back(std::move(value));
  }

  const bool ok = desktop_autopaste::EditFocusedTextField(parsed);
  if (!ok) {
    WriteUtf8(error_utf8, error_utf8_capacity, "Edit operation failed");
    return 1;
  }

  WriteUtf8(error_utf8, error_utf8_capacity, "");
  return 0;
}
