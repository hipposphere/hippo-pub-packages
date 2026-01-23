#include "autopaste_text.h"
#include <windows.h>

namespace desktop_autopaste {

bool AutoPasteText(const std::wstring& text) {
  for (wchar_t ch : text) {
    // Convert '\n' into Unicode LF explicitly
    if (ch == L'\n') {
      SendShiftEnter();
    }

    INPUT inputs[2] = {};
    inputs[0].type = INPUT_KEYBOARD;
    inputs[0].ki.wVk = 0;
    inputs[0].ki.wScan = ch;
    inputs[0].ki.dwFlags = KEYEVENTF_UNICODE;

    inputs[1] = inputs[0];
    inputs[1].ki.dwFlags |= KEYEVENTF_KEYUP;

    UINT sent = ::SendInput(2, inputs, sizeof(INPUT));
    if (sent != 2) {
      return false;
    }
  }
  return true;
}

bool SendShiftEnter() {
  INPUT seq[4] = {};
  // Shift down
  seq[0].type = INPUT_KEYBOARD;
  seq[0].ki.wVk = VK_SHIFT;

  // Enter down
  seq[1].type = INPUT_KEYBOARD;
  seq[1].ki.wVk = VK_RETURN;

  // Enter up
  seq[2] = seq[1];
  seq[2].ki.dwFlags = KEYEVENTF_KEYUP;

  // Shift up
  seq[3] = seq[0];
  seq[3].ki.dwFlags = KEYEVENTF_KEYUP;

  return ::SendInput(4, seq, sizeof(INPUT)) == 4;
}

bool AutoPasteTextViaClipboard(const std::wstring& text) {
  if (text.empty()) {
    return true;
  }

  // Get the clipboard sequence number before we start. The sequence number
  // only changes after CloseClipboard, so we capture it here to detect when
  // our changes have been committed.
  DWORD seqBefore = ::GetClipboardSequenceNumber();

  // Open the clipboard
  if (!::OpenClipboard(nullptr)) {
    return false;
  }

  // Save the current clipboard content
  HANDLE hOldData = nullptr;
  bool hasOldData = false;
  if (::IsClipboardFormatAvailable(CF_UNICODETEXT)) {
    hOldData = ::GetClipboardData(CF_UNICODETEXT);
    if (hOldData != nullptr) {
      hasOldData = true;
      // Create a copy of the old data
      SIZE_T size = ::GlobalSize(hOldData);
      HGLOBAL hOldDataCopy = ::GlobalAlloc(GMEM_MOVEABLE, size);
      if (hOldDataCopy != nullptr) {
        void* pOldData = ::GlobalLock(hOldData);
        void* pOldDataCopy = ::GlobalLock(hOldDataCopy);
        if (pOldData != nullptr && pOldDataCopy != nullptr) {
          memcpy(pOldDataCopy, pOldData, size);
        }
        ::GlobalUnlock(hOldData);
        ::GlobalUnlock(hOldDataCopy);
        hOldData = hOldDataCopy;
      } else {
        hasOldData = false;
      }
    }
  }

  // Empty the clipboard
  ::EmptyClipboard();

  // Allocate global memory for the new text
  size_t len = text.length();
  HGLOBAL hGlobal = ::GlobalAlloc(GMEM_MOVEABLE, (len + 1) * sizeof(wchar_t));
  if (hGlobal == nullptr) {
    ::CloseClipboard();
    if (hasOldData && hOldData != nullptr) {
      ::GlobalFree(hOldData);
    }
    return false;
  }

  // Copy the text to global memory
  wchar_t* pGlobal = static_cast<wchar_t*>(::GlobalLock(hGlobal));
  if (pGlobal == nullptr) {
    ::GlobalFree(hGlobal);
    ::CloseClipboard();
    if (hasOldData && hOldData != nullptr) {
      ::GlobalFree(hOldData);
    }
    return false;
  }
  memcpy(pGlobal, text.c_str(), len * sizeof(wchar_t));
  pGlobal[len] = L'\0';
  ::GlobalUnlock(hGlobal);

  // Set the new clipboard data
  if (::SetClipboardData(CF_UNICODETEXT, hGlobal) == nullptr) {
    ::GlobalFree(hGlobal);
    ::CloseClipboard();
    if (hasOldData && hOldData != nullptr) {
      ::GlobalFree(hOldData);
    }
    return false;
  }

  // Close the clipboard
  ::CloseClipboard();

  // Wait for the clipboard sequence number to change, confirming that our
  // clipboard write was fully registered by Windows. This is more reliable
  // than a fixed sleep, as it ensures the system has processed our change
  // before we send the paste command.
  const int kMaxRetries = 50;
  const int kRetryDelayMs = 10;
  int retries = 0;
  while (::GetClipboardSequenceNumber() == seqBefore && retries < kMaxRetries) {
    ::Sleep(kRetryDelayMs);
    retries++;
  }

  // Simulate Ctrl+V (VK_CONTROL + 'V')
  INPUT inputs[4] = {};
  
  // Ctrl down
  inputs[0].type = INPUT_KEYBOARD;
  inputs[0].ki.wVk = VK_CONTROL;
  inputs[0].ki.dwFlags = 0;

  // V down
  inputs[1].type = INPUT_KEYBOARD;
  inputs[1].ki.wVk = 'V';
  inputs[1].ki.dwFlags = 0;

  // V up
  inputs[2].type = INPUT_KEYBOARD;
  inputs[2].ki.wVk = 'V';
  inputs[2].ki.dwFlags = KEYEVENTF_KEYUP;

  // Ctrl up
  inputs[3].type = INPUT_KEYBOARD;
  inputs[3].ki.wVk = VK_CONTROL;
  inputs[3].ki.dwFlags = KEYEVENTF_KEYUP;

  UINT sent = ::SendInput(4, inputs, sizeof(INPUT));
  if (sent != 4) {
    if (hasOldData && hOldData != nullptr) {
      ::GlobalFree(hOldData);
    }
    return false;
  }

  // Process pending messages to ensure the paste operation is delivered
  // to the target window before restoring the clipboard
  MSG msg;
  while (::PeekMessage(&msg, nullptr, 0, 0, PM_REMOVE)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  // Add a small delay to give the target application time to process the paste
  // command.
  ::Sleep(250);

  // Restore the original clipboard content
  if (hasOldData && hOldData != nullptr) {
    // Retry opening the clipboard for a short period, as the target application
    // might still be holding it.
    for (int i = 0; i < 10; ++i) {
      if (::OpenClipboard(nullptr)) {
        ::EmptyClipboard();
        ::SetClipboardData(CF_UNICODETEXT, hOldData);
        ::CloseClipboard();
        hOldData = nullptr; // Ownership transferred to clipboard
        break;
      }
      ::Sleep(25);
    }
    if (hOldData != nullptr) {
      // If we still have the handle, it means we failed to restore the
      // clipboard, so we should free the memory.
      ::GlobalFree(hOldData);
    }
  }

  return true;
}

} // namespace desktop_autopaste
