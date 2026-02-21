#include "desktop_autopaste_ffi.h"

#include "autopaste_text.h"
#include "focused_text_field_context.h"

#include <windows.h>

#include <algorithm>
#include <cstdint>
#include <cstring>
#include <optional>
#include <sstream>
#include <string>
#include <vector>

namespace {

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

std::string EscapeJsonString(const std::string& input) {
  std::string escaped;
  escaped.reserve(input.size() + 16);

  for (const char ch : input) {
    switch (ch) {
      case '"':
        escaped += "\\\"";
        break;
      case '\\':
        escaped += "\\\\";
        break;
      case '\b':
        escaped += "\\b";
        break;
      case '\f':
        escaped += "\\f";
        break;
      case '\n':
        escaped += "\\n";
        break;
      case '\r':
        escaped += "\\r";
        break;
      case '\t':
        escaped += "\\t";
        break;
      default:
        const unsigned char byte = static_cast<unsigned char>(ch);
        if (byte < 0x20) {
          const char hex[] = "0123456789abcdef";
          escaped += "\\u00";
          escaped += hex[(byte >> 4) & 0x0F];
          escaped += hex[byte & 0x0F];
        } else {
          escaped.push_back(ch);
        }
        break;
    }
  }

  return escaped;
}

void AppendJsonStringField(
    std::ostringstream& out,
    const char* key,
    const std::optional<std::string>& value,
    bool* needs_comma) {
  if (!value.has_value()) {
    return;
  }
  if (*needs_comma) {
    out << ',';
  }
  out << '"' << key << "\":\"" << EscapeJsonString(*value) << '"';
  *needs_comma = true;
}

void AppendJsonIntField(
    std::ostringstream& out,
    const char* key,
    const std::optional<int>& value,
    bool* needs_comma) {
  if (!value.has_value()) {
    return;
  }
  if (*needs_comma) {
    out << ',';
  }
  out << '"' << key << "\":" << *value;
  *needs_comma = true;
}

void AppendJsonBoolField(
    std::ostringstream& out,
    const char* key,
    const std::optional<bool>& value,
    bool* needs_comma) {
  if (!value.has_value()) {
    return;
  }
  if (*needs_comma) {
    out << ',';
  }
  out << '"' << key << "\":" << (*value ? "true" : "false");
  *needs_comma = true;
}

std::string ContextToJson(
    const desktop_autopaste::FocusedTextFieldContextData& context) {
  std::ostringstream out;
  out << '{';

  bool needs_comma = false;
  out << "\"available\":" << (context.available ? "true" : "false");
  needs_comma = true;

  if (!context.reason.empty()) {
    out << ",\"reason\":\"" << EscapeJsonString(context.reason) << '"';
  }

  AppendJsonStringField(out, "appIdentifier", context.app_identifier, &needs_comma);
  AppendJsonStringField(out, "appName", context.app_name, &needs_comma);
  AppendJsonStringField(out, "role", context.role, &needs_comma);
  AppendJsonStringField(out, "subrole", context.subrole, &needs_comma);
  AppendJsonBoolField(out, "isEditable", context.is_editable, &needs_comma);
  AppendJsonBoolField(out, "isSecure", context.is_secure, &needs_comma);
  AppendJsonIntField(out, "selectionStart", context.selection_start, &needs_comma);
  AppendJsonIntField(out, "selectionLength", context.selection_length, &needs_comma);
  AppendJsonStringField(out, "selectedText", context.selected_text, &needs_comma);
  AppendJsonStringField(
      out,
      "textBeforeSelection",
      context.text_before_selection,
      &needs_comma);
  AppendJsonStringField(
      out,
      "textAfterSelection",
      context.text_after_selection,
      &needs_comma);
  AppendJsonIntField(out, "fullTextLength", context.full_text_length, &needs_comma);

  out << '}';
  return out.str();
}

}  // namespace

extern "C" __declspec(dllexport) int32_t
    desktop_autopaste_paste_into_cursor_via_clipboard(
        const char* text_utf8,
        char* error_utf8,
        uint32_t error_utf8_capacity) {
  if (text_utf8 == nullptr) {
    WriteUtf8(error_utf8, error_utf8_capacity, "Missing text");
    return 2;
  }

  const bool ok = desktop_autopaste::AutoPasteTextViaClipboard(Utf8ToWide(text_utf8));
  if (!ok) {
    WriteUtf8(error_utf8, error_utf8_capacity, "Auto paste failed");
    return 1;
  }

  WriteUtf8(error_utf8, error_utf8_capacity, "");
  return 0;
}

extern "C" __declspec(dllexport) int32_t
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

extern "C" __declspec(dllexport) int32_t desktop_autopaste_edit_focused_text_field(
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
