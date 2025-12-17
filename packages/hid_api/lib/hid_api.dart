import 'hid_api_platform_interface.dart';

export 'hid_api_platform_interface.dart'
    show
        HidDeviceInfo,
        HidDevice,
        HidReport,
        HidInputReport,
        HidOutputReport,
        HidFeatureReport,
        HidException,
        HidTimeoutException,
        HidDeviceNotFoundException,
        HidPermissionException;

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
  static Future<HidDevice> open(String devicePath) {
    return HidApiPlatform.instance.open(devicePath);
  }

  /// Open device by VID/PID (first match)
  static Future<HidDevice> openById({
    required int vendorId,
    required int productId,
    String? serialNumber,
  }) async {
    final devices = await enumerate(
      vendorId: vendorId,
      productId: productId,
      serialNumber: serialNumber,
    );

    if (devices.isEmpty) {
      throw HidDeviceNotFoundException();
    }

    return open(devices.first.path);
  }
}
