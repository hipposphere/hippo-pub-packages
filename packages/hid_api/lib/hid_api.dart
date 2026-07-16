import 'package:hid_api_platform_interface/hid_api_platform_interface.dart';

export 'package:hid_api_platform_interface/hid_api_platform_interface.dart'
    show
        HidDeviceInfo,
        HidDevice,
        HidReport,
        HidReportType,
        HidException,
        HidTimeoutException,
        HidDeviceNotFoundException,
        HidPermissionException,
        HidExclusiveAccessException;

abstract class HidApi {
  /// Initialize native HID subsystem
  static Future<void> initialize() {
    return HidApiPlatform.instance.initialize();
  }

  /// Free native resources
  static Future<void> shutdown() {
    return HidApiPlatform.instance.shutdown();
  }

  /// Enumerate HID devices
  static Future<List<HidDeviceInfo>> enumerate({
    int? vendorId,
    int? productId,
    String? serialNumber,
  }) {
    return HidApiPlatform.instance.enumerate(
      vendorId: vendorId,
      productId: productId,
      serialNumber: serialNumber,
    );
  }

  /// Open device by path (recommended)
  static Future<HidDevice> open(String devicePath, {bool exclusive = false}) {
    return HidApiPlatform.instance.open(devicePath, exclusive: exclusive);
  }

  /// Open device by VID/PID (first match)
  static Future<HidDevice> openById({
    required int vendorId,
    required int productId,
    String? serialNumber,
    bool exclusive = false,
  }) async {
    final devices = await enumerate(
      vendorId: vendorId,
      productId: productId,
      serialNumber: serialNumber,
    );

    if (devices.isEmpty) {
      throw HidDeviceNotFoundException();
    }

    return open(devices.first.path, exclusive: exclusive);
  }

  /// Global stream of connected HID devices
  static Stream<List<HidDeviceInfo>> get deviceListStream {
    return HidApiPlatform.instance.deviceListStream;
  }
}
