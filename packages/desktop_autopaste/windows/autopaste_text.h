#ifndef DICTO_NATIVE_TOOLS_AUTOPASTE_TEXT_H_
#define DICTO_NATIVE_TOOLS_AUTOPASTE_TEXT_H_

#include <string>

namespace autopaste_text {

bool AutoPasteText(const std::wstring& text);

bool AutoPasteTextViaClipboard(const std::wstring& text);

bool SendShiftEnter();

}  // namespace autopaste_text

#endif  // DICTO_NATIVE_TOOLS_AUTOPASTE_TEXT_H_