## 0.1.8

* Split the plugin into an app-facing package, a shared platform interface,
  and endorsed Linux, macOS, and Windows implementation packages.

## 0.0.1

* TODO: Describe initial release.
* Fix: Windows - Removed background thread polling from device_updates channel to prevent threading issues. The channel now sends the device list once when first subscribed.
