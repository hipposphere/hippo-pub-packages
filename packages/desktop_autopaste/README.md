# desktop_autopaste

Desktop auto-paste helpers backed by native FFI code assets.

## API

- `pasteIntoCursorViaClipboard(text)`
- `getFocusedTextFieldContext(maxCharsBefore, maxCharsAfter, enableScreenReader)`
- `editFocusedTextField(operations)`

## Implementation

- Dart calls native symbols through `dart:ffi`.
- Bindings are generated with `ffigen` from `native/include/desktop_autopaste_ffi.h`.
- Native libraries are built with Dart build hooks (`hook/build.dart`) and bundled as code assets.

## Notes

- Windows: paste + focused context + focused text edits are implemented natively.
- macOS: clipboard paste is implemented natively; focused context/edit APIs return unsupported.
- Linux: currently unsupported in the FFI path.
