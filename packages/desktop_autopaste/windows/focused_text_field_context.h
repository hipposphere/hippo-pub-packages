#ifndef FLUTTER_PLUGIN_FOCUSED_TEXT_FIELD_CONTEXT_H_
#define FLUTTER_PLUGIN_FOCUSED_TEXT_FIELD_CONTEXT_H_

#include <flutter/encodable_value.h>
#include <string>
#include <vector>

namespace desktop_autopaste {

struct TextEditOperation {
  int start = 0;
  int end = 0;
  std::wstring replacement;
};

flutter::EncodableMap GetFocusedTextFieldContext(
    int max_chars_before,
    int max_chars_after);

bool EditFocusedTextField(const std::vector<TextEditOperation>& operations);

}  // namespace desktop_autopaste

#endif  // FLUTTER_PLUGIN_FOCUSED_TEXT_FIELD_CONTEXT_H_
