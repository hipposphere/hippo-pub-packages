# hid_api

Federated Flutter HID plugin with endorsed Linux, macOS, and Windows
implementations and support for shared or exclusive device opens.

## Package family

- `hid_api` is the app-facing API and endorses the desktop packages.
- `hid_api_platform_interface` owns the public HID types, registration
  contract, and shared method-channel implementation.
- `hid_api_linux`, `hid_api_macos`, and `hid_api_windows` own their native
  plugins and platform registration.

Applications only need to depend on `hid_api`; Flutter selects and registers
the endorsed implementation for the target desktop platform.

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
