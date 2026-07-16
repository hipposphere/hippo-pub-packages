# hid_api_platform_interface

Platform contract for the federated `hid_api` package family.

It owns the HID device abstractions, public models and exceptions,
implementation registration point, and shared method-channel adapter used by
the endorsed desktop packages. Applications should depend on `hid_api`, not
this package directly.
