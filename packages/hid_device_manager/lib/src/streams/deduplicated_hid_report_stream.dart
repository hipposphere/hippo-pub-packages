part of '../hid_device_manager.dart';

class _DeduplicatedHidReportStream {
  _DeduplicatedHidReportStream({
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

  final Stream<HidReport> source;
  final Duration deduplicationInterval;

  late final StreamController<HidReport> _controller;
  StreamSubscription<HidReport>? _subscription;

  Uint8List? _lastReportData;
  int? _lastReportId;
  DateTime? _lastReportTime;

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

    if (_lastReportTime != null &&
        _lastReportId == report.reportId &&
        _lastReportData != null &&
        _bytesEqual(_lastReportData!, report.data) &&
        now.difference(_lastReportTime!) < deduplicationInterval) {
      return;
    }

    _lastReportData = Uint8List.fromList(report.data);
    _lastReportId = report.reportId;
    _lastReportTime = now;

    _controller.add(report);
  }

  bool _bytesEqual(Uint8List a, Uint8List b) {
    if (a.length != b.length) {
      return false;
    }
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }
}
