part of '../hid_device_manager.dart';

class HidDeviceController {
  HidDeviceController(this.managedDevice);

  final HidManagedDevice managedDevice;

  HidDeviceInfo get info => managedDevice.info;
  HidDevice get hidDevice => managedDevice.requireConnectedDevice();
  Stream<HidReport> get inputReports => managedDevice.inputReports;

  Stream<HidReport> deduplicatedInputReports({
    Duration deduplicationInterval = const Duration(milliseconds: 5),
  }) {
    return managedDevice.deduplicatedInputReports(deduplicationInterval: deduplicationInterval);
  }

  DataSubject<HidManagedDeviceState> get stateSubject => managedDevice.stateSubject;

  Future<void> onAttached() async {}

  Future<void> onConnected() async {}

  Future<void> onDisconnected() async {}

  Future<void> recoverConnection() async {
    managedDevice.requireConnectedDevice();
  }

  Future<void> dispose() async {}
}
