#ifndef FLUTTER_PLUGIN_AUTOPASTE_TEXT_H_
#define FLUTTER_PLUGIN_AUTOPASTE_TEXT_H_

#include <string>

namespace desktop_autopaste {

enum class ClipboardPasteShortcut {
  kCtrlV,
  kShiftInsert,
};

bool AutoPasteTextViaWin32Messages(const std::wstring& text);

bool AutoPasteTextViaClipboard(const std::wstring& text);

bool AutoPasteTextViaClipboardWithShortcut(
    const std::wstring& text,
    ClipboardPasteShortcut shortcut);

bool AutoPasteTextViaClipboardAuto(const std::wstring& text);

}  // namespace desktop_autopaste

#endif  // FLUTTER_PLUGIN_AUTOPASTE_TEXT_H_
