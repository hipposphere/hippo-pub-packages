#ifndef DICTO_NATIVE_TOOLS_AUTOPASTE_TEXT_H_
#define DICTO_NATIVE_TOOLS_AUTOPASTE_TEXT_H_

#include <string>

namespace desktop_autopaste {

bool AutoPasteText(const std::wstring& text);

bool AutoPasteTextViaClipboard(const std::wstring& text);

bool SendShiftEnter();

}  // namespace desktop_autopaste

#endif  // DICTO_NATIVE_TOOLS_AUTOPASTE_TEXT_H_