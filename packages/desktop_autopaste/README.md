# desktop_autopaste

Federated desktop auto-paste helpers backed by endorsed native packages.

## API

- `pasteIntoCursorViaClipboard(text, prePasteDelay: ..., pasteShortcut: ...)`
  (`prePasteDelay` is optional and defaults to `0ms`)
- `pasteFromClipboard(prePasteDelay: ..., pasteShortcut: ...)`
  sends the paste shortcut for the current clipboard contents without changing
  clipboard data
- `getFocusedTextFieldContext(maxCharsBefore, maxCharsAfter, enableScreenReader)`
- `editFocusedTextField(operations)`

## Package family

- `desktop_autopaste` is the app-facing API and endorses the desktop packages.
- `desktop_autopaste_platform_interface` owns the public models, registration
  contract, unsupported fallback, and shared FFI marshalling.
- `desktop_autopaste_linux`, `desktop_autopaste_macos`, and
  `desktop_autopaste_windows` own their native sources, bindings, build hooks,
  and code assets.

Applications only need to depend on `desktop_autopaste`; Flutter selects and
registers the endorsed implementation for the target desktop platform.

## Notes

- Windows: paste + focused context + focused text edits are implemented
  natively. Temporary text is materialized before shortcut injection and the
  original clipboard is restored only while the temporary value remains
  unchanged.
- macOS: clipboard paste is implemented natively; focused context/edit APIs return unsupported.
- Linux: clipboard paste is implemented for X11/XWayland via the X11 clipboard
  selection and XTEST shortcut injection; focused context/edit APIs return
  unsupported. Linux builds require the X11 and Xtst development libraries.

## Experimental Swiftgen (macOS package)

An experimental `swiftgen` setup is available for trying direct Swift-to-Dart
Objective-C interop generation:

- Swift API surface:
  - `../desktop_autopaste_macos/native/macos/desktop_autopaste_macos_ffi.swift`
- Generator script:
  - `../desktop_autopaste_macos/tool/generate_macos_swiftgen_bindings.dart`
- Generated Dart bindings:
  - `../desktop_autopaste_macos/lib/src/generated/desktop_autopaste_macos_swiftgen_bindings.dart`

Run:

```sh
cd ../desktop_autopaste_macos
dart run tool/generate_macos_swiftgen_bindings.dart
```
