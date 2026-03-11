#ifndef DESKTOP_AUTOPASTE_FFI_H_
#define DESKTOP_AUTOPASTE_FFI_H_

#include <stdint.h>

#if defined(_WIN32)
#define DESKTOP_AUTOPASTE_FFI_EXPORT __declspec(dllexport)
#else
#define DESKTOP_AUTOPASTE_FFI_EXPORT
#endif

#ifdef __cplusplus
extern "C" {
#endif

typedef struct desktop_autopaste_text_edit_operation_t {
  int32_t start;
  int32_t end;
  const char* replacement_utf8;
} desktop_autopaste_text_edit_operation_t;

DESKTOP_AUTOPASTE_FFI_EXPORT int32_t desktop_autopaste_paste_into_cursor_via_clipboard(
    const char* text_utf8,
    int32_t pre_paste_delay_ms,
    int32_t paste_shortcut,
    char* error_utf8,
    uint32_t error_utf8_capacity);

DESKTOP_AUTOPASTE_FFI_EXPORT int32_t desktop_autopaste_get_focused_text_field_context_json(
    int32_t max_chars_before,
    int32_t max_chars_after,
    int32_t enable_screen_reader,
    char* context_json_utf8,
    uint32_t context_json_utf8_capacity,
    char* error_utf8,
    uint32_t error_utf8_capacity);

DESKTOP_AUTOPASTE_FFI_EXPORT int32_t desktop_autopaste_edit_focused_text_field(
    const desktop_autopaste_text_edit_operation_t* operations,
    uint32_t operation_count,
    char* error_utf8,
    uint32_t error_utf8_capacity);

#ifdef __cplusplus
}
#endif

#endif  // DESKTOP_AUTOPASTE_FFI_H_
