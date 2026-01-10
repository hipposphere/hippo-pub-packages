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

  /// Deduplication interval for input reports (default: 50ms)
  static const Duration defaultDeduplicationInterval = Duration(
    milliseconds: 50,
  );

  ImplementationType get implType;

  final Set<ButtonEventListener> _buttonEventListeners = {};
  int _lastBitMask = 0;
  bool _isShuttingDown = false;

  StreamSubscription<HidReport>? _reportSubscription;
  final StreamController<int> _buttonEventController =
      StreamController<int>.broadcast();

  DictationDevice(this.hidDevice);

  /// Stream of button event bitmasks
  ///
  /// Emits whenever the button state changes. The bitmask contains
  /// flags from [ButtonEvent] indicating which buttons are pressed.
  Stream<int> get buttonEvents => _buttonEventController.stream;

  Future<void> init() async {
    _startReading();
  }

  Future<void> shutdown({bool closeDevice = true}) async {
    _isShuttingDown = true;
    await _reportSubscription?.cancel();
    _reportSubscription = null;
    if (closeDevice) {
      await hidDevice.close();
    }
    _buttonEventListeners.clear();
    await _buttonEventController.close();
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
    // Also emit on the stream
    if (!_buttonEventController.isClosed) {
      _buttonEventController.add(outputBitMask);
    }
  }

  void _startReading() {
    // Use deduplicated reports stream with 50ms interval
    final reportStream = hidDevice.deduplicatedReports(
      deduplicationInterval: defaultDeduplicationInterval,
    );

    _reportSubscription = reportStream.listen(
      (report) async {
        if (report.normalizedData.isNotEmpty) {
          await _onInputReport(report);
        }
      },
      onError: (e) {
        if (!_isShuttingDown) {
          // ignore: avoid_print
          print('Error reading from device: $e');
        }
      },
      cancelOnError: false,
    );

    // Handle device disconnection
    hidDevice.onDisconnected.listen((_) {
      if (!_isShuttingDown) {
        shutdown(closeDevice: false);
      }
    });
  }

  Future<void> _onInputReport(HidReport report) async {
    final data = ByteData.sublistView(report.normalizedData);
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

  /// Get the current button state bitmask
  int get currentButtonState => _lastBitMask;

  DeviceType getDeviceType();
  Map<int, int> getButtonMappings();
  int getInputBitmask(ByteData data);
}
