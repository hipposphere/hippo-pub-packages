#include "focused_text_field_context.h"

#include <ole2.h>
#include <uiautomation.h>
#include <windows.h>
#include <wil/resource.h>
#include <wrl/client.h>

#include <algorithm>
#include <cwctype>
#include <limits>
#include <optional>
#include <string>

namespace desktop_autopaste {
namespace {
using Microsoft::WRL::ComPtr;

class ScopedComInit {
 public:
  ScopedComInit() : hr_(::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED)) {}

  ~ScopedComInit() {
    if (hr_ == S_OK || hr_ == S_FALSE) {
      ::CoUninitialize();
    }
  }

  bool IsUsable() const {
    return hr_ == S_OK || hr_ == S_FALSE || hr_ == RPC_E_CHANGED_MODE;
  }

  HRESULT result() const { return hr_; }

 private:
  HRESULT hr_;
};

std::string WideToUtf8(const std::wstring& wide) {
  if (wide.empty()) {
    return std::string();
  }
  const int size_needed = ::WideCharToMultiByte(
      CP_UTF8, 0, wide.c_str(), -1, nullptr, 0, nullptr, nullptr);
  if (size_needed <= 0) {
    return std::string();
  }
  std::string utf8(size_needed - 1, '\0');
  ::WideCharToMultiByte(
      CP_UTF8, 0, wide.c_str(), -1, utf8.data(), size_needed, nullptr, nullptr);
  return utf8;
}

std::wstring BstrToWString(BSTR bstr) {
  if (bstr == nullptr) {
    return std::wstring();
  }
  return std::wstring(bstr, ::SysStringLen(bstr));
}

std::wstring GetTextFromRange(IUIAutomationTextRange* range, int max_length) {
  if (range == nullptr) {
    return std::wstring();
  }
  BSTR text = nullptr;
  if (FAILED(range->GetText(max_length, &text))) {
    return std::wstring();
  }
  std::wstring out = BstrToWString(text);
  if (text != nullptr) {
    ::SysFreeString(text);
  }
  return out;
}

std::string ControlTypeToString(CONTROLTYPEID control_type) {
  switch (control_type) {
    case UIA_EditControlTypeId:
      return "Edit";
    case UIA_DocumentControlTypeId:
      return "Document";
    case UIA_ComboBoxControlTypeId:
      return "ComboBox";
    case UIA_ListItemControlTypeId:
      return "ListItem";
    case UIA_TextControlTypeId:
      return "Text";
    case UIA_CustomControlTypeId:
      return "Custom";
    default:
      return std::to_string(control_type);
  }
}

HWND GetFocusedWindowHandle() {
  GUITHREADINFO thread_info = {};
  thread_info.cbSize = sizeof(GUITHREADINFO);
  if (::GetGUIThreadInfo(0, &thread_info) && thread_info.hwndFocus != nullptr) {
    return thread_info.hwndFocus;
  }
  return ::GetForegroundWindow();
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

std::optional<std::wstring> GetProcessImagePath(DWORD process_id) {
  if (process_id == 0) {
    return std::nullopt;
  }

  wil::unique_handle process(::OpenProcess(
      PROCESS_QUERY_LIMITED_INFORMATION,
      FALSE,
      process_id));
  if (!process) {
    return std::nullopt;
  }

  std::wstring path(4096, L'\0');
  DWORD size = static_cast<DWORD>(path.size());
  const BOOL ok =
      ::QueryFullProcessImageNameW(process.get(), 0, path.data(), &size);
  if (!ok || size == 0) {
    return std::nullopt;
  }
  path.resize(size);
  return path;
}

std::wstring GetBaseName(const std::wstring& path) {
  if (path.empty()) {
    return std::wstring();
  }
  const size_t idx = path.find_last_of(L"\\/");
  if (idx == std::wstring::npos || idx + 1 >= path.size()) {
    return path;
  }
  return path.substr(idx + 1);
}

bool TryGetFocusedElement(
    IUIAutomation* automation,
    HWND focused_hwnd,
    IUIAutomationElement** out_element) {
  if (automation == nullptr || out_element == nullptr) {
    return false;
  }

  if (SUCCEEDED(automation->GetFocusedElement(out_element)) && *out_element) {
    return true;
  }

  return focused_hwnd != nullptr &&
         SUCCEEDED(automation->ElementFromHandle(focused_hwnd, out_element)) &&
         *out_element != nullptr;
}

std::optional<std::wstring> ApplyTextEdits(
    const std::wstring& input,
    const std::vector<TextEditOperation>& operations) {
  std::wstring output = input;
  for (const auto& operation : operations) {
    if (operation.start < 0 || operation.end < operation.start) {
      return std::nullopt;
    }
    const size_t start = static_cast<size_t>(operation.start);
    const size_t end = static_cast<size_t>(operation.end);
    if (end > output.size()) {
      return std::nullopt;
    }
    output.replace(start, end - start, operation.replacement);
  }
  return output;
}

int TransformOffsetAfterEdits(
    int original_offset,
    const std::vector<TextEditOperation>& operations) {
  int transformed = original_offset;
  for (const auto& operation : operations) {
    const int replace_start = operation.start;
    const int replace_end = operation.end;
    const int replacement_length = static_cast<int>(operation.replacement.size());
    const int replaced_length = replace_end - replace_start;
    const int delta = replacement_length - replaced_length;

    if (transformed < replace_start) {
      continue;
    }
    if (transformed >= replace_end) {
      transformed += delta;
      continue;
    }

    // Cursor inside replaced range: place it after replacement text.
    transformed = replace_start + replacement_length;
  }
  return transformed;
}

bool TryEditViaValuePattern(
    IUIAutomationElement* element,
    const std::vector<TextEditOperation>& operations) {
  if (element == nullptr || operations.empty()) {
    return false;
  }

  ComPtr<IUIAutomationValuePattern> value_pattern;
  if (FAILED(element->GetCurrentPatternAs(
          UIA_ValuePatternId,
          IID_PPV_ARGS(&value_pattern))) ||
      !value_pattern) {
    return false;
  }

  BOOL is_read_only = TRUE;
  if (FAILED(value_pattern->get_CurrentIsReadOnly(&is_read_only)) ||
      is_read_only == TRUE) {
    return false;
  }

  BSTR value_bstr = nullptr;
  if (FAILED(value_pattern->get_CurrentValue(&value_bstr))) {
    return false;
  }
  const std::wstring current_text = BstrToWString(value_bstr);
  if (value_bstr != nullptr) {
    ::SysFreeString(value_bstr);
  }

  const auto updated_text = ApplyTextEdits(current_text, operations);
  if (!updated_text.has_value()) {
    return false;
  }
  if (*updated_text == current_text) {
    return true;
  }

  BSTR updated_bstr = ::SysAllocStringLen(
      updated_text->data(),
      static_cast<UINT>(updated_text->size()));
  if (updated_bstr == nullptr) {
    return false;
  }
  const HRESULT set_value_hr = value_pattern->SetValue(updated_bstr);
  ::SysFreeString(updated_bstr);
  return SUCCEEDED(set_value_hr);
}

bool TryEditViaWin32Edit(
    HWND focused_hwnd,
    const std::vector<TextEditOperation>& operations) {
  if (focused_hwnd == nullptr || operations.empty()) {
    return false;
  }
  if (!IsLikelyEditControl(GetWindowClassName(focused_hwnd))) {
    return false;
  }

  const int text_length = ::GetWindowTextLengthW(focused_hwnd);
  if (text_length < 0) {
    return false;
  }

  DWORD selection_start = 0;
  DWORD selection_end = 0;
  ::SendMessageW(
      focused_hwnd,
      EM_GETSEL,
      reinterpret_cast<WPARAM>(&selection_start),
      reinterpret_cast<LPARAM>(&selection_end));

  std::wstring current_text(static_cast<size_t>(text_length) + 1, L'\0');
  if (text_length > 0) {
    const int copied = ::GetWindowTextW(
        focused_hwnd,
        current_text.data(),
        text_length + 1);
    if (copied <= 0 && text_length > 0) {
      return false;
    }
    current_text.resize(static_cast<size_t>(copied));
  } else {
    current_text.clear();
  }

  const auto updated_text = ApplyTextEdits(current_text, operations);
  if (!updated_text.has_value()) {
    return false;
  }
  if (*updated_text == current_text) {
    return true;
  }

  const bool set_text_ok = ::SendMessageW(
             focused_hwnd,
             WM_SETTEXT,
             0,
             reinterpret_cast<LPARAM>(updated_text->c_str())) != 0;
  if (!set_text_ok) {
    return false;
  }

  int restored_start = TransformOffsetAfterEdits(
      static_cast<int>(selection_start),
      operations);
  int restored_end = TransformOffsetAfterEdits(
      static_cast<int>(selection_end),
      operations);
  const int updated_length = static_cast<int>(updated_text->size());
  restored_start = std::max(0, std::min(restored_start, updated_length));
  restored_end = std::max(0, std::min(restored_end, updated_length));
  if (restored_end < restored_start) {
    restored_end = restored_start;
  }

  ::SendMessageW(
      focused_hwnd,
      EM_SETSEL,
      static_cast<WPARAM>(restored_start),
      static_cast<LPARAM>(restored_end));
  return true;
}

HWND GetNativeWindowHandleFromElement(IUIAutomationElement* element) {
  if (element == nullptr) {
    return nullptr;
  }

  UIA_HWND native_hwnd = 0;
  if (SUCCEEDED(element->get_CurrentNativeWindowHandle(&native_hwnd)) &&
      native_hwnd != 0) {
    return reinterpret_cast<HWND>(native_hwnd);
  }
  return nullptr;
}

bool TryGetSelectionRangeFromTextPattern(
    IUIAutomationTextPattern* pattern,
    IUIAutomationTextRange** out_range) {
  if (out_range == nullptr || pattern == nullptr) {
    return false;
  }

  ComPtr<IUIAutomationTextRangeArray> selections;
  if (FAILED(pattern->GetSelection(&selections)) || !selections) {
    return false;
  }

  int length = 0;
  if (FAILED(selections->get_Length(&length)) || length <= 0) {
    return false;
  }

  return SUCCEEDED(selections->GetElement(0, out_range)) && *out_range != nullptr;
}

bool TryGetCaretRangeFromTextPattern2(
    IUIAutomationTextPattern2* pattern2,
    IUIAutomationTextRange** out_range) {
  if (out_range == nullptr || pattern2 == nullptr) {
    return false;
  }
  BOOL is_active = FALSE;
  return SUCCEEDED(pattern2->GetCaretRange(&is_active, out_range)) &&
         is_active == TRUE &&
         *out_range != nullptr;
}

bool ExtractContextFromRange(
    IUIAutomationTextRange* selection_range,
    int max_chars_before,
    int max_chars_after,
    std::wstring* out_before,
    std::wstring* out_selected,
    std::wstring* out_after) {
  if (selection_range == nullptr || out_before == nullptr ||
      out_selected == nullptr || out_after == nullptr) {
    return false;
  }

  *out_selected = GetTextFromRange(selection_range, -1);

  ComPtr<IUIAutomationTextRange> before_range;
  if (FAILED(selection_range->Clone(&before_range)) || !before_range) {
    return false;
  }
  if (FAILED(before_range->MoveEndpointByRange(
          TextPatternRangeEndpoint_End,
          selection_range,
          TextPatternRangeEndpoint_Start))) {
    return false;
  }
  if (max_chars_before > 0) {
    int moved = 0;
    before_range->MoveEndpointByUnit(
        TextPatternRangeEndpoint_Start,
        TextUnit_Character,
        -max_chars_before,
        &moved);
  } else if (max_chars_before < 0) {
    int moved = 0;
    before_range->MoveEndpointByUnit(
        TextPatternRangeEndpoint_Start,
        TextUnit_Character,
        std::numeric_limits<int>::min() + 1,
        &moved);
  }
  *out_before = GetTextFromRange(before_range.Get(), -1);

  ComPtr<IUIAutomationTextRange> after_range;
  if (FAILED(selection_range->Clone(&after_range)) || !after_range) {
    return false;
  }
  if (FAILED(after_range->MoveEndpointByRange(
          TextPatternRangeEndpoint_Start,
          selection_range,
          TextPatternRangeEndpoint_End))) {
    return false;
  }
  if (max_chars_after > 0) {
    int moved = 0;
    after_range->MoveEndpointByUnit(
        TextPatternRangeEndpoint_End,
        TextUnit_Character,
        max_chars_after,
        &moved);
  } else if (max_chars_after < 0) {
    int moved = 0;
    after_range->MoveEndpointByUnit(
        TextPatternRangeEndpoint_End,
        TextUnit_Character,
        std::numeric_limits<int>::max(),
        &moved);
  }
  *out_after = GetTextFromRange(after_range.Get(), -1);

  return true;
}

bool TryExtractFromTextPattern(
    IUIAutomationElement* element,
    int max_chars_before,
    int max_chars_after,
    std::wstring* out_before,
    std::wstring* out_selected,
    std::wstring* out_after) {
  if (element == nullptr) {
    return false;
  }

  ComPtr<IUIAutomationTextRange> selection_range;

  ComPtr<IUIAutomationTextPattern2> text_pattern2;
  if (SUCCEEDED(element->GetCurrentPatternAs(
          UIA_TextPattern2Id,
          IID_PPV_ARGS(&text_pattern2))) &&
      text_pattern2) {
    if (!TryGetSelectionRangeFromTextPattern(
            text_pattern2.Get(),
            selection_range.ReleaseAndGetAddressOf())) {
      TryGetCaretRangeFromTextPattern2(
          text_pattern2.Get(),
          selection_range.ReleaseAndGetAddressOf());
    }
  }

  if (!selection_range) {
    ComPtr<IUIAutomationTextPattern> text_pattern;
    if (SUCCEEDED(element->GetCurrentPatternAs(
            UIA_TextPatternId,
            IID_PPV_ARGS(&text_pattern))) &&
        text_pattern) {
      TryGetSelectionRangeFromTextPattern(
          text_pattern.Get(),
          selection_range.ReleaseAndGetAddressOf());
    }
  }

  if (!selection_range) {
    return false;
  }

  return ExtractContextFromRange(
      selection_range.Get(),
      max_chars_before,
      max_chars_after,
      out_before,
      out_selected,
      out_after);
}

bool TryExtractFromValuePattern(
    IUIAutomationElement* element,
    HWND focused_hwnd,
    int max_chars_before,
    int max_chars_after,
    std::wstring* out_before,
    std::wstring* out_selected,
    std::wstring* out_after,
    std::optional<int>* out_selection_start,
    std::optional<int>* out_selection_length,
    std::optional<int>* out_full_text_length) {
  if (element == nullptr || out_before == nullptr || out_selected == nullptr ||
      out_after == nullptr || out_selection_start == nullptr ||
      out_selection_length == nullptr || out_full_text_length == nullptr) {
    return false;
  }

  ComPtr<IUIAutomationValuePattern> value_pattern;
  if (FAILED(element->GetCurrentPatternAs(
          UIA_ValuePatternId,
          IID_PPV_ARGS(&value_pattern))) ||
      !value_pattern) {
    return false;
  }

  BSTR value_bstr = nullptr;
  if (FAILED(value_pattern->get_CurrentValue(&value_bstr))) {
    return false;
  }
  const std::wstring value = BstrToWString(value_bstr);
  if (value_bstr != nullptr) {
    ::SysFreeString(value_bstr);
  }

  *out_full_text_length = static_cast<int>(value.size());

  // Reset optional selection metadata; we fill it when we can resolve a caret
  // or selected range.
  *out_selection_start = std::nullopt;
  *out_selection_length = std::nullopt;

  HWND selection_hwnd = nullptr;
  UIA_HWND native_hwnd = 0;
  if (SUCCEEDED(element->get_CurrentNativeWindowHandle(&native_hwnd)) &&
      native_hwnd != 0) {
    selection_hwnd = reinterpret_cast<HWND>(native_hwnd);
  } else {
    selection_hwnd = focused_hwnd;
  }

  const std::wstring class_name = GetWindowClassName(selection_hwnd);
  const bool can_read_win32_selection =
      selection_hwnd != nullptr && IsLikelyEditControl(class_name);
  if (!can_read_win32_selection) {
    // Best effort fallback for UIA providers that expose ValuePattern text but
    // do not expose Win32-style selection.
    const int text_len = static_cast<int>(value.size());
    const int selection_start = text_len;
    const int selection_end = text_len;
    const int before_start = max_chars_before < 0
        ? 0
        : std::max(0, selection_start - max_chars_before);
    const int after_end = max_chars_after < 0
        ? text_len
        : std::min(text_len, selection_end + max_chars_after);

    *out_before = value.substr(before_start, selection_start - before_start);
    *out_selected = value.substr(selection_start, selection_end - selection_start);
    *out_after = value.substr(selection_end, after_end - selection_end);
    *out_selection_start = selection_start;
    *out_selection_length = 0;
    return true;
  }

  const LRESULT packed = ::SendMessageW(selection_hwnd, EM_GETSEL, 0, 0);
  int selection_start = static_cast<int>(LOWORD(static_cast<DWORD>(packed)));
  int selection_end = static_cast<int>(HIWORD(static_cast<DWORD>(packed)));

  selection_start =
      std::max(0, std::min(selection_start, static_cast<int>(value.size())));
  selection_end =
      std::max(selection_start,
               std::min(selection_end, static_cast<int>(value.size())));

  const int selection_length = selection_end - selection_start;
  const int text_len = static_cast<int>(value.size());
  const int before_start = max_chars_before < 0
      ? 0
      : std::max(0, selection_start - max_chars_before);
  const int after_end = max_chars_after < 0
      ? text_len
      : std::min(text_len, selection_end + max_chars_after);

  *out_before = value.substr(before_start, selection_start - before_start);
  *out_selected = value.substr(selection_start, selection_length);
  *out_after = value.substr(selection_end, after_end - selection_end);

  *out_selection_start = selection_start;
  *out_selection_length = selection_length;

  return true;
}

}  // namespace

FocusedTextFieldContextData GetFocusedTextFieldContext(
    int max_chars_before,
    int max_chars_after) {
  FocusedTextFieldContextData context;
  context.available = false;
  context.reason = "unknown";

  // Negative means unbounded context.
  if (max_chars_before < 0) {
    max_chars_before = -1;
  } else {
    max_chars_before = std::max(0, max_chars_before);
  }
  if (max_chars_after < 0) {
    max_chars_after = -1;
  } else {
    max_chars_after = std::max(0, max_chars_after);
  }

  ScopedComInit com;
  if (!com.IsUsable()) {
    context.reason = "comInitializationFailed";
    return context;
  }

  ComPtr<IUIAutomation> automation;
  const HRESULT automation_hr = ::CoCreateInstance(
      CLSID_CUIAutomation,
      nullptr,
      CLSCTX_INPROC_SERVER,
      IID_PPV_ARGS(&automation));
  if (FAILED(automation_hr) || !automation) {
    context.reason = "uiaUnavailable";
    return context;
  }

  const HWND focused_hwnd = GetFocusedWindowHandle();
  if (focused_hwnd == nullptr) {
    context.reason = "focusedWindowUnavailable";
    return context;
  }

  ComPtr<IUIAutomationElement> element;
  if (!TryGetFocusedElement(
          automation.Get(),
          focused_hwnd,
          element.ReleaseAndGetAddressOf())) {
    context.reason = "focusedElementUnavailable";
    return context;
  }

  int process_id = 0;
  if (SUCCEEDED(element->get_CurrentProcessId(&process_id)) && process_id > 0) {
    if (const auto image_path = GetProcessImagePath(static_cast<DWORD>(process_id))) {
      context.app_identifier = WideToUtf8(*image_path);
      context.app_name = WideToUtf8(GetBaseName(*image_path));
    }
  }

  CONTROLTYPEID control_type = 0;
  if (SUCCEEDED(element->get_CurrentControlType(&control_type))) {
    context.role = ControlTypeToString(control_type);
  }

  BSTR localized_control_type = nullptr;
  if (SUCCEEDED(element->get_CurrentLocalizedControlType(&localized_control_type)) &&
      localized_control_type != nullptr) {
    context.subrole = WideToUtf8(BstrToWString(localized_control_type));
    ::SysFreeString(localized_control_type);
  }

  BOOL is_password = FALSE;
  if (SUCCEEDED(element->get_CurrentIsPassword(&is_password))) {
    context.is_secure = (is_password == TRUE);
  }

  std::optional<bool> is_editable;
  ComPtr<IUIAutomationValuePattern> value_pattern_for_meta;
  if (SUCCEEDED(element->GetCurrentPatternAs(
          UIA_ValuePatternId,
          IID_PPV_ARGS(&value_pattern_for_meta))) &&
      value_pattern_for_meta) {
    BOOL is_read_only = FALSE;
    if (SUCCEEDED(value_pattern_for_meta->get_CurrentIsReadOnly(&is_read_only))) {
      is_editable = (is_read_only == FALSE);
    }
  }
  if (is_editable.has_value()) {
    context.is_editable = *is_editable;
  }

  std::wstring before_text;
  std::wstring selected_text;
  std::wstring after_text;
  std::optional<int> selection_start;
  std::optional<int> selection_length;
  std::optional<int> full_text_length;

  const bool from_text_pattern = TryExtractFromTextPattern(
      element.Get(),
      max_chars_before,
      max_chars_after,
      &before_text,
      &selected_text,
      &after_text);

  bool available = from_text_pattern;
  if (!from_text_pattern) {
    available = TryExtractFromValuePattern(
        element.Get(),
        focused_hwnd,
        max_chars_before,
        max_chars_after,
        &before_text,
        &selected_text,
        &after_text,
        &selection_start,
        &selection_length,
        &full_text_length);
  } else {
    selection_length = static_cast<int>(selected_text.size());
  }

  if (available) {
    context.available = true;
    context.reason = "ok";
    context.text_before_selection = WideToUtf8(before_text);
    context.selected_text = WideToUtf8(selected_text);
    context.text_after_selection = WideToUtf8(after_text);
    context.selection_start = selection_start;
    context.selection_length = selection_length;
    context.full_text_length = full_text_length;
    return context;
  }

  context.reason = "textPatternUnavailable";
  context.available = false;
  return context;
}

bool EditFocusedTextField(const std::vector<TextEditOperation>& operations) {
  if (operations.empty()) {
    return false;
  }

  ScopedComInit com;
  if (!com.IsUsable()) {
    return false;
  }

  ComPtr<IUIAutomation> automation;
  const HRESULT automation_hr = ::CoCreateInstance(
      CLSID_CUIAutomation,
      nullptr,
      CLSCTX_INPROC_SERVER,
      IID_PPV_ARGS(&automation));
  if (FAILED(automation_hr) || !automation) {
    return false;
  }

  const HWND focused_hwnd = GetFocusedWindowHandle();
  if (TryEditViaWin32Edit(focused_hwnd, operations)) {
    return true;
  }

  ComPtr<IUIAutomationElement> element;
  if (TryGetFocusedElement(
          automation.Get(),
          focused_hwnd,
          element.ReleaseAndGetAddressOf()) &&
      element) {
    const HWND native_hwnd = GetNativeWindowHandleFromElement(element.Get());
    if (TryEditViaWin32Edit(native_hwnd, operations)) {
      return true;
    }
    if (TryEditViaValuePattern(element.Get(), operations)) {
      return true;
    }
  }

  return false;
}

}  // namespace desktop_autopaste
