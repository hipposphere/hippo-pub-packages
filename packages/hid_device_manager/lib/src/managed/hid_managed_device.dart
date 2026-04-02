part of '../hid_device_manager.dart';

class HidManagedDevice {
  HidManagedDevice._({
    required this.deviceKey,
    required HidDeviceDefinition<dynamic> definition,
    required HidDeviceInfo info,
  }) : _definition = definition,
       _info = info,
       infoSubject = DataSubject<HidDeviceInfo>.seeded(info),
       isAvailableSubject = DataSubject<bool>.seeded(true),
       desiredConnectionSubject = DataSubject<bool>.seeded(
         definition.autoConnect,
       ),
       reconnectOnDisconnectSubject = DataSubject<bool>.seeded(
         definition.reconnectOnDisconnect,
       ),
       openModeSubject = DataSubject<HidOpenMode>.seeded(definition.openMode),
       stateSubject = DataSubject<HidManagedDeviceState>.seeded(
         HidManagedDeviceState.disconnected,
       ),
       handleSubject = DataSubject<HidDevice?>.seeded(null),
       controllerSubject = DataSubject<HidDeviceController?>.seeded(null),
       lastErrorSubject = DataSubject<Object?>.seeded(null);

  final String deviceKey;

  HidDeviceDefinition<dynamic> _definition;
  HidDeviceInfo _info;
  HidDevice? _hidDevice;
  HidDeviceController? _controller;

  StreamSubscription<HidReport>? _reportSubscription;
  StreamSubscription<void>? _nativeDisconnectSubscription;
  Timer? _reconnectTimer;

  bool _isDisposed = false;
  bool _connectedLifecycleActive = false;
  Future<void> _operationQueue = Future<void>.value();

  final DataSubject<HidDeviceInfo> infoSubject;
  final DataSubject<bool> isAvailableSubject;
  final DataSubject<bool> desiredConnectionSubject;
  final DataSubject<bool> reconnectOnDisconnectSubject;
  final DataSubject<HidOpenMode> openModeSubject;
  final DataSubject<HidManagedDeviceState> stateSubject;
  final DataSubject<HidDevice?> handleSubject;
  final DataSubject<HidDeviceController?> controllerSubject;
  final DataSubject<Object?> lastErrorSubject;

  final PublishSubject<HidReport> _inputReportController =
      PublishSubject<HidReport>();
  final PublishSubject<Object> _inputErrorController = PublishSubject<Object>();

  HidDeviceDefinition<dynamic> get definition => _definition;
  HidDeviceInfo get info => _info;
  String get path => _info.path;
  bool get isAvailable => isAvailableSubject.value;

  bool get isConnected =>
      stateSubject.value == HidManagedDeviceState.connected &&
      _hidDevice != null &&
      _hidDevice!.isOpen;

  String get label => definition.label ?? info.product ?? definition.id;
  HidDeviceController? get controller => _controller;

  Stream<HidReport> get inputReports => _inputReportController.stream;
  Stream<Object> get inputErrors => _inputErrorController.stream;

  T? controllerAs<T extends HidDeviceController>() {
    final controller = _controller;
    if (controller is T) {
      return controller;
    }
    return null;
  }

  HidDevice requireConnectedDevice() {
    final device = _hidDevice;
    if (device == null || !device.isOpen) {
      throw HidException('Device $deviceKey is not connected');
    }
    return device;
  }

  Stream<HidReport> deduplicatedInputReports({
    Duration deduplicationInterval = const Duration(milliseconds: 5),
  }) {
    if (deduplicationInterval == Duration.zero) {
      return inputReports;
    }

    return _DeduplicatedHidReportStream(
      source: inputReports,
      deduplicationInterval: deduplicationInterval,
    ).stream;
  }

  Future<void> connect() async {
    if (_isDisposed) return;

    desiredConnectionSubject.add(true);
    await _enqueue(() async {
      await _connectInternal(
        reconnecting:
            stateSubject.value == HidManagedDeviceState.reconnecting ||
            stateSubject.value == HidManagedDeviceState.error,
      );
    });
  }

  Future<void> disconnect() async {
    if (_isDisposed) return;

    desiredConnectionSubject.add(false);
    await _enqueue(() async {
      await _disconnectInternal(
        nextState: isAvailable
            ? HidManagedDeviceState.disconnected
            : HidManagedDeviceState.unavailable,
      );
    });
  }

  Future<void> reconnect() async {
    if (_isDisposed) return;

    desiredConnectionSubject.add(true);
    await _enqueue(() async {
      await _disconnectInternal(
        nextState: isAvailable
            ? HidManagedDeviceState.disconnected
            : HidManagedDeviceState.unavailable,
      );
      await _connectInternal(reconnecting: true);
    });
  }

  Future<void> setOpenMode(HidOpenMode openMode) async {
    if (_isDisposed || openModeSubject.value == openMode) {
      return;
    }

    openModeSubject.add(openMode);

    if (desiredConnectionSubject.value || isConnected) {
      await reconnect();
    }
  }

  Future<void> setReconnectOnDisconnect(bool reconnectOnDisconnect) async {
    if (_isDisposed) return;
    reconnectOnDisconnectSubject.add(reconnectOnDisconnect);
  }

  Future<int> sendReport(HidReport report, HidReportType type) {
    return requireConnectedDevice().sendReport(report, type);
  }

  Future<HidReport> getFeatureReport(int reportId, int length) {
    return requireConnectedDevice().getFeatureReport(reportId, length);
  }

  Future<HidReport> read({Duration? timeout}) {
    return requireConnectedDevice().read(timeout: timeout);
  }

  Future<void> flush() {
    return requireConnectedDevice().flush();
  }

  Future<void> _enqueue(Future<void> Function() operation) {
    _operationQueue = _operationQueue.then((_) async {
      if (_isDisposed) return;
      await operation();
    });
    return _operationQueue;
  }

  Future<void> _ensureControllerCreated() async {
    if (_controller != null) {
      return;
    }

    final controller =
        await _definition.controllerFactory?.call(this) ??
        HidDeviceController(this);
    await controller.onAttached();
    _controller = controller;
    controllerSubject.add(controller);
  }

  Future<void> _connectInternal({bool reconnecting = false}) async {
    if (_isDisposed || !desiredConnectionSubject.value || !isAvailable) {
      return;
    }
    if (isConnected ||
        stateSubject.value == HidManagedDeviceState.connecting ||
        stateSubject.value == HidManagedDeviceState.reconnecting) {
      return;
    }

    _reconnectTimer?.cancel();
    await _ensureControllerCreated();
    lastErrorSubject.add(null);
    stateSubject.add(
      reconnecting
          ? HidManagedDeviceState.reconnecting
          : HidManagedDeviceState.connecting,
    );

    try {
      final device = await _openCurrentDevice();
      _hidDevice = device;
      handleSubject.add(device);
      _bindDeviceStreams(device);
      _connectedLifecycleActive = true;
      stateSubject.add(HidManagedDeviceState.connected);
      try {
        await _controller?.onConnected();
      } catch (error) {
        lastErrorSubject.add(error);
        await _disconnectInternal(nextState: HidManagedDeviceState.error);
      }
    } catch (error) {
      _hidDevice = null;
      handleSubject.add(null);
      lastErrorSubject.add(error);
      stateSubject.add(HidManagedDeviceState.error);
    }
  }

  Future<void> _disconnectInternal({
    required HidManagedDeviceState nextState,
  }) async {
    _reconnectTimer?.cancel();

    final currentState = stateSubject.value;
    final shouldTransition =
        currentState == HidManagedDeviceState.connected ||
        currentState == HidManagedDeviceState.connecting ||
        currentState == HidManagedDeviceState.reconnecting ||
        currentState == HidManagedDeviceState.error;

    if (shouldTransition) {
      stateSubject.add(HidManagedDeviceState.disconnecting);
    }

    await _reportSubscription?.cancel();
    _reportSubscription = null;
    await _nativeDisconnectSubscription?.cancel();
    _nativeDisconnectSubscription = null;

    final device = _hidDevice;
    _hidDevice = null;
    handleSubject.add(null);

    if (device != null && device.isOpen) {
      try {
        await device.close();
      } catch (error) {
        lastErrorSubject.add(error);
      }
    }

    if (_connectedLifecycleActive) {
      _connectedLifecycleActive = false;
      await _controller?.onDisconnected();
    }

    stateSubject.add(nextState);
  }

  Future<HidDevice> _openCurrentDevice() async {
    switch (openModeSubject.value) {
      case HidOpenMode.shared:
        return HidApi.open(info.path, exclusive: false);
      case HidOpenMode.exclusive:
        return HidApi.open(info.path, exclusive: true);
      case HidOpenMode.preferExclusive:
        try {
          return await HidApi.open(info.path, exclusive: true);
        } on HidExclusiveAccessException {
          return HidApi.open(info.path, exclusive: false);
        }
    }
  }

  void _bindDeviceStreams(HidDevice device) {
    _reportSubscription = device.reports.listen(
      (report) {
        if (!_inputReportController.isClosed) {
          _inputReportController.add(report);
        }
      },
      onError: (error) {
        if (_isDisposed) return;
        if (!_inputErrorController.isClosed) {
          _inputErrorController.add(error);
        }
        lastErrorSubject.add(error);
        unawaited(_handleUnexpectedDisconnect());
      },
      cancelOnError: false,
    );

    _nativeDisconnectSubscription = device.onDisconnected.listen((_) {
      if (_isDisposed) return;
      unawaited(_handleUnexpectedDisconnect());
    });
  }

  Future<void> _handleUnexpectedDisconnect() async {
    await _enqueue(() async {
      if (_isDisposed) return;

      await _reportSubscription?.cancel();
      _reportSubscription = null;
      await _nativeDisconnectSubscription?.cancel();
      _nativeDisconnectSubscription = null;

      final device = _hidDevice;
      _hidDevice = null;
      handleSubject.add(null);

      if (device != null && device.isOpen) {
        try {
          await device.close();
        } catch (_) {}
      }

      if (_connectedLifecycleActive) {
        _connectedLifecycleActive = false;
        await _controller?.onDisconnected();
      }

      stateSubject.add(
        isAvailable
            ? HidManagedDeviceState.disconnected
            : HidManagedDeviceState.unavailable,
      );

      if (desiredConnectionSubject.value &&
          reconnectOnDisconnectSubject.value &&
          isAvailable) {
        _scheduleReconnect();
      }
    });
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(milliseconds: 500), () {
      if (_isDisposed || !desiredConnectionSubject.value || !isAvailable) {
        return;
      }
      unawaited(
        _enqueue(() async {
          await _connectInternal(reconnecting: true);
        }),
      );
    });
  }

  Future<void> _updateInfo(HidDeviceInfo info) async {
    if (_isDisposed) return;
    _info = info;
    infoSubject.add(info);
  }

  Future<void> _markAvailable(HidDeviceInfo info) async {
    await _updateInfo(info);
    final wasAvailable = isAvailable;
    if (!wasAvailable) {
      isAvailableSubject.add(true);
    }
    if (stateSubject.value == HidManagedDeviceState.unavailable) {
      stateSubject.add(HidManagedDeviceState.disconnected);
    }
    if (desiredConnectionSubject.value) {
      unawaited(
        _enqueue(() async {
          await _connectInternal();
        }),
      );
    }
  }

  Future<void> _markUnavailable() async {
    if (_isDisposed) return;
    if (isAvailable) {
      isAvailableSubject.add(false);
    }
    await _enqueue(() async {
      await _disconnectInternal(nextState: HidManagedDeviceState.unavailable);
    });
  }

  Future<void> _dispose() async {
    _isDisposed = true;
    _reconnectTimer?.cancel();
    await _disconnectInternal(nextState: HidManagedDeviceState.unavailable);
    await _controller?.dispose();
    await _reportSubscription?.cancel();
    await _nativeDisconnectSubscription?.cancel();
    await _inputReportController.close();
    await _inputErrorController.close();
    infoSubject.close();
    isAvailableSubject.close();
    desiredConnectionSubject.close();
    reconnectOnDisconnectSubject.close();
    openModeSubject.close();
    stateSubject.close();
    handleSubject.close();
    controllerSubject.close();
    lastErrorSubject.close();
  }
}
