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
  Future<int> write(HidOutputReport report) async {
    final result = await _channel.invokeMethod<int>('write', {
      'path': path,
      'reportId': report.reportId,
      'data': report.data,
    });
    return result ?? 0;
  }

  @override
  Future<int> sendFeatureReport(HidFeatureReport report) async {
    final result = await _channel.invokeMethod<int>('sendFeatureReport', {
      'path': path,
      'reportId': report.reportId,
      'data': report.data,
    });
    return result ?? 0;
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
