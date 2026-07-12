#include "autopaste_text.h"

#include <windows.h>

#include <algorithm>
#include <array>
#include <cstring>
#include <cwctype>
#include <limits>
#include <mutex>
#include <string>
#include <vector>

namespace desktop_autopaste {

namespace {

constexpr int kClipboardOpenRetries = 20;
constexpr int kClipboardOpenRetryDelayMs = 10;
constexpr int kClipboardPublishAttempts = 2;
constexpr int kClipboardSequenceRetries = 50;
constexpr int kClipboardSequenceRetryDelayMs = 10;
constexpr int kClipboardVerificationRetries = 5;
constexpr int kClipboardVerificationRetryDelayMs = 20;
// Remote-hosted Windows apps (for example Citrix sessions) can consume the
// clipboard noticeably later than local apps, so restoring too early can cause
// the target to paste an empty placeholder or stale content.
constexpr int kPostPasteRestoreDelayMs = 500;
constexpr DWORD kPostPasteInputIdleTimeoutMs = 1000;
constexpr UINT kMessageTimeoutMs = 300;

constexpr std::array<UINT, 8> kModifierVirtualKeys = {
    VK_LWIN,
    VK_RWIN,
    VK_LCONTROL,
    VK_RCONTROL,
    VK_LMENU,
    VK_RMENU,
    VK_LSHIFT,
    VK_RSHIFT,
};

std::mutex g_paste_shortcut_mutex;

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

bool WaitForClipboardSequenceChange(DWORD previous_sequence) {
  for (int i = 0; i < kClipboardSequenceRetries; ++i) {
    if (::GetClipboardSequenceNumber() != previous_sequence) {
      return true;
    }
    ::Sleep(kClipboardSequenceRetryDelayMs);
  }
  return false;
}

bool ReadOpenClipboardUnicodeText(std::wstring* out_text) {
  if (out_text == nullptr) {
    return false;
  }
  out_text->clear();

  if (!::IsClipboardFormatAvailable(CF_UNICODETEXT)) {
    return false;
  }
  HANDLE clipboard_data = ::GetClipboardData(CF_UNICODETEXT);
  if (clipboard_data == nullptr) {
    return false;
  }

  SIZE_T size = ::GlobalSize(clipboard_data);
  if (size == 0) {
    return false;
  }

  const wchar_t* source =
      static_cast<const wchar_t*>(::GlobalLock(clipboard_data));
  if (source == nullptr) {
    return false;
  }

  const size_t capacity = size / sizeof(wchar_t);
  size_t length = 0;
  while (length < capacity && source[length] != L'\0') {
    ++length;
  }

  out_text->assign(source, length);
  ::GlobalUnlock(clipboard_data);
  return true;
}

bool OpenClipboardUnicodeTextEquals(const std::wstring& text) {
  std::wstring current_text;
  return ReadOpenClipboardUnicodeText(&current_text) && current_text == text;
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

bool WaitForClipboardUnicodeText(HWND owner_hwnd, const std::wstring& text) {
  for (int i = 0; i < kClipboardVerificationRetries; ++i) {
    if (!OpenClipboardWithRetries(owner_hwnd)) {
      ::Sleep(kClipboardVerificationRetryDelayMs);
      continue;
    }

    const bool matches = OpenClipboardUnicodeTextEquals(text);
    ::CloseClipboard();
    if (matches) {
      return true;
    }

    ::Sleep(kClipboardVerificationRetryDelayMs);
  }
  return false;
}

bool PublishClipboardUnicodeText(HWND owner_hwnd, const std::wstring& text) {
  for (int i = 0; i < kClipboardPublishAttempts; ++i) {
    DWORD sequence_before = ::GetClipboardSequenceNumber();
    if (!OpenClipboardWithRetries(owner_hwnd)) {
      return false;
    }

    bool publish_ok = false;
    if (::EmptyClipboard()) {
      publish_ok = SetClipboardUnicodeText(text);
    }
    ::CloseClipboard();

    if (!publish_ok) {
      continue;
    }

    WaitForClipboardSequenceChange(sequence_before);
    if (WaitForClipboardUnicodeText(owner_hwnd, text)) {
      return true;
    }
  }

  return false;
}

bool CapturePreviousAndPublishClipboardUnicodeText(
    HWND owner_hwnd,
    const std::wstring& text,
    HGLOBAL* out_previous_text_copy) {
  if (out_previous_text_copy == nullptr) {
    return false;
  }
  *out_previous_text_copy = nullptr;

  if (!OpenClipboardWithRetries(owner_hwnd)) {
    return false;
  }

  *out_previous_text_copy = DuplicateClipboardUnicodeText();
  ::CloseClipboard();

  return PublishClipboardUnicodeText(owner_hwnd, text);
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

void RestoreClipboardUnicodeTextIfStillExpected(
    HWND owner_hwnd,
    HGLOBAL previous_text_copy,
    const std::wstring& expected_text) {
  if (previous_text_copy == nullptr) {
    return;
  }

  for (int i = 0; i < kClipboardOpenRetries; ++i) {
    if (!::OpenClipboard(owner_hwnd)) {
      ::Sleep(kClipboardOpenRetryDelayMs);
      continue;
    }

    if (!OpenClipboardUnicodeTextEquals(expected_text)) {
      ::CloseClipboard();
      ::GlobalFree(previous_text_copy);
      return;
    }

    ::EmptyClipboard();
    if (::SetClipboardData(CF_UNICODETEXT, previous_text_copy) != nullptr) {
      ::CloseClipboard();
      return;
    }

    ::CloseClipboard();
    break;
  }

  ::GlobalFree(previous_text_copy);
}

INPUT MakeScanCodeInput(UINT virtual_key, bool key_up) {
  INPUT input = {};
  input.type = INPUT_KEYBOARD;
  input.ki.wVk = 0;
  input.ki.wScan = static_cast<WORD>(::MapVirtualKeyExW(
      virtual_key,
      MAPVK_VK_TO_VSC_EX,
      ::GetKeyboardLayout(0)));
  input.ki.dwFlags = KEYEVENTF_SCANCODE;
  if ((input.ki.wScan & 0xFF00) != 0) {
    input.ki.dwFlags |= KEYEVENTF_EXTENDEDKEY;
  }
  input.ki.wScan = static_cast<WORD>(input.ki.wScan & 0xFF);
  if (key_up) {
    input.ki.dwFlags |= KEYEVENTF_KEYUP;
  }
  return input;
}

void ReleaseShortcutKeysAfterFailedInjection() {
  std::vector<INPUT> cleanup_inputs;
  cleanup_inputs.reserve(kModifierVirtualKeys.size() + 2);
  cleanup_inputs.push_back(MakeScanCodeInput('V', true));
  cleanup_inputs.push_back(MakeScanCodeInput(VK_INSERT, true));
  for (const UINT modifier : kModifierVirtualKeys) {
    cleanup_inputs.push_back(MakeScanCodeInput(modifier, true));
  }

  ::SendInput(
      static_cast<UINT>(cleanup_inputs.size()),
      cleanup_inputs.data(),
      sizeof(INPUT));
}

bool SendPasteShortcut(ClipboardPasteShortcut shortcut) {
  std::lock_guard<std::mutex> lock(g_paste_shortcut_mutex);

  std::vector<INPUT> inputs;
  inputs.reserve(kModifierVirtualKeys.size() + 4);

  // SendInput does not reset existing keyboard state. In particular, an
  // Office/Copilot key or a programmable HID can leave Ctrl+Alt+Shift+Win
  // logically pressed and turn normal letters into application-launch
  // shortcuts. Neutralize only modifiers that Windows currently reports as
  // down before sending the paste chord.
  for (const UINT modifier : kModifierVirtualKeys) {
    if ((::GetAsyncKeyState(static_cast<int>(modifier)) & 0x8000) != 0) {
      inputs.push_back(MakeScanCodeInput(modifier, true));
    }
  }

  switch (shortcut) {
    case ClipboardPasteShortcut::kCtrlV:
      inputs.push_back(MakeScanCodeInput(VK_LCONTROL, false));
      inputs.push_back(MakeScanCodeInput('V', false));
      inputs.push_back(MakeScanCodeInput('V', true));
      inputs.push_back(MakeScanCodeInput(VK_LCONTROL, true));
      break;
    case ClipboardPasteShortcut::kShiftInsert:
      inputs.push_back(MakeScanCodeInput(VK_LSHIFT, false));
      inputs.push_back(MakeScanCodeInput(VK_INSERT, false));
      inputs.push_back(MakeScanCodeInput(VK_INSERT, true));
      inputs.push_back(MakeScanCodeInput(VK_LSHIFT, true));
      break;
  }

  const UINT expected_sent = static_cast<UINT>(inputs.size());
  const UINT sent = ::SendInput(expected_sent, inputs.data(), sizeof(INPUT));
  if (sent == expected_sent) {
    return true;
  }

  // A partial SendInput result can otherwise leave the shortcut key or one of
  // its modifiers down indefinitely. Best-effort key-up events are safe even
  // when the original events were not inserted.
  ReleaseShortcutKeysAfterFailedInjection();
  return false;
}

void PumpPendingMessages() {
  MSG msg;
  while (::PeekMessage(&msg, nullptr, 0, 0, PM_REMOVE)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }
}

void WaitForWindowProcessInputIdle(HWND hwnd) {
  if (hwnd == nullptr) {
    return;
  }

  DWORD process_id = 0;
  const HWND root_hwnd = ::GetAncestor(hwnd, GA_ROOT);
  ::GetWindowThreadProcessId(
      root_hwnd == nullptr ? hwnd : root_hwnd,
      &process_id);
  if (process_id == 0 || process_id == ::GetCurrentProcessId()) {
    return;
  }

  HANDLE process = ::OpenProcess(SYNCHRONIZE, FALSE, process_id);
  if (process == nullptr) {
    return;
  }

  ::WaitForInputIdle(process, kPostPasteInputIdleTimeoutMs);
  ::CloseHandle(process);
}

int NormalizePrePasteDelayMs(int pre_paste_delay_ms) {
  if (pre_paste_delay_ms < 0) {
    return 0;
  }
  return pre_paste_delay_ms;
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

bool AutoPasteTextViaClipboard(const std::wstring& text,
                               ClipboardPasteShortcut shortcut,
                               int pre_paste_delay_ms) {
  return AutoPasteTextViaClipboardWithShortcut(text,
                                               shortcut,
                                               pre_paste_delay_ms);
}

bool PasteFromClipboard(ClipboardPasteShortcut shortcut,
                        int pre_paste_delay_ms) {
  const int effective_pre_paste_delay_ms =
      NormalizePrePasteDelayMs(pre_paste_delay_ms);
  if (effective_pre_paste_delay_ms > 0) {
    ::Sleep(effective_pre_paste_delay_ms);
  }

  const HWND target_hwnd = GetFocusedWindowHandle();
  if (!SendPasteShortcut(shortcut)) {
    return false;
  }

  WaitForWindowProcessInputIdle(target_hwnd);
  PumpPendingMessages();
  return true;
}

bool AutoPasteTextViaClipboardWithShortcut(const std::wstring& text,
                                           ClipboardPasteShortcut shortcut,
                                           int pre_paste_delay_ms) {
  if (text.empty()) {
    return true;
  }

  const HWND clipboard_owner_hwnd = GetClipboardOwnerWindowHandle();
  HGLOBAL previous_text_copy = nullptr;
  if (!CapturePreviousAndPublishClipboardUnicodeText(
          clipboard_owner_hwnd,
          text,
          &previous_text_copy)) {
    RestoreClipboardUnicodeText(clipboard_owner_hwnd, previous_text_copy);
    return false;
  }

  const int effective_pre_paste_delay_ms =
      NormalizePrePasteDelayMs(pre_paste_delay_ms);
  if (effective_pre_paste_delay_ms > 0) {
    ::Sleep(effective_pre_paste_delay_ms);
  }

  if (!WaitForClipboardUnicodeText(clipboard_owner_hwnd, text) &&
      !PublishClipboardUnicodeText(clipboard_owner_hwnd, text)) {
    RestoreClipboardUnicodeText(clipboard_owner_hwnd, previous_text_copy);
    return false;
  }

  const HWND target_hwnd = GetFocusedWindowHandle();
  if (!SendPasteShortcut(shortcut)) {
    RestoreClipboardUnicodeText(clipboard_owner_hwnd, previous_text_copy);
    return false;
  }

  // SendInput only confirms dispatch, not that the target accepted the paste.
  WaitForWindowProcessInputIdle(target_hwnd);
  PumpPendingMessages();
  ::Sleep(kPostPasteRestoreDelayMs);

  RestoreClipboardUnicodeTextIfStillExpected(
      clipboard_owner_hwnd,
      previous_text_copy,
      text);
  return true;
}

}  // namespace desktop_autopaste
