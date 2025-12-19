import 'dart:async';
import 'dart:typed_data';
import 'package:hid_api/hid_api.dart';
import 'enums.dart';

typedef ButtonEventListener =
    void Function(DictationDevice device, int bitMask);
typedef MotionEventListener =
    void Function(DictationDevice device, MotionEvent event);

abstract class DictationDevice {
  static int _nextId = 0;

  final int id = _nextId++;
  final HidDevice hidDevice;

  ImplementationType get implType;

  final Set<ButtonEventListener> _buttonEventListeners = {};
  int _lastBitMask = 0;
  bool _isShuttingDown = false;

  DictationDevice(this.hidDevice);

  Future<void> init() async {
    _startReading();
  }

  Future<void> shutdown({bool closeDevice = true}) async {
    _isShuttingDown = true;
    if (closeDevice) {
      await hidDevice.close();
    }
    _buttonEventListeners.clear();
  }

  void addButtonEventListener(ButtonEventListener listener) {
    _buttonEventListeners.add(listener);
  }

  void removeButtonEventListener(ButtonEventListener listener) {
    _buttonEventListeners.remove(listener);
  }

  void notifyButtonListeners(int outputBitMask) {
    for (final listener in _buttonEventListeners) {
      listener(this, outputBitMask);
    }
  }

  void _startReading() async {
    while (!_isShuttingDown && hidDevice.isOpen) {
      try {
        final report = await hidDevice.read(
          timeout: const Duration(milliseconds: 100),
        );
        if (report.data.isNotEmpty) {
          await _onInputReport(report);
        }
      } on HidTimeoutException {
        // Continue reading
      } catch (e) {
        if (!_isShuttingDown) {
          // ignore: avoid_print
          print('Error reading from device: $e');
        }
        break;
      }
    }
  }

  Future<void> _onInputReport(HidInputReport report) async {
    final data = ByteData.sublistView(report.data);
    await handleInputReport(report.reportId, data);
  }

  Future<void> handleInputReport(int reportId, ByteData data) async {
    await handleButtonPress(data);
  }

  Future<void> handleButtonPress(ByteData data) async {
    final buttonMappings = getButtonMappings();
    final inputBitMask = getInputBitmask(data);
    int outputBitMask = 0;

    for (final entry in buttonMappings.entries) {
      if ((inputBitMask & entry.value) != 0) {
        outputBitMask |= entry.key;
      }
    }

    if (outputBitMask == _lastBitMask) return;
    _lastBitMask = outputBitMask;

    outputBitMask = filterOutputBitMask(outputBitMask);

    notifyButtonListeners(outputBitMask);
  }

  int filterOutputBitMask(int outputBitMask) {
    return outputBitMask;
  }

  DeviceType getDeviceType();
  Map<int, int> getButtonMappings();
  int getInputBitmask(ByteData data);
}
