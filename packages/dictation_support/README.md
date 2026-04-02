## dictation_support

Support dictation devices using `hid_device_manager` on top of `hid_api`.

Based on https://github.com/GoogleChromeLabs/dictation_support

### Recovering after another app takes the microphone buttons

SpeechMike-style devices can be switched out of `EventMode.hid` by other
applications such as Dragon. When that happens, button events stop flowing
until HID mode is restored.

Connected `SpeechMikeHidDevice`s now automatically run a recovery sweep that
re-asserts `EventMode.hid` and reopens devices whose handle was lost. You can
also call `recoverDevices()` manually when your app regains focus or detects
that button input stopped. `aggressiveReconnection: true` keeps the same sweep
running even when no SpeechMike HID device is currently connected.

### Exclusive access

`DictationDeviceManager` now defaults to `HidOpenMode.preferExclusive`, which
tries exclusive access first and falls back to shared access if another process
already owns the handle.

```dart
final manager = DictationDeviceManager();
await manager.init();
```

You can change the policy at runtime:

```dart
await manager.setOpenMode(HidOpenMode.preferExclusive);
await manager.setOpenMode(HidOpenMode.shared);
await manager.setOpenMode(HidOpenMode.exclusive);
```

Changing the open mode refreshes the currently managed devices because HID
share mode cannot be changed on an already open native handle.
