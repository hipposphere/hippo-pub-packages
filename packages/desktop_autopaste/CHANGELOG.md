## 0.2.2

* Fix macOS native asset output handling so release builds keep arm64 and x86_64
  `desktop_autopaste` dylibs in architecture-specific hook output paths.
* Use a hook-local Swift module cache and verify the produced dylib contains the
  requested macOS architecture before handing it to Flutter for universal
  binary assembly.

## 0.0.1

* TODO: Describe initial release.
