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
  Timer? _pollTimer;

  DictationDeviceManager();

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

    // Start polling for connection changes
    _pollTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _pollDevices(),
    );
  }

  Future<void> shutdown() async {
    _failIfNotInitialized();
    _pollTimer?.cancel();

    for (final device in _devices.values) {
      await device.shutdown(closeDevice: true);
    }
    _devices.clear();
    _pendingProxyDevices.clear();

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

  Future<void> _pollDevices() async {
    final currentInfos = await HidApi.enumerate();
    final currentPaths = currentInfos.map((e) => e.path).toSet();

    // Check for disconnected devices
    final disconnectedPaths = _devices.keys
        .where((path) => !currentPaths.contains(path))
        .toList();
    for (final path in disconnectedPaths) {
      final device = _devices.remove(path)!;
      await device.shutdown(closeDevice: false);
      for (final listener in _deviceDisconnectEventListeners) {
        listener(device);
      }
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
        for (final listener in _deviceConnectEventListeners) {
          listener(device);
        }
      }
    }
  }
}
