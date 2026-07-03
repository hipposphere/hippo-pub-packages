## Unreleased

* Move Windows low-level keyboard hook event delivery out of the hook callback.
* Queue Windows hotkey events through a bounded native buffer and dispatch them
  from the plugin message loop to reduce system input stalls under load.

## 0.0.1

* TODO: Describe initial release.
