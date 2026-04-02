import 'dart:async';

import 'package:hid_device_manager/hid_device_manager.dart';
import 'package:hippo_utils/hippo_utils.dart';

import 'devices/speechmike_gamepad_device.dart';
import 'devices/speechmike_hid_device.dart';
import 'dictation_device.dart';
import 'enums.dart';
import 'utils.dart';

typedef DeviceEventListener = void Function(DictationDevice device);

class DictationDeviceManager {
  DictationDeviceManager({
    this.aggressiveReconnection = false,
    HidOpenMode openMode = HidOpenMode.preferExclusive,
  }) : _openMode = openMode,
       _openModeSubject = DataSubject<HidOpenMode>.seeded(openMode),
       _hidManager = HidDeviceManager(
         definitions: buildDictationDeviceDefinitions(openMode: openMode),
       );

  final bool aggressiveReconnection;
  HidOpenMode _openMode;

  final HidDeviceManager _hidManager;

  final Set<ButtonEventListener> _buttonEventListeners = {};
  final Set<DeviceEventListener> _deviceConnectEventListeners = {};
  final Set<DeviceEventListener> _deviceDisconnectEventListeners = {};
  final Set<MotionEventListener> _motionEventListeners = {};

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
  final DataSubject<HidOpenMode> _openModeSubject;

  final Map<int, ButtonStates> _deviceButtonStates = {};
  final Map<int, DictationDevice> _subscribedDevices = {};
  final Map<int, StreamSubscription<ButtonStates>> _stateSubscriptions = {};
  final Map<int, StreamSubscription<ButtonChange>> _changeSubscriptions = {};

  bool _isInitialized = false;
  Timer? _reconnectTimer;
  List<DictationDevice> _visibleDevices = const [];

  StreamSubscription<HidManagedDevice>? _deviceAddedSubscription;
  StreamSubscription<List<HidManagedDevice>>?
  _connectedManagedDevicesSubscription;

  static const Duration _reconnectInterval = Duration(seconds: 3);

  Stream<DictationDevice> get deviceConnectedStream =>
      _deviceConnectedController.stream;
  Stream<DictationDevice> get deviceDisconnectedStream =>
      _deviceDisconnectedController.stream;
  Stream<(DictationDevice, ButtonStates)> get onButtonStateChanged =>
      _buttonStateChangedController.stream;
  Stream<(DictationDevice, ButtonChange)> get onButtonChange =>
      _buttonChangeController.stream;

  DataSubject<List<DictationDevice>> get connectedDevicesSubject =>
      _connectedDevicesSubject;
  DataSubject<HidOpenMode> get openModeSubject => _openModeSubject;

  Stream<List<DictationDevice>> get connectedDevicesStream =>
      _connectedDevicesSubject.stream;
  Stream<HidOpenMode> get openModeStream => _openModeSubject.stream;

  HidDeviceManager get hidManager => _hidManager;

  Map<int, ButtonStates> get allButtonStates =>
      Map.unmodifiable(_deviceButtonStates);

  HidOpenMode get openMode => _openMode;

  Future<void> init() async {
    if (_isInitialized) {
      throw Exception('DictationDeviceManager already initialized');
    }

    _deviceAddedSubscription = _hidManager.deviceAddedStream.listen(
      _onManagedDeviceAdded,
    );
    _connectedManagedDevicesSubscription = _hidManager.connectedDevicesSubject
        .listen((_) {
          _refreshVisibleDevices();
        });

    await _hidManager.init();
    _isInitialized = true;
    _refreshVisibleDevices();
    _updateRecoveryTimerState();
  }

  Future<void> shutdown() async {
    if (!_isInitialized) {
      return;
    }

    _stopReconnectTimer();
    await _deviceAddedSubscription?.cancel();
    await _connectedManagedDevicesSubscription?.cancel();

    for (final subscription in _stateSubscriptions.values) {
      await subscription.cancel();
    }
    _stateSubscriptions.clear();

    for (final subscription in _changeSubscriptions.values) {
      await subscription.cancel();
    }
    _changeSubscriptions.clear();
    _subscribedDevices.clear();
    _deviceButtonStates.clear();
    _visibleDevices = const [];

    await _hidManager.shutdown();

    await _deviceConnectedController.close();
    await _deviceDisconnectedController.close();
    await _buttonStateChangedController.close();
    await _buttonChangeController.close();
    _connectedDevicesSubject.close();
    _openModeSubject.close();

    _isInitialized = false;
  }

  List<DictationDevice> getDevices() {
    _failIfNotInitialized();
    return List.unmodifiable(_visibleDevices);
  }

  Future<void> setOpenMode(HidOpenMode openMode) async {
    if (_openMode == openMode) {
      return;
    }

    _openMode = openMode;
    _openModeSubject.add(openMode);

    for (final device in _hidManager.devices) {
      await device.setOpenMode(openMode);
    }
  }

  void addButtonEventListener(ButtonEventListener listener) {
    _buttonEventListeners.add(listener);
    for (final device in _subscribedDevices.values) {
      device.addButtonEventListener(listener);
    }
  }

  void removeButtonEventListener(ButtonEventListener listener) {
    _buttonEventListeners.remove(listener);
    for (final device in _subscribedDevices.values) {
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
    for (final device in _subscribedDevices.values) {
      if (device is SpeechMikeHidDevice) {
        device.addMotionEventListener(listener);
      }
    }
  }

  Future<void> recoverDevices() async {
    _failIfNotInitialized();

    for (final device in _visibleDevices) {
      try {
        await device.recoverConnection();
      } catch (error) {
        // ignore: avoid_print
        print('Failed to recover ${device.getDeviceType().name}: $error');
        await device.managedDevice.reconnect();
      }
    }

    await _hidManager.reload();
  }

  void _onManagedDeviceAdded(HidManagedDevice managedDevice) {
    unawaited(managedDevice.setOpenMode(_openMode));

    final controller = managedDevice.controllerAs<DictationDevice>();
    if (controller == null || controller is SpeechMikeGamepadDevice) {
      return;
    }

    _subscribeToDevice(controller);
  }

  void _subscribeToDevice(DictationDevice device) {
    if (_subscribedDevices.containsKey(device.id)) {
      return;
    }

    _subscribedDevices[device.id] = device;

    for (final listener in _buttonEventListeners) {
      device.addButtonEventListener(listener);
    }

    if (device is SpeechMikeHidDevice) {
      for (final listener in _motionEventListeners) {
        device.addMotionEventListener(listener);
      }
    }

    _stateSubscriptions[device.id] = device.onButtonStateChanged.listen((
      state,
    ) {
      _deviceButtonStates[device.id] = state;
      if (!_buttonStateChangedController.isClosed) {
        _buttonStateChangedController.add((device, state));
      }
    });

    _changeSubscriptions[device.id] = device.onButtonChange.listen((change) {
      if (!_buttonChangeController.isClosed) {
        _buttonChangeController.add((device, change));
      }
    });

    _deviceButtonStates[device.id] = device.currentButtonStates;
  }

  void _refreshVisibleDevices() {
    final connectedControllers = _hidManager.connectedDevicesSubject.value
        .map((managedDevice) => managedDevice.controllerAs<DictationDevice>())
        .whereType<DictationDevice>()
        .toList(growable: false);

    _assignProxyDevices(connectedControllers);

    final visibleDevices = connectedControllers
        .where((device) => device is! SpeechMikeGamepadDevice)
        .toList(growable: false);

    for (final device in visibleDevices) {
      _subscribeToDevice(device);
    }

    final previousVisibleById = {
      for (final device in _visibleDevices) device.id: device,
    };
    final nextVisibleById = {
      for (final device in visibleDevices) device.id: device,
    };

    for (final device in visibleDevices) {
      if (!previousVisibleById.containsKey(device.id)) {
        _notifyDeviceConnected(device);
      }
    }

    for (final device in _visibleDevices) {
      if (!nextVisibleById.containsKey(device.id)) {
        _deviceButtonStates.remove(device.id);
        _notifyDeviceDisconnected(device);
      }
    }

    _visibleDevices = List.unmodifiable(visibleDevices);
    _connectedDevicesSubject.add(_visibleDevices);
    _updateRecoveryTimerState();
  }

  void _assignProxyDevices(List<DictationDevice> connectedControllers) {
    final hosts = connectedControllers.whereType<SpeechMikeHidDevice>().toList(
      growable: false,
    );
    final proxies = connectedControllers
        .whereType<SpeechMikeGamepadDevice>()
        .toList(growable: false);

    for (final proxy in proxies) {
      for (final host in hosts) {
        if (proxy.info.vendorId == host.info.vendorId &&
            proxy.info.productId == host.info.productId) {
          host.assignProxyDevice(proxy);
          break;
        }
      }
    }
  }

  void _notifyDeviceConnected(DictationDevice device) {
    for (final listener in _deviceConnectEventListeners) {
      listener(device);
    }
    if (!_deviceConnectedController.isClosed) {
      _deviceConnectedController.add(device);
    }
  }

  void _notifyDeviceDisconnected(DictationDevice device) {
    for (final listener in _deviceDisconnectEventListeners) {
      listener(device);
    }
    if (!_deviceDisconnectedController.isClosed) {
      _deviceDisconnectedController.add(device);
    }
  }

  void _failIfNotInitialized() {
    if (!_isInitialized) {
      throw Exception('DictationDeviceManager not yet initialized');
    }
  }

  void _startReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer.periodic(_reconnectInterval, (_) async {
      if (!_isInitialized) {
        return;
      }
      try {
        await recoverDevices();
      } catch (error) {
        // ignore: avoid_print
        print('Error in dictation recovery timer: $error');
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
        _visibleDevices.any((device) => device is SpeechMikeHidDevice);

    if (shouldRunTimer) {
      if (_reconnectTimer == null) {
        _startReconnectTimer();
      }
      return;
    }

    _stopReconnectTimer();
  }
}
