import 'dart:async';
import 'package:hid_api/hid_api.dart';
import 'package:hippo_utils/hippo_utils.dart';
import 'dictation_device.dart';
import 'enums.dart';
import 'utils.dart';
import 'devices/foot_control_device.dart';
import 'devices/powermic_3_device.dart';
import 'devices/speechmike_gamepad_device.dart';
import 'devices/speechmike_hid_device.dart';

typedef DeviceEventListener = void Function(DictationDevice device);

class DictationDeviceManager {
  final Set<ButtonEventListener> _buttonEventListeners = {};
  final Set<DeviceEventListener> _deviceConnectEventListeners = {};
  final Set<DeviceEventListener> _deviceDisconnectEventListeners = {};
  final Set<MotionEventListener> _motionEventListeners = {};

  final Map<String, DictationDevice> _devices = {};
  final Map<String, SpeechMikeGamepadDevice> _pendingProxyDevices = {};

  bool _isInitialized = false;
  StreamSubscription<List<HidDeviceInfo>>? _deviceListSubscription;

  // Stream controllers for device events
  final StreamController<DictationDevice> _deviceConnectedController =
      StreamController<DictationDevice>.broadcast();
  final StreamController<DictationDevice> _deviceDisconnectedController =
      StreamController<DictationDevice>.broadcast();
  final StreamController<(DictationDevice, ButtonStates)>
  _buttonStateChangedController =
      StreamController<(DictationDevice, ButtonStates)>.broadcast();
  final StreamController<(DictationDevice, ButtonChange)>
  _buttonChangeController =
      StreamController<(DictationDevice, ButtonChange)>.broadcast();
  final DataSubject<List<DictationDevice>> _connectedDevicesSubject =
      DataSubject<List<DictationDevice>>.seeded([]);
  final DataSubject<bool> _exclusiveAccessSubject;

  // Track button states for all devices
  final Map<int, ButtonStates> _deviceButtonStates = {};

  // Track subscriptions to device streams
  final Map<int, StreamSubscription<ButtonStates>> _stateSubscriptions = {};
  final Map<int, StreamSubscription<ButtonChange>> _changeSubscriptions = {};

  final bool aggressiveReconnection;
  bool _exclusiveAccess;
  Timer? _reconnectTimer;
  static const Duration _reconnectInterval = Duration(seconds: 3);
  bool _isRecoverySweepRunning = false;
  bool _isDeviceReloadRunning = false;

  DictationDeviceManager({
    this.aggressiveReconnection = false,
    bool exclusiveAccess = false,
  }) : _exclusiveAccess = exclusiveAccess,
       _exclusiveAccessSubject = DataSubject<bool>.seeded(exclusiveAccess);

  /// Stream of newly connected dictation devices
  Stream<DictationDevice> get deviceConnectedStream =>
      _deviceConnectedController.stream;

  /// Stream of disconnected dictation devices
  Stream<DictationDevice> get deviceDisconnectedStream =>
      _deviceDisconnectedController.stream;

  /// Stream of button state changes from all devices
  ///
  /// Emits a tuple of (device, ButtonStates) whenever any device's button state changes.
  Stream<(DictationDevice, ButtonStates)> get onButtonStateChanged =>
      _buttonStateChangedController.stream;

  /// Stream of individual button changes from all devices
  ///
  /// Emits a tuple of (device, ButtonChange) for each button press/release on any device.
  Stream<(DictationDevice, ButtonChange)> get onButtonChange =>
      _buttonChangeController.stream;

  /// Subject of the current list of connected devices
  DataSubject<List<DictationDevice>> get connectedDevicesSubject =>
      _connectedDevicesSubject;

  /// Subject of the current exclusive-access setting.
  DataSubject<bool> get exclusiveAccessSubject => _exclusiveAccessSubject;

  /// Stream of the current list of connected devices
  ///
  /// Emits the updated list of connected dictation devices whenever a device
  /// is connected or disconnected. This allows you to always have the current
  /// state of all connected devices.
  ///
  /// Example:
  /// ```dart
  /// final manager = DictationDeviceManager();
  /// await manager.init();
  ///
  /// manager.connectedDevicesStream.listen((devices) {
  ///   print('Currently connected devices: ${devices.length}');
  ///   for (final device in devices) {
  ///     print('  - ${device.getDeviceType()}');
  ///   }
  /// });
  /// ```
  Stream<List<DictationDevice>> get connectedDevicesStream =>
      _connectedDevicesSubject.stream;

  /// Stream of exclusive-access setting changes.
  Stream<bool> get exclusiveAccessStream => _exclusiveAccessSubject.stream;

  /// Get the current button states for all devices
  ///
  /// Returns a map of device ID to ButtonStates.
  Map<int, ButtonStates> get allButtonStates =>
      Map.unmodifiable(_deviceButtonStates);

  bool get exclusiveAccess => _exclusiveAccess;

  List<DictationDevice> getDevices() {
    _failIfNotInitialized();
    return _devices.values.toList();
  }

  Future<void> setExclusiveAccess(bool exclusiveAccess) async {
    if (_exclusiveAccess == exclusiveAccess) {
      return;
    }

    _exclusiveAccess = exclusiveAccess;
    _exclusiveAccessSubject.add(exclusiveAccess);

    if (!_isInitialized || _isDeviceReloadRunning) {
      return;
    }

    await _reloadManagedDevices();
  }

  Future<void> init() async {
    if (_isInitialized) {
      throw Exception('DictationDeviceManager already initialized');
    }

    await HidApi.initialize();

    final infos = await HidApi.enumerate();
    await _createAndAddInitializedDevices(infos);

    _isInitialized = true;

    _updateRecoveryTimerState();

    // Emit initial device list
    _connectedDevicesSubject.add(_devices.values.toList());

    // Subscribe to device list stream for connect/disconnect detection
    _deviceListSubscription = HidApi.deviceListStream.listen(
      _onDeviceListUpdate,
    );
  }

  Future<void> shutdown() async {
    _failIfNotInitialized();
    _stopReconnectTimer();
    await _deviceListSubscription?.cancel();
    _deviceListSubscription = null;

    for (final device in _devices.values) {
      _unsubscribeFromDevice(device);
      await device.shutdown(closeDevice: true);
    }
    _devices.clear();
    for (final proxyDevice in _pendingProxyDevices.values) {
      await proxyDevice.shutdown(closeDevice: true);
    }
    _pendingProxyDevices.clear();
    _deviceButtonStates.clear();

    await _deviceConnectedController.close();
    await _deviceDisconnectedController.close();
    await _buttonStateChangedController.close();
    await _buttonChangeController.close();
    _connectedDevicesSubject.close();
    _exclusiveAccessSubject.close();

    await HidApi.shutdown();
    _isInitialized = false;
  }

  void addButtonEventListener(ButtonEventListener listener) {
    _buttonEventListeners.add(listener);
    for (final device in _devices.values) {
      device.addButtonEventListener(listener);
    }
  }

  void removeButtonEventListener(ButtonEventListener listener) {
    _buttonEventListeners.remove(listener);
    for (final device in _devices.values) {
      device.removeButtonEventListener(listener);
    }
  }

  void addDeviceConnectedEventListener(DeviceEventListener listener) {
    _deviceConnectEventListeners.add(listener);
  }

  void addDeviceDisconnectedEventListener(DeviceEventListener listener) {
    _deviceDisconnectEventListeners.add(listener);
  }

  void addMotionEventListener(MotionEventListener listener) {
    _motionEventListeners.add(listener);
    for (final device in _devices.values) {
      if (device is SpeechMikeHidDevice) {
        device.addMotionEventListener(listener);
      }
    }
  }

  void _failIfNotInitialized() {
    if (!_isInitialized) {
      throw Exception('DictationDeviceManager not yet initialized');
    }
  }

  void _startReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer.periodic(_reconnectInterval, (timer) async {
      if (!_isInitialized) {
        timer.cancel();
        return;
      }
      try {
        await recoverDevices();
      } catch (e) {
        // ignore: avoid_print
        print('Error in reconnect timer: $e');
      }
    });
  }

  void _stopReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  void _updateRecoveryTimerState() {
    final shouldRunTimer =
        aggressiveReconnection ||
        _devices.values.any((device) => device is SpeechMikeHidDevice);

    if (shouldRunTimer) {
      if (_reconnectTimer == null) {
        _startReconnectTimer();
      }
      return;
    }

    _stopReconnectTimer();
  }

  Future<void> _onDeviceListUpdate(List<HidDeviceInfo> currentInfos) async {
    final currentPaths = currentInfos.map((e) => e.path).toSet();

    // Check for disconnected devices
    final disconnectedPaths = _devices.keys
        .where((path) => !currentPaths.contains(path))
        .toList();
    for (final path in disconnectedPaths) {
      final device = _devices.remove(path)!;
      _unsubscribeFromDevice(device);
      _deviceButtonStates.remove(device.id);
      await device.shutdown(closeDevice: false);
      _notifyDeviceDisconnected(device);
    }

    // Also remove disconnected pending proxy devices
    final disconnectedProxyPaths = _pendingProxyDevices.keys
        .where((path) => !currentPaths.contains(path))
        .toList();
    for (final path in disconnectedProxyPaths) {
      final device = _pendingProxyDevices.remove(path)!;
      await device.shutdown(closeDevice: false);
    }

    // Check for new devices
    final newInfos = currentInfos
        .where(
          (info) =>
              !_devices.containsKey(info.path) &&
              !_pendingProxyDevices.containsKey(info.path),
        )
        .toList();
    if (newInfos.isNotEmpty) {
      final newDevices = await _createAndAddInitializedDevices(newInfos);
      for (final device in newDevices) {
        _notifyDeviceConnected(device);
      }
    }
  }

  void _notifyDeviceConnected(DictationDevice device) {
    _updateRecoveryTimerState();
    for (final listener in _deviceConnectEventListeners) {
      listener(device);
    }
    if (!_deviceConnectedController.isClosed) {
      _deviceConnectedController.add(device);
    }
    // Emit updated device list
    _connectedDevicesSubject.add(_devices.values.toList());
  }

  void _notifyDeviceDisconnected(DictationDevice device) {
    _updateRecoveryTimerState();
    for (final listener in _deviceDisconnectEventListeners) {
      listener(device);
    }
    if (!_deviceDisconnectedController.isClosed) {
      _deviceDisconnectedController.add(device);
    }
    // Emit updated device list
    _connectedDevicesSubject.add(_devices.values.toList());
  }

  /// Re-checks all managed devices and attempts to recover device ownership.
  ///
  /// This is useful when another application temporarily changed the device
  /// state or opened it with exclusive access and later released it.
  Future<void> recoverDevices() async {
    _failIfNotInitialized();

    if (_isRecoverySweepRunning || _isDeviceReloadRunning) {
      return;
    }

    _isRecoverySweepRunning = true;
    try {
      await _recoverManagedDevices();

      final infos = await HidApi.enumerate();
      final unmanagedInfos = infos
          .where(
            (info) =>
                !_devices.containsKey(info.path) &&
                !_pendingProxyDevices.containsKey(info.path),
          )
          .toList();

      if (unmanagedInfos.isNotEmpty) {
        final newDevices = await _createAndAddInitializedDevices(
          unmanagedInfos,
        );
        for (final device in newDevices) {
          _notifyDeviceConnected(device);
        }
      }
    } finally {
      _isRecoverySweepRunning = false;
    }
  }

  Future<List<DictationDevice>> _createAndAddInitializedDevices(
    List<HidDeviceInfo> infos,
  ) async {
    final List<DictationDevice> result = [];

    for (final info in infos) {
      if (_devices.containsKey(info.path)) continue;

      final implType = getImplType(info);
      if (implType == null) continue;

      try {
        final hidDevice = await _openHidDevice(info);
        final device = _createDevice(hidDevice, implType);

        if (device == null) continue;

        await device.init();

        if (device is SpeechMikeGamepadDevice) {
          _pendingProxyDevices[info.path] = device;
          continue;
        }

        _addListeners(device);
        _devices[info.path] = device;
        result.add(device);
      } catch (e) {
        // ignore: avoid_print
        print('Failed to initialize device at ${info.path}: $e');
      }
    }

    _assignPendingProxyDevices();

    return result;
  }

  Future<HidDevice> _openHidDevice(HidDeviceInfo info) async {
    if (!_exclusiveAccess) {
      return HidApi.open(info.path, exclusive: false);
    }

    try {
      return await HidApi.open(info.path, exclusive: true);
    } on HidExclusiveAccessException {
      // ignore: avoid_print
      print(
        'Exclusive access unavailable for ${info.path}, '
        'falling back to shared access',
      );
      return HidApi.open(info.path, exclusive: false);
    }
  }

  DictationDevice? _createDevice(
    HidDevice hidDevice,
    ImplementationType implType,
  ) {
    switch (implType) {
      case ImplementationType.speechMikeHid:
        return SpeechMikeHidDevice(hidDevice);
      case ImplementationType.powerMic3:
        return PowerMic3Device(hidDevice);
      case ImplementationType.speechMikeGamepad:
        return SpeechMikeGamepadDevice(hidDevice);
      case ImplementationType.footControl:
        return FootControlDevice(hidDevice);
    }
  }

  void _assignPendingProxyDevices() {
    final List<String> assignedPaths = [];

    for (final entry in _pendingProxyDevices.entries) {
      final proxyPath = entry.key;
      final proxyDevice = entry.value;

      for (final hostDevice in _devices.values) {
        if (hostDevice is! SpeechMikeHidDevice) continue;

        if (proxyDevice.hidDevice.info.vendorId ==
                hostDevice.hidDevice.info.vendorId &&
            proxyDevice.hidDevice.info.productId ==
                hostDevice.hidDevice.info.productId) {
          hostDevice.assignProxyDevice(proxyDevice);
          assignedPaths.add(proxyPath);
          break;
        }
      }
    }

    for (final path in assignedPaths) {
      _pendingProxyDevices.remove(path);
    }
  }

  void _addListeners(DictationDevice device) {
    for (final listener in _buttonEventListeners) {
      device.addButtonEventListener(listener);
    }

    if (device is SpeechMikeHidDevice) {
      for (final listener in _motionEventListeners) {
        device.addMotionEventListener(listener);
      }
    }

    // Subscribe to button state changes
    _stateSubscriptions[device.id] = device.onButtonStateChanged.listen((
      state,
    ) {
      _deviceButtonStates[device.id] = state;
      if (!_buttonStateChangedController.isClosed) {
        _buttonStateChangedController.add((device, state));
      }
    });

    // Subscribe to individual button changes
    _changeSubscriptions[device.id] = device.onButtonChange.listen((change) {
      if (!_buttonChangeController.isClosed) {
        _buttonChangeController.add((device, change));
      }
    });

    // Subscribe to connection lost
    // We don't track subscription here because we handle it via shutdown/unsubscribe
    // But we need to make sure we cancel it.
    // Actually _unsubscribeFromDevice needs to handle it if we store it.
    // Or we can just let it be cancelled when device shuts down?
    // No, we need to listen.
    // Let's add it to a new subscription map?
    // Or just treat it as a special case.
    // Better to just listen and not store connection if we are sure it cleans up?
    // DictationDevice.shutdown closes the controller, so the stream will close.
    // But we want to react to the event.

    device.onConnectionLost.listen((_) {
      // Handle connection lost
      // ignore: avoid_print
      print('Connection lost for device ${device.id}, cleaning up...');
      _handleDeviceConnectionLost(device);
    });

    // Initialize the device's button state
    _deviceButtonStates[device.id] = device.currentButtonStates;
  }

  Future<void> _handleDeviceConnectionLost(DictationDevice device) async {
    String? pathToRemove;
    for (final entry in _devices.entries) {
      if (entry.value == device) {
        pathToRemove = entry.key;
        break;
      }
    }

    if (pathToRemove == null) {
      return;
    }
    await _removeManagedDeviceByPath(
      pathToRemove,
      closeDevice: true,
      notify: true,
    );
  }

  void _unsubscribeFromDevice(DictationDevice device) {
    _stateSubscriptions[device.id]?.cancel();
    _stateSubscriptions.remove(device.id);
    _changeSubscriptions[device.id]?.cancel();
    _changeSubscriptions.remove(device.id);
  }

  Future<void> _recoverManagedDevices() async {
    final deviceEntries = _devices.entries.toList(growable: false);

    for (final entry in deviceEntries) {
      final path = entry.key;
      final device = entry.value;

      if (!identical(_devices[path], device)) {
        continue;
      }

      try {
        await device.recoverConnection();
      } catch (e) {
        // ignore: avoid_print
        print('Failed to recover device at $path: $e');
        await _handleDeviceConnectionLost(device);
      }
    }
  }

  Future<void> _reloadManagedDevices() async {
    _isDeviceReloadRunning = true;
    try {
      final paths = _devices.keys.toList(growable: false);
      for (final path in paths) {
        await _removeManagedDeviceByPath(path, closeDevice: true, notify: true);
      }

      final pendingProxyDevices = _pendingProxyDevices.values.toList(
        growable: false,
      );
      _pendingProxyDevices.clear();
      for (final proxyDevice in pendingProxyDevices) {
        await proxyDevice.shutdown(closeDevice: true);
      }

      final infos = await HidApi.enumerate();
      final newDevices = await _createAndAddInitializedDevices(infos);
      for (final device in newDevices) {
        _notifyDeviceConnected(device);
      }
    } finally {
      _isDeviceReloadRunning = false;
    }
  }

  Future<void> _removeManagedDeviceByPath(
    String path, {
    required bool closeDevice,
    required bool notify,
  }) async {
    final removedDevice = _devices.remove(path);
    if (removedDevice == null) {
      return;
    }

    _unsubscribeFromDevice(removedDevice);
    _deviceButtonStates.remove(removedDevice.id);
    await removedDevice.shutdown(closeDevice: closeDevice);

    if (notify) {
      _notifyDeviceDisconnected(removedDevice);
    }
  }
}
