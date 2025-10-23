#ifndef FLUTTER_PLUGIN_AUTOPASTE_TEXT_H_
#define FLUTTER_PLUGIN_AUTOPASTE_TEXT_H_

#include <string>

namespace desktop_autopaste {

bool AutoPasteText(const std::wstring& text);

bool AutoPasteTextViaClipboard(const std::wstring& text);

bool SendShiftEnter();

}  // namespace desktop_autopaste

#endif  // FLUTTER_PLUGIN_AUTOPASTE_TEXT_H_
