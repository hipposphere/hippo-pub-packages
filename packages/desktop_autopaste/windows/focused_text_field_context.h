#ifndef FLUTTER_PLUGIN_FOCUSED_TEXT_FIELD_CONTEXT_H_
#define FLUTTER_PLUGIN_FOCUSED_TEXT_FIELD_CONTEXT_H_

#include <flutter/encodable_value.h>

namespace desktop_autopaste {

flutter::EncodableMap GetFocusedTextFieldContext(
    int max_chars_before,
    int max_chars_after);

}  // namespace desktop_autopaste

#endif  // FLUTTER_PLUGIN_FOCUSED_TEXT_FIELD_CONTEXT_H_
