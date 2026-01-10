part of 'page.dart';

class HidTestingInterfaceBloc extends BlocBase {
  HidTestingInterfaceBloc() {
    _initBloc();
    vendorIdController.addListener(reloadHidDevices);
    productIdController.addListener(reloadHidDevices);
  }

  final vendorIdController = TextEditingController();
  final productIdController = TextEditingController();

  final hidDeviceInfosSubject = DataSubject<List<HidDeviceInfo>?>.seeded(null);
  final selectedDeviceInfoSubject = DataSubject<HidDeviceInfo?>.seeded(null);
  final connectedDeviceSubject = DataSubject<HidDevice?>.seeded(null);
  final hidEventsSubject = DataSubject<List<String>>.seeded([]);
  final autoRefreshEnabledSubject = DataSubject<bool>.seeded(true);

  // Track open device paths to show in UI
  final openDevicePathsSubject = DataSubject<Set<String>>.seeded({});

  Future<void> _initBloc() async {
    await HidApi.initialize();
    _listenToDeviceUpdates();
  }

  void _listenToDeviceUpdates() {
    HidApi.deviceListStream.listen((devices) {
      if (!autoRefreshEnabledSubject.value) return;

      final sorted = _sortDevices(devices);
      hidDeviceInfosSubject.add(sorted);

      // If our selected or connected device is gone, handle it
      final selected = selectedDeviceInfoSubject.value;
      if (selected != null && !devices.any((d) => d.path == selected.path)) {
        selectedDeviceInfoSubject.add(null);
        disconnect(reason: 'Device removed');
      }
    });
  }

  void toggleAutoRefresh() {
    autoRefreshEnabledSubject.add(!autoRefreshEnabledSubject.value);
    if (autoRefreshEnabledSubject.value) {
      reloadHidDevices();
    }
  }

  List<HidDeviceInfo> _sortDevices(List<HidDeviceInfo> devices) {
    final sorted = List<HidDeviceInfo>.from(devices);
    sorted.sort((a, b) {
      // Sort by VID, then PID, then path for consistent ordering
      final vidCompare = a.vendorId.compareTo(b.vendorId);
      if (vidCompare != 0) return vidCompare;
      final pidCompare = a.productId.compareTo(b.productId);
      if (pidCompare != 0) return pidCompare;
      return a.path.compareTo(b.path);
    });
    return sorted;
  }

  Future<void> reloadHidDevices() async {
    final devices = await HidApi.enumerate();
    final sorted = _sortDevices(devices);
    hidDeviceInfosSubject.add(sorted);
  }

  void selectDevice(HidDeviceInfo info) {
    selectedDeviceInfoSubject.add(info);
    if (connectedDeviceSubject.value != null) {
      disconnect();
    }
  }

  Future<void> connect() async {
    final info = selectedDeviceInfoSubject.value;
    if (info == null) return;

    try {
      final device = await HidApi.open(info.path);
      connectedDeviceSubject.add(device);
      _updateOpenPaths();
      _log('Connected to ${info.product ?? 'Unknown'} (${info.path})');
      _startReading(device);
    } catch (e) {
      _log('Error connecting: $e');
    }
  }

  Future<void> disconnect({String? reason}) async {
    final device = connectedDeviceSubject.value;
    if (device != null) {
      await device.close();
      connectedDeviceSubject.add(null);
      _updateOpenPaths();
      _log('Disconnected${reason != null ? ': $reason' : ''}');
    }
  }

  void _updateOpenPaths() {
    final device = connectedDeviceSubject.value;
    openDevicePathsSubject.add(device != null ? {device.info.path} : {});
  }

  void _startReading(HidDevice device) async {
    device.reports.listen(
      (report) {
        _log(
          'Received report: ${report.reportId}, data: ${report.data.map((e) => e.toRadixString(16).padLeft(2, '0')).join(' ')}',
        );
      },
      onError: (e) {
        if (device.isOpen) {
          _log('Read error: $e');
        }
      },
      cancelOnError: true,
    );

    device.onDisconnected.listen((_) {
      disconnect(reason: 'Connection lost (handle invalid)');
    });
  }

  Future<void> sendReport(int reportId, List<int> data) async {
    final device = connectedDeviceSubject.value;
    if (device == null) return;

    try {
      await device.write(HidOutputReport(reportId, Uint8List.fromList(data)));
      _log(
        'Sent report: $reportId, data: ${data.map((e) => e.toRadixString(16).padLeft(2, '0')).join(' ')}',
      );
    } catch (e) {
      _log('Write error: $e');
    }
  }

  void _log(String message) {
    final current = hidEventsSubject.value;
    hidEventsSubject.add([
      '[${DateTime.now().toIso8601String().split('T').last.split('.').first}] $message',
      ...current.take(99),
    ]);
  }

  @override
  void dispose() {
    disconnect();
    vendorIdController.dispose();
    productIdController.dispose();
  }

  static HidTestingInterfaceBloc of(BuildContext context) {
    return BlocProvider.of<HidTestingInterfaceBloc>(context);
  }
}
