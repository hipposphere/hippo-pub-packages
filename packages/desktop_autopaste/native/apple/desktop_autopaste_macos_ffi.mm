#include "desktop_autopaste_ffi.h"

#import <ApplicationServices/ApplicationServices.h>
#import <Cocoa/Cocoa.h>
#import <dispatch/dispatch.h>

#include <algorithm>
#include <cstdint>
#include <cstring>
#include <string>

namespace {

void WriteUtf8(char* buffer, uint32_t capacity, const std::string& value) {
  if (buffer == nullptr || capacity == 0) {
    return;
  }

  const size_t copy_length = std::min<size_t>(value.size(), capacity - 1);
  std::memcpy(buffer, value.data(), copy_length);
  buffer[copy_length] = '\0';
}

bool EmulateCommandV() {
  CGEventSourceRef source = CGEventSourceCreate(kCGEventSourceStateHIDSystemState);
  if (source == nullptr) {
    return false;
  }

  CGEventRef key_down = CGEventCreateKeyboardEvent(source, static_cast<CGKeyCode>(0x09), true);
  CGEventRef key_up = CGEventCreateKeyboardEvent(source, static_cast<CGKeyCode>(0x09), false);
  if (key_down == nullptr || key_up == nullptr) {
    if (key_down != nullptr) {
      CFRelease(key_down);
    }
    if (key_up != nullptr) {
      CFRelease(key_up);
    }
    CFRelease(source);
    return false;
  }

  CGEventSetFlags(key_down, kCGEventFlagMaskCommand);
  CGEventSetFlags(key_up, kCGEventFlagMaskCommand);
  CGEventPost(kCGHIDEventTap, key_down);
  CGEventPost(kCGHIDEventTap, key_up);

  CFRelease(key_down);
  CFRelease(key_up);
  CFRelease(source);
  return true;
}

NSArray<NSDictionary<NSString*, id>*>* CopyPasteboardItemsData(NSPasteboard* pasteboard) {
  NSMutableArray<NSDictionary<NSString*, id>*>* saved = [NSMutableArray array];
  NSArray<NSPasteboardItem*>* items = pasteboard.pasteboardItems;
  if (items == nil) {
    return saved;
  }

  for (NSPasteboardItem* item in items) {
    NSMutableDictionary<NSPasteboardType, NSData*>* data_by_type = [NSMutableDictionary dictionary];
    NSMutableArray<NSPasteboardType>* type_order = [NSMutableArray array];

    for (NSPasteboardType type in item.types) {
      NSString* type_value = type;
      if ([type_value containsString:@"0x"] ||
          [type_value containsString:@".pid."] ||
          [type_value hasPrefix:@"com.microsoft.ole.source."]) {
        continue;
      }

      NSData* data = [item dataForType:type];
      if (data != nil && data.length > 0) {
        data_by_type[type] = data;
        [type_order addObject:type];
      }
    }

    [saved addObject:@{
      @"dataByType": data_by_type,
      @"typeOrder": type_order,
    }];
  }

  return saved;
}

void RestorePasteboardFromData(
    NSArray<NSDictionary<NSString*, id>*>* saved_items,
    NSPasteboard* pasteboard) {
  if (saved_items == nil || saved_items.count == 0) {
    return;
  }

  NSMutableArray<NSPasteboardItem*>* recreated = [NSMutableArray array];
  for (NSDictionary<NSString*, id>* saved_item in saved_items) {
    NSDictionary<NSPasteboardType, NSData*>* data_by_type = saved_item[@"dataByType"];
    NSArray<NSPasteboardType>* type_order = saved_item[@"typeOrder"];
    if (data_by_type == nil || type_order == nil) {
      continue;
    }

    NSPasteboardItem* item = [[NSPasteboardItem alloc] init];
    for (NSPasteboardType type in type_order) {
      NSData* data = data_by_type[type];
      if (data == nil) {
        continue;
      }

      if ([type isEqualToString:NSPasteboardTypeString]) {
        NSString* string_value = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (string_value != nil) {
          [item setString:string_value forType:NSPasteboardTypeString];
          continue;
        }
      }
      [item setData:data forType:type];
    }
    [recreated addObject:item];
  }

  [pasteboard clearContents];
  if (recreated.count > 0) {
    [pasteboard writeObjects:recreated];
  }
}

bool PreflightPublish(
    NSPasteboard* pasteboard,
    NSInteger previous_change_count,
    NSString* expected_string,
    CFTimeInterval timeout_seconds) {
  const CFTimeInterval deadline = CFAbsoluteTimeGetCurrent() + timeout_seconds;
  auto is_ok = ^bool {
    if (pasteboard.changeCount <= previous_change_count) {
      return false;
    }
    NSString* value = [pasteboard stringForType:NSPasteboardTypeString];
    return value != nil && [value isEqualToString:expected_string];
  };

  if (is_ok()) {
    return true;
  }

  while (CFAbsoluteTimeGetCurrent() < deadline) {
    CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1.0 / 240.0, true);
    if (is_ok()) {
      return true;
    }
  }
  return false;
}

bool WaitForPostPasteSignal(
    NSPasteboard* pasteboard,
    NSInteger baseline_change_count,
    CFTimeInterval timeout_seconds) {
  if (pasteboard.changeCount > baseline_change_count) {
    return true;
  }

  const CFTimeInterval deadline = CFAbsoluteTimeGetCurrent() + timeout_seconds;
  while (CFAbsoluteTimeGetCurrent() < deadline) {
    CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1.0 / 240.0, true);
    if (pasteboard.changeCount > baseline_change_count) {
      return true;
    }
  }
  return false;
}

}  // namespace

extern "C" int32_t desktop_autopaste_paste_into_cursor_via_clipboard(
    const char* text_utf8,
    char* error_utf8,
    uint32_t error_utf8_capacity) {
  if (text_utf8 == nullptr) {
    WriteUtf8(error_utf8, error_utf8_capacity, "Missing text");
    return 2;
  }

  __block int32_t result_code = 0;
  __block NSString* error_message = @"";

  auto run_paste = ^{
    @autoreleasepool {
      NSString* value = [NSString stringWithUTF8String:text_utf8];
      if (value == nil) {
        result_code = 2;
        error_message = @"Invalid UTF-8 text";
        return;
      }

      NSPasteboard* pasteboard = [NSPasteboard generalPasteboard];
      NSArray<NSDictionary<NSString*, id>*>* saved_items = CopyPasteboardItemsData(pasteboard);
      const NSInteger change_before_write = pasteboard.changeCount;

      [pasteboard clearContents];
      const BOOL write_ok = [pasteboard setString:value forType:NSPasteboardTypeString];
      if (!write_ok) {
        RestorePasteboardFromData(saved_items, pasteboard);
        result_code = 1;
        error_message = @"Failed to write to pasteboard";
        return;
      }

      if (!PreflightPublish(pasteboard, change_before_write, value, 0.6)) {
        RestorePasteboardFromData(saved_items, pasteboard);
        result_code = 1;
        error_message = @"Pasteboard publish preflight failed";
        return;
      }
      const NSInteger change_after_write = pasteboard.changeCount;

      const bool key_ok = EmulateCommandV();
      const bool post_paste_ok =
          WaitForPostPasteSignal(pasteboard, change_after_write, 0.6);

      if (!key_ok) {
        RestorePasteboardFromData(saved_items, pasteboard);
        result_code = 1;
        error_message = @"Failed to emulate Command+V";
        return;
      }

      if (post_paste_ok) {
        RestorePasteboardFromData(saved_items, pasteboard);
      } else {
        // Flutter macOS text fields may read pasteboard asynchronously after the
        // Command+V key event. Delay restore to avoid racing the paste request.
        dispatch_after(
            dispatch_time(DISPATCH_TIME_NOW, static_cast<int64_t>(1.2 * NSEC_PER_SEC)),
            dispatch_get_main_queue(),
            ^{
              RestorePasteboardFromData(saved_items, pasteboard);
            });
      }
    }
  };

  if ([NSThread isMainThread]) {
    run_paste();
  } else {
    dispatch_sync(dispatch_get_main_queue(), run_paste);
  }

  if (result_code != 0) {
    WriteUtf8(error_utf8, error_utf8_capacity, [error_message UTF8String]);
    return result_code;
  }

  WriteUtf8(error_utf8, error_utf8_capacity, "");
  return 0;
}

extern "C" int32_t desktop_autopaste_get_focused_text_field_context_json(
    int32_t /*max_chars_before*/,
    int32_t /*max_chars_after*/,
    int32_t /*enable_screen_reader*/,
    char* context_json_utf8,
    uint32_t context_json_utf8_capacity,
    char* error_utf8,
    uint32_t error_utf8_capacity) {
  if (context_json_utf8 == nullptr || context_json_utf8_capacity == 0) {
    WriteUtf8(error_utf8, error_utf8_capacity, "Missing output buffer");
    return 2;
  }

  WriteUtf8(
      context_json_utf8,
      context_json_utf8_capacity,
      "{\"available\":false,\"reason\":\"unsupportedOnMacOS\"}");
  WriteUtf8(error_utf8, error_utf8_capacity, "");
  return 0;
}

extern "C" int32_t desktop_autopaste_edit_focused_text_field(
    const desktop_autopaste_text_edit_operation_t* /*operations*/,
    uint32_t /*operation_count*/,
    char* error_utf8,
    uint32_t error_utf8_capacity) {
  WriteUtf8(error_utf8, error_utf8_capacity, "unsupportedOnMacOS");
  return 3;
}
