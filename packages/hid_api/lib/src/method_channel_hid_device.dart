import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'hid_device.dart';
import 'hid_device_info.dart';
import 'hid_report.dart';
import 'hid_exception.dart';

class MethodChannelHidDevice extends HidDevice {
  final String path;
  final MethodChannel _channel;
  final HidDeviceInfo _info;

  bool _isOpen = true;

  /// Set to true to enable verbose HID logging
  static bool verboseLogging = true;

  MethodChannelHidDevice({
    required this.path,
    required MethodChannel channel,
    required HidDeviceInfo info,
  }) : _channel = channel,
       _info = info;

  @override
  HidDeviceInfo get info => _info;

  @override
  bool get isOpen => _isOpen;

  @override
  Future<void> close() async {
    if (!_isOpen) return;
    _isOpen = false;
    await _channel.invokeMethod('close', {'path': path});
  }

  @override
  Future<void> setBlocking(bool blocking) async {
    await _channel.invokeMethod('setBlocking', {
      'path': path,
      'blocking': blocking,
    });
  }

  @override
  Future<HidInputReport> read({Duration? timeout}) async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'read',
        {'path': path, 'timeout': timeout?.inMilliseconds},
      );

      if (result == null) {
        throw HidException("Read returned null");
      }

      return HidInputReport(
        result['reportId'] as int? ?? 0,
        result['data'] as Uint8List,
      );
    } on PlatformException catch (e) {
      if (e.code == 'timeout') {
        throw HidTimeoutException();
      }
      throw HidException(e.message ?? "Read failed");
    }
  }

  @override
  Stream<HidInputReport> get reports {
    final eventChannel = EventChannel('hid_api/reports/$path');
    return eventChannel.receiveBroadcastStream().map((event) {
      final map = event as Map<dynamic, dynamic>;
      return HidInputReport(
        map['reportId'] as int? ?? 0,
        map['data'] as Uint8List,
      );
    });
  }

  @override
  Stream<void> get onDisconnected {
    final eventChannel = EventChannel('hid_api/disconnection/$path');
    return eventChannel.receiveBroadcastStream();
  }

  @override
  Future<int> sendReport(HidReport report, HidReportType type) async {
    final methodName = type == HidReportType.output
        ? 'write'
        : 'sendFeatureReport';
    final reportTypeName = type == HidReportType.output
        ? 'Output Report'
        : 'Feature Report';

    try {
      if (verboseLogging) {
        debugPrint(
          '[HID] Sending $reportTypeName: ${report.reportId}, '
          'data: ${report.data.map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase()).join(' ')}',
        );
      }

      final result = await _channel.invokeMethod<int>(methodName, {
        'path': path,
        'reportId': report.reportId,
        'data': report.data,
      });

      if (verboseLogging) {
        debugPrint('[HID] Send $reportTypeName returned: $result bytes');
      }
      return result ?? 0;
    } on PlatformException catch (e) {
      debugPrint('[HID] Send $reportTypeName failed: ${e.code} - ${e.message}');
      throw HidException('Failed to send $reportTypeName: ${e.message}');
    }
  }

  @override
  Future<HidFeatureReport> getFeatureReport(int reportId, int length) async {
    final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
      'getFeatureReport',
      {'path': path, 'reportId': reportId, 'length': length},
    );

    if (result == null) throw HidException("Failed to get feature report");

    return HidFeatureReport(reportId, result['data'] as Uint8List);
  }

  @override
  Future<void> flush() async {
    // Optional: Implement flush by reading until empty if needed,
    // or add a native method if the backend supports it.
  }
}
