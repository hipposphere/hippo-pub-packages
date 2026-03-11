#include "autopaste_text.h"

#include <windows.h>

#include <algorithm>
#include <cstring>
#include <cwctype>
#include <limits>
#include <string>

namespace desktop_autopaste {

namespace {

constexpr int kClipboardOpenRetries = 20;
constexpr int kClipboardOpenRetryDelayMs = 10;
constexpr int kClipboardSequenceRetries = 50;
constexpr int kClipboardSequenceRetryDelayMs = 10;
// Remote-hosted Windows apps (for example Citrix sessions) can consume the
// clipboard noticeably later than local apps, so restoring too early can cause
// the target to paste an empty placeholder or stale content.
constexpr int kPostPasteDelayMs = 750;
constexpr UINT kMessageTimeoutMs = 300;

struct ProcessTopLevelWindowSearchContext {
  DWORD process_id = 0;
  HWND best_window = nullptr;
  HWND fallback_window = nullptr;
};

BOOL CALLBACK FindProcessTopLevelWindowCallback(HWND hwnd, LPARAM lparam) {
  auto* context =
      reinterpret_cast<ProcessTopLevelWindowSearchContext*>(lparam);
  if (context == nullptr) {
    return FALSE;
  }

  DWORD window_process_id = 0;
  ::GetWindowThreadProcessId(hwnd, &window_process_id);
  if (window_process_id != context->process_id) {
    return TRUE;
  }

  if (::GetAncestor(hwnd, GA_ROOT) != hwnd) {
    return TRUE;
  }

  if (context->fallback_window == nullptr) {
    context->fallback_window = hwnd;
  }

  if (::GetWindow(hwnd, GW_OWNER) != nullptr || !::IsWindowVisible(hwnd)) {
    return TRUE;
  }

  context->best_window = hwnd;
  return FALSE;
}

HWND GetFocusedWindowHandle() {
  GUITHREADINFO thread_info = {};
  thread_info.cbSize = sizeof(GUITHREADINFO);
  if (::GetGUIThreadInfo(0, &thread_info) && thread_info.hwndFocus != nullptr) {
    return thread_info.hwndFocus;
  }
  return ::GetForegroundWindow();
}

HWND GetClipboardOwnerWindowHandle() {
  ProcessTopLevelWindowSearchContext context = {};
  context.process_id = ::GetCurrentProcessId();
  ::EnumWindows(&FindProcessTopLevelWindowCallback,
                reinterpret_cast<LPARAM>(&context));
  if (context.best_window != nullptr) {
    return context.best_window;
  }
  return context.fallback_window;
}

std::wstring GetWindowClassName(HWND hwnd) {
  if (hwnd == nullptr) {
    return std::wstring();
  }

  wchar_t class_name[256] = {0};
  const int size = ::GetClassNameW(hwnd, class_name, 255);
  if (size <= 0) {
    return std::wstring();
  }
  return std::wstring(class_name, size);
}

bool IsLikelyEditControl(const std::wstring& class_name) {
  if (class_name.empty()) {
    return false;
  }

  std::wstring upper = class_name;
  std::transform(
      upper.begin(),
      upper.end(),
      upper.begin(),
      [](wchar_t c) { return static_cast<wchar_t>(::towupper(c)); });

  return upper.find(L"EDIT") != std::wstring::npos ||
         upper.find(L"RICHEDIT") != std::wstring::npos;
}

bool SendMessageTimeoutLResult(
    HWND hwnd,
    UINT msg,
    WPARAM wparam,
    LPARAM lparam,
    LRESULT* out_result) {
  if (out_result == nullptr || hwnd == nullptr) {
    return false;
  }

  DWORD_PTR result = 0;
  const LRESULT ok = ::SendMessageTimeoutW(
      hwnd,
      msg,
      wparam,
      lparam,
      SMTO_ABORTIFHUNG | SMTO_BLOCK,
      kMessageTimeoutMs,
      &result);
  if (ok == 0) {
    return false;
  }

  *out_result = static_cast<LRESULT>(result);
  return true;
}

bool TryGetEditSelection(HWND hwnd, int* out_start, int* out_end) {
  if (out_start == nullptr || out_end == nullptr || hwnd == nullptr) {
    return false;
  }

  DWORD start = 0;
  DWORD end = 0;
  LRESULT ignored = 0;
  if (!SendMessageTimeoutLResult(
          hwnd,
          EM_GETSEL,
          reinterpret_cast<WPARAM>(&start),
          reinterpret_cast<LPARAM>(&end),
          &ignored)) {
    return false;
  }

  const DWORD kBadPos = static_cast<DWORD>(-1);
  if (start == kBadPos || end == kBadPos) {
    return false;
  }

  start = std::min(start, static_cast<DWORD>(std::numeric_limits<int>::max()));
  end = std::min(end, static_cast<DWORD>(std::numeric_limits<int>::max()));

  *out_start = static_cast<int>(start);
  *out_end = static_cast<int>(end);
  return true;
}

bool TryGetEditTextLength(HWND hwnd, int* out_length) {
  if (out_length == nullptr || hwnd == nullptr) {
    return false;
  }

  LRESULT result = 0;
  if (!SendMessageTimeoutLResult(hwnd, WM_GETTEXTLENGTH, 0, 0, &result)) {
    return false;
  }
  if (result < 0) {
    return false;
  }

  result = std::min<LRESULT>(result, std::numeric_limits<int>::max());
  *out_length = static_cast<int>(result);
  return true;
}

bool TryReplaceSelectionViaEmReplaceSel(HWND hwnd, const std::wstring& text) {
  LRESULT ignored = 0;
  return SendMessageTimeoutLResult(
      hwnd,
      EM_REPLACESEL,
      TRUE,
      reinterpret_cast<LPARAM>(text.c_str()),
      &ignored);
}

bool TryGetFocusedWin32TextFieldHandle(HWND* out_hwnd) {
  if (out_hwnd == nullptr) {
    return false;
  }
  *out_hwnd = nullptr;

  const HWND focused_hwnd = GetFocusedWindowHandle();
  if (focused_hwnd == nullptr) {
    return false;
  }

  const std::wstring class_name = GetWindowClassName(focused_hwnd);
  if (!IsLikelyEditControl(class_name)) {
    return false;
  }

  // Probe an edit-specific message so we only use direct insertion when the
  // focused control behaves like a Win32 Edit/RichEdit field.
  int selection_start = 0;
  int selection_end = 0;
  int text_length = 0;
  if (!TryGetEditSelection(focused_hwnd, &selection_start, &selection_end) &&
      !TryGetEditTextLength(focused_hwnd, &text_length)) {
    return false;
  }

  *out_hwnd = focused_hwnd;
  return true;
}

bool OpenClipboardWithRetries(HWND owner_hwnd) {
  for (int i = 0; i < kClipboardOpenRetries; ++i) {
    if (::OpenClipboard(owner_hwnd)) {
      return true;
    }
    ::Sleep(kClipboardOpenRetryDelayMs);
  }
  return false;
}

HGLOBAL DuplicateClipboardUnicodeText() {
  if (!::IsClipboardFormatAvailable(CF_UNICODETEXT)) {
    return nullptr;
  }
  HANDLE clipboard_data = ::GetClipboardData(CF_UNICODETEXT);
  if (clipboard_data == nullptr) {
    return nullptr;
  }

  SIZE_T size = ::GlobalSize(clipboard_data);
  if (size == 0) {
    return nullptr;
  }

  HGLOBAL copy = ::GlobalAlloc(GMEM_MOVEABLE, size);
  if (copy == nullptr) {
    return nullptr;
  }

  void* source = ::GlobalLock(clipboard_data);
  void* destination = ::GlobalLock(copy);
  if (source == nullptr || destination == nullptr) {
    if (destination != nullptr) {
      ::GlobalUnlock(copy);
    }
    if (source != nullptr) {
      ::GlobalUnlock(clipboard_data);
    }
    ::GlobalFree(copy);
    return nullptr;
  }

  std::memcpy(destination, source, size);
  ::GlobalUnlock(copy);
  ::GlobalUnlock(clipboard_data);
  return copy;
}

bool SetClipboardUnicodeText(const std::wstring& text) {
  HGLOBAL clipboard_text =
      ::GlobalAlloc(GMEM_MOVEABLE, (text.length() + 1) * sizeof(wchar_t));
  if (clipboard_text == nullptr) {
    return false;
  }

  wchar_t* buffer = static_cast<wchar_t*>(::GlobalLock(clipboard_text));
  if (buffer == nullptr) {
    ::GlobalFree(clipboard_text);
    return false;
  }

  std::memcpy(buffer, text.c_str(), text.length() * sizeof(wchar_t));
  buffer[text.length()] = L'\0';
  ::GlobalUnlock(clipboard_text);

  if (::SetClipboardData(CF_UNICODETEXT, clipboard_text) == nullptr) {
    ::GlobalFree(clipboard_text);
    return false;
  }
  return true;
}

void RestoreClipboardUnicodeText(HWND owner_hwnd, HGLOBAL previous_text_copy) {
  if (previous_text_copy == nullptr) {
    return;
  }

  for (int i = 0; i < kClipboardOpenRetries; ++i) {
    if (!::OpenClipboard(owner_hwnd)) {
      ::Sleep(kClipboardOpenRetryDelayMs);
      continue;
    }

    ::EmptyClipboard();
    if (::SetClipboardData(CF_UNICODETEXT, previous_text_copy) != nullptr) {
      ::CloseClipboard();
      return;
    }

    ::CloseClipboard();
    break;
  }

  // If ownership was not transferred back to the clipboard, we still own it.
  ::GlobalFree(previous_text_copy);
}

bool SendPasteShortcut(ClipboardPasteShortcut shortcut) {
  INPUT inputs[4] = {};
  UINT expected_sent = 4;

  switch (shortcut) {
    case ClipboardPasteShortcut::kCtrlV:
      // Ctrl down
      inputs[0].type = INPUT_KEYBOARD;
      inputs[0].ki.wVk = VK_CONTROL;

      // V down
      inputs[1].type = INPUT_KEYBOARD;
      inputs[1].ki.wVk = 'V';

      // V up
      inputs[2] = inputs[1];
      inputs[2].ki.dwFlags = KEYEVENTF_KEYUP;

      // Ctrl up
      inputs[3] = inputs[0];
      inputs[3].ki.dwFlags = KEYEVENTF_KEYUP;
      break;
    case ClipboardPasteShortcut::kShiftInsert:
      // Shift down
      inputs[0].type = INPUT_KEYBOARD;
      inputs[0].ki.wVk = VK_SHIFT;

      // Insert down
      inputs[1].type = INPUT_KEYBOARD;
      inputs[1].ki.wVk = VK_INSERT;

      // Insert up
      inputs[2] = inputs[1];
      inputs[2].ki.dwFlags = KEYEVENTF_KEYUP;

      // Shift up
      inputs[3] = inputs[0];
      inputs[3].ki.dwFlags = KEYEVENTF_KEYUP;
      break;
  }

  return ::SendInput(expected_sent, inputs, sizeof(INPUT)) == expected_sent;
}

void PumpPendingMessages() {
  MSG msg;
  while (::PeekMessage(&msg, nullptr, 0, 0, PM_REMOVE)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }
}

bool WaitForClipboardSequenceChange(DWORD previous_sequence) {
  for (int i = 0; i < kClipboardSequenceRetries; ++i) {
    if (::GetClipboardSequenceNumber() != previous_sequence) {
      return true;
    }
    ::Sleep(kClipboardSequenceRetryDelayMs);
  }
  return false;
}

}  // namespace

bool AutoPasteTextViaWin32Messages(const std::wstring& text) {
  if (text.empty()) {
    return true;
  }

  HWND focused_hwnd = nullptr;
  if (!TryGetFocusedWin32TextFieldHandle(&focused_hwnd)) {
    return false;
  }

  int selection_start = 0;
  int selection_end = 0;
  const bool has_selection_before =
      TryGetEditSelection(focused_hwnd, &selection_start, &selection_end);

  int text_length_before = 0;
  const bool has_length_before =
      TryGetEditTextLength(focused_hwnd, &text_length_before);

  if (!TryReplaceSelectionViaEmReplaceSel(focused_hwnd, text)) {
    return false;
  }

  // If we cannot read state, we still consider a successful message dispatch
  // as a likely success for Edit/RichEdit controls.
  int selection_start_after = 0;
  int selection_end_after = 0;
  const bool has_selection_after = TryGetEditSelection(
      focused_hwnd, &selection_start_after, &selection_end_after);

  int text_length_after = 0;
  const bool has_length_after =
      TryGetEditTextLength(focused_hwnd, &text_length_after);

  if (has_length_before && has_length_after && has_selection_before) {
    const int removed_length = std::max(0, selection_end - selection_start);
    const int expected_length =
        text_length_before - removed_length + static_cast<int>(text.length());
    if (text_length_after == expected_length) {
      return true;
    }
  }

  if (has_selection_before && has_selection_after) {
    const int expected_caret =
        selection_start + static_cast<int>(text.length());
    if (selection_start_after == selection_end_after &&
        selection_start_after == expected_caret) {
      return true;
    }
  }

  return has_selection_before || has_length_before;
}

bool AutoPasteTextViaClipboard(const std::wstring& text) {
  return AutoPasteTextViaClipboardWithShortcut(text,
                                               ClipboardPasteShortcut::kCtrlV);
}

bool AutoPasteTextViaClipboardWithShortcut(const std::wstring& text,
                                           ClipboardPasteShortcut shortcut) {
  if (text.empty()) {
    return true;
  }

  const HWND clipboard_owner_hwnd = GetClipboardOwnerWindowHandle();
  DWORD sequence_before = ::GetClipboardSequenceNumber();
  if (!OpenClipboardWithRetries(clipboard_owner_hwnd)) {
    return false;
  }

  HGLOBAL previous_text_copy = DuplicateClipboardUnicodeText();
  bool publish_ok = false;
  if (::EmptyClipboard()) {
    publish_ok = SetClipboardUnicodeText(text);
  }
  ::CloseClipboard();

  if (!publish_ok) {
    RestoreClipboardUnicodeText(clipboard_owner_hwnd, previous_text_copy);
    return false;
  }
  WaitForClipboardSequenceChange(sequence_before);

  if (!SendPasteShortcut(shortcut)) {
    RestoreClipboardUnicodeText(clipboard_owner_hwnd, previous_text_copy);
    return false;
  }

  // SendInput only confirms dispatch, not that the target accepted the paste.
  PumpPendingMessages();
  ::Sleep(kPostPasteDelayMs);

  RestoreClipboardUnicodeText(clipboard_owner_hwnd, previous_text_copy);
  return true;
}

bool AutoPasteTextViaClipboardAuto(const std::wstring& text) {
  HWND focused_hwnd = nullptr;
  if (TryGetFocusedWin32TextFieldHandle(&focused_hwnd)) {
    if (AutoPasteTextViaWin32Messages(text)) {
      return true;
    }
  }
  if (AutoPasteTextViaClipboardWithShortcut(text,
                                            ClipboardPasteShortcut::kCtrlV)) {
    return true;
  }
  return AutoPasteTextViaClipboardWithShortcut(
      text, ClipboardPasteShortcut::kShiftInsert);
}

}  // namespace desktop_autopaste
