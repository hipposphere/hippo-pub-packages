part of '../hid_device_manager.dart';

typedef HidDeviceControllerFactory<T extends HidDeviceController> =
    FutureOr<T> Function(HidManagedDevice managedDevice);

class HidDeviceDefinition<T extends HidDeviceController> {
  final String id;
  final String? label;
  final List<HidDeviceMatcher> matchers;
  final bool autoConnect;
  final bool reconnectOnDisconnect;
  final HidOpenMode openMode;
  final HidDeviceControllerFactory<T>? controllerFactory;

  const HidDeviceDefinition({
    required this.id,
    required this.matchers,
    this.label,
    this.autoConnect = true,
    this.reconnectOnDisconnect = true,
    this.openMode = HidOpenMode.shared,
    this.controllerFactory,
  }) : assert(matchers.length > 0);

  bool matches(HidDeviceInfo info) {
    for (final matcher in matchers) {
      if (matcher.matches(info)) {
        return true;
      }
    }
    return false;
  }
}
