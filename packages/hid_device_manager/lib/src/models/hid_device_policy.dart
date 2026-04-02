part of '../hid_device_manager.dart';

enum HidOpenMode { shared, exclusive, preferExclusive }

enum HidManagedDeviceState {
  unavailable,
  disconnected,
  connecting,
  connected,
  disconnecting,
  reconnecting,
  error,
}
