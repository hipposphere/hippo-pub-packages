import 'dart:async';
import 'package:flutter/foundation.dart';

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

  /// Write raw input report
  Future<HidReport> read({Duration? timeout});

  /// Continuous stream of input reports (raw, may contain duplicates)
  Stream<HidReport> get reports;

  /// Continuous stream of input reports with deduplication.
  ///
  /// Filters out consecutive duplicate reports that arrive within the
  /// specified [deduplicationInterval]. This is useful for devices like
  /// Philips SpeechMike that send each report twice on Windows.
  ///
  /// If [deduplicationInterval] is null or Duration.zero, no deduplication
  /// is performed and this behaves the same as [reports].
  Stream<HidReport> deduplicatedReports({
    Duration deduplicationInterval = const Duration(milliseconds: 5),
  }) {
    if (deduplicationInterval == Duration.zero) {
      return reports;
    }

    return _DeduplicatedReportStream(
      source: reports,
      deduplicationInterval: deduplicationInterval,
    ).stream;
  }

  /// Stream that emits when the device is disconnected
  Stream<void> get onDisconnected;

  /// Send a HID report (Output or Feature)
  Future<int> sendReport(HidReport report, HidReportType type);

  /// Get feature report
  Future<HidReport> getFeatureReport(int reportId, int length);

  /// Flush pending reads (if supported)
  Future<void> flush();
}

/// Internal class that wraps a report stream with deduplication logic.
class _DeduplicatedReportStream {
  final Stream<HidReport> source;
  final Duration deduplicationInterval;

  late final StreamController<HidReport> _controller;
  StreamSubscription<HidReport>? _subscription;

  Uint8List? _lastReportData;
  int? _lastReportId;
  DateTime? _lastReportTime;

  _DeduplicatedReportStream({
    required this.source,
    required this.deduplicationInterval,
  }) {
    _controller = StreamController<HidReport>(
      onListen: _onListen,
      onPause: _onPause,
      onResume: _onResume,
      onCancel: _onCancel,
    );
  }

  Stream<HidReport> get stream => _controller.stream;

  void _onListen() {
    _subscription = source.listen(
      _onData,
      onError: _controller.addError,
      onDone: _controller.close,
    );
  }

  void _onPause() {
    _subscription?.pause();
  }

  void _onResume() {
    _subscription?.resume();
  }

  Future<void> _onCancel() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  void _onData(HidReport report) {
    final now = DateTime.now();

    // Check if this is a duplicate
    if (_lastReportTime != null &&
        _lastReportId == report.reportId &&
        _lastReportData != null &&
        listEquals(_lastReportData, report.data) &&
        now.difference(_lastReportTime!) < deduplicationInterval) {
      // Skip duplicate
      return;
    }

    // Update state and emit
    _lastReportData = Uint8List.fromList(report.data);
    _lastReportId = report.reportId;
    _lastReportTime = now;

    _controller.add(report);
  }
}
