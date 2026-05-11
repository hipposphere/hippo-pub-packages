## 0.2.9

* Harden Windows clipboard auto-paste against stale clipboard races by
  verifying the published text before sending the paste shortcut and avoiding
  restore when another process changed the clipboard after paste injection.

## 0.2.8

* Add Linux clipboard auto-paste support for X11/XWayland using the X11
  clipboard selection and XTEST paste shortcut injection.

## 0.2.7

* Switch Windows paste shortcut injection to scan-code based `SendInput`.
* Add a selectable paste shortcut (`Ctrl+V` or `Shift+Insert`) to the Dart API.

## 0.2.6

* Change the default Windows clipboard paste shortcut from `Ctrl+V` to
  `Shift+Insert`.

## 0.2.4

* Add a configurable pre-paste delay for native clipboard paste so Windows
  callers can give Citrix and other remote-hosted apps time to sync clipboard
  contents before the paste shortcut is sent.

## 0.2.2

* Fix macOS native asset output handling so release builds keep arm64 and x86_64
  `desktop_autopaste` dylibs in architecture-specific hook output paths.
* Use a hook-local Swift module cache and verify the produced dylib contains the
  requested macOS architecture before handing it to Flutter for universal
  binary assembly.

## 0.0.1

* TODO: Describe initial release.
