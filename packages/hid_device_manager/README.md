# hid_device_manager

Reactive HID device management on top of `hid_api`.

This package provides:

- device registration and matching
- reactive device availability and connection state
- per-device desired connection state
- configurable open mode (`shared`, `exclusive`, `preferExclusive`)
- reconnect orchestration
- typed controller factories for semantic HID devices

Use this package when you want lifecycle and policy management for HID devices.
Keep vendor-specific button mappings and commands in higher-level packages.
