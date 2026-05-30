# desktop_autopaste

Desktop auto-paste helpers backed by native FFI code assets.

## API

- `pasteIntoCursorViaClipboard(text, prePasteDelay: ..., pasteShortcut: ...)`
  (`prePasteDelay` is optional and defaults to `0ms`)
- `pasteFromClipboard(prePasteDelay: ..., pasteShortcut: ...)`
  sends the paste shortcut for the current clipboard contents without changing
  clipboard data
- `getFocusedTextFieldContext(maxCharsBefore, maxCharsAfter, enableScreenReader)`
- `editFocusedTextField(operations)`

## Implementation

- Dart calls native symbols through `dart:ffi`.
- Bindings are generated with `ffigen` from `native/include/desktop_autopaste_ffi.h`.
- Native libraries are built with Dart build hooks (`hook/build.dart`) and bundled as code assets.

## Notes

- Windows: paste + focused context + focused text edits are implemented natively.
- macOS: clipboard paste is implemented natively; focused context/edit APIs return unsupported.
- Linux: clipboard paste is implemented for X11/XWayland via the X11 clipboard
  selection and XTEST shortcut injection; focused context/edit APIs return
  unsupported. Linux builds require the X11 and Xtst development libraries.

## Experimental Swiftgen (macOS)

An experimental `swiftgen` setup is available for trying direct Swift-to-Dart
Objective-C interop generation:

- Swift API surface:
  - `native/macos/desktop_autopaste_macos_ffi.swift`
- Generator script:
  - `tool/generate_macos_swiftgen_bindings.dart`
- Generated Dart bindings:
  - `lib/src/ffi/generated/desktop_autopaste_macos_swiftgen_bindings.dart`

Run:

```sh
dart run tool/generate_macos_swiftgen_bindings.dart
```
