import 'hid_device_info.dart';
import 'hid_report.dart';

abstract class HidDevice {
  HidDeviceInfo get info;

  /// Close device
  Future<void> close();

  /// Whether device is still open
  bool get isOpen;

  /// Set blocking/non-blocking mode
  Future<void> setBlocking(bool blocking);

  /// Read raw input report
  Future<HidInputReport> read({Duration? timeout});

  /// Write output report
  Future<int> write(HidOutputReport report);

  /// Send feature report
  Future<int> sendFeatureReport(HidFeatureReport report);

  /// Get feature report
  Future<HidFeatureReport> getFeatureReport(int reportId, int length);

  /// Flush pending reads (if supported)
  Future<void> flush();
}
