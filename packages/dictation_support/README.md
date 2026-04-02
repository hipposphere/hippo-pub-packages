## dictation_support

Support dictation devices using the hid_api package.

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

`DictationDeviceManager` can now open HID handles in exclusive mode:

```dart
final manager = DictationDeviceManager(exclusiveAccess: true);
await manager.init();
```

You can also change this at runtime:

```dart
await manager.setExclusiveAccess(true);
await manager.setExclusiveAccess(false);
```

Changing this setting refreshes the currently managed devices because HID share
mode cannot be changed on an already open native handle.

When `exclusiveAccess` is enabled, the manager first tries to open each device
exclusively. If that fails because another application already owns the device,
it automatically falls back to shared access so the device can still connect.
