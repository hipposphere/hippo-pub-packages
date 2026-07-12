## 0.1.12

* Ignore injected Windows key-up events as well as key-down events so synthetic
  paste and keyboard-recovery sequences cannot corrupt physical hotkey state.

## 0.1.10

* Move Windows low-level keyboard hook event delivery out of the hook callback.
* Queue Windows hotkey events through a bounded native buffer and dispatch them
  from the plugin message loop to reduce system input stalls under load.

## 0.0.1

* TODO: Describe initial release.
