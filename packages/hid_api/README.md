# hid_api

A Flutter HID plugin with support for shared or exclusive device opens.

## Usage

```dart
final device = await HidApi.open(path, exclusive: true);
```

If exclusive access cannot be acquired because another application already owns
the device, `HidApi.open` throws `HidExclusiveAccessException`.

Platform notes:

- Windows: exclusive mode opens the HID handle with `dwShareMode = 0`.
- macOS: exclusive mode uses `kIOHIDOptionsTypeSeizeDevice`.
- Linux: the flag is currently accepted but not enforced by this plugin's
  backend.
