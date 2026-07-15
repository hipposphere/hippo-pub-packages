#ifndef FLUTTER_PLUGIN_FOCUSED_TEXT_FIELD_CONTEXT_H_
#define FLUTTER_PLUGIN_FOCUSED_TEXT_FIELD_CONTEXT_H_

#include <optional>
#include <string>
#include <vector>

namespace desktop_autopaste {

struct TextEditOperation {
  int start = 0;
  int end = 0;
  std::wstring replacement;
};

struct FocusedTextFieldContextData {
  bool available = false;
  std::string reason;
  std::optional<std::string> app_identifier;
  std::optional<std::string> app_name;
  std::optional<std::string> role;
  std::optional<std::string> subrole;
  std::optional<bool> is_editable;
  std::optional<bool> is_secure;
  std::optional<int> selection_start;
  std::optional<int> selection_length;
  std::optional<std::string> selected_text;
  std::optional<std::string> text_before_selection;
  std::optional<std::string> text_after_selection;
  std::optional<int> full_text_length;
};

FocusedTextFieldContextData GetFocusedTextFieldContext(
    int max_chars_before,
    int max_chars_after);

bool EditFocusedTextField(const std::vector<TextEditOperation>& operations);

}  // namespace desktop_autopaste

#endif  // FLUTTER_PLUGIN_FOCUSED_TEXT_FIELD_CONTEXT_H_
