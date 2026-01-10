import 'dart:async';
import 'package:hid_api/hid_api.dart';
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

  DictationDeviceManager();

  /// Stream of newly connected dictation devices
  Stream<DictationDevice> get deviceConnectedStream =>
      _deviceConnectedController.stream;

  /// Stream of disconnected dictation devices
  Stream<DictationDevice> get deviceDisconnectedStream =>
      _deviceDisconnectedController.stream;

  List<DictationDevice> getDevices() {
    _failIfNotInitialized();
    return _devices.values.toList();
  }

  Future<void> init() async {
    if (_isInitialized) {
      throw Exception('DictationDeviceManager already initialized');
    }

    await HidApi.initialize();

    final infos = await HidApi.enumerate();
    await _createAndAddInitializedDevices(infos);

    _isInitialized = true;

    // Subscribe to device list stream for connect/disconnect detection
    _deviceListSubscription = HidApi.deviceListStream.listen(
      _onDeviceListUpdate,
    );
  }

  Future<void> shutdown() async {
    _failIfNotInitialized();
    await _deviceListSubscription?.cancel();
    _deviceListSubscription = null;

    for (final device in _devices.values) {
      await device.shutdown(closeDevice: true);
    }
    _devices.clear();
    _pendingProxyDevices.clear();

    await _deviceConnectedController.close();
    await _deviceDisconnectedController.close();

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

  Future<void> _onDeviceListUpdate(List<HidDeviceInfo> currentInfos) async {
    final currentPaths = currentInfos.map((e) => e.path).toSet();

    // Check for disconnected devices
    final disconnectedPaths = _devices.keys
        .where((path) => !currentPaths.contains(path))
        .toList();
    for (final path in disconnectedPaths) {
      final device = _devices.remove(path)!;
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

  Future<List<DictationDevice>> _createAndAddInitializedDevices(
    List<HidDeviceInfo> infos,
  ) async {
    final List<DictationDevice> result = [];

    for (final info in infos) {
      if (_devices.containsKey(info.path)) continue;

      final implType = getImplType(info);
      if (implType == null) continue;

      try {
        final hidDevice = await HidApi.open(info.path);
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
  }
}
