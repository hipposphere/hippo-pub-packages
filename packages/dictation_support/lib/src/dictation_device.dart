import 'dart:async';
import 'dart:typed_data';
import 'package:hid_api/hid_api.dart';
import 'package:hippo_utils/hippo_utils.dart';
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
  final DataSubject<int> _buttonEventSubject = DataSubject<int>.seeded(0);
  final DataSubject<ButtonStates> _buttonStateChangedSubject =
      DataSubject<ButtonStates>.seeded(ButtonStates(0));
  final StreamController<ButtonChange> _buttonChangeController =
      StreamController<ButtonChange>.broadcast();

  final StreamController<void> _connectionLostController =
      StreamController<void>.broadcast();

  DictationDevice(this.hidDevice);

  /// Stream of button event bitmasks
  Stream<int> get buttonEvents => _buttonEventSubject.stream;

  /// Subject of button event bitmasks
  DataSubject<int> get buttonEventsSubject => _buttonEventSubject;

  /// Stream of button state changes
  Stream<ButtonStates> get onButtonStateChanged =>
      _buttonStateChangedSubject.stream;

  /// Subject of button state changes
  DataSubject<ButtonStates> get buttonStateSubject =>
      _buttonStateChangedSubject;

  /// Stream of individual button changes
  ///
  /// Emits a [ButtonChange] event for each button that is pressed or released.
  /// This allows you to see exactly which button changed and whether it was
  /// pressed or released.
  Stream<ButtonChange> get onButtonChange => _buttonChangeController.stream;

  /// Stream that emits when the connection to the device is lost/error occurs
  Stream<void> get onConnectionLost => _connectionLostController.stream;

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
    _buttonEventSubject.close();
    _buttonStateChangedSubject.close();
    await _buttonChangeController.close();
    await _connectionLostController.close();
  }

  void addButtonEventListener(ButtonEventListener listener) {
    _buttonEventListeners.add(listener);
  }

  void removeButtonEventListener(ButtonEventListener listener) {
    _buttonEventListeners.remove(listener);
  }

  void notifyButtonListeners(int outputBitMask) {
    if (outputBitMask == _lastBitMask) return;

    // Detect individual button changes by comparing with previous state
    final changedBits = _lastBitMask ^ outputBitMask;
    final newState = ButtonStates(outputBitMask);

    // Emit individual button change events
    if (changedBits != 0 && !_buttonChangeController.isClosed) {
      // Check each button bit to see if it changed
      for (int i = 0; i < 32; i++) {
        final buttonMask = 1 << i;
        if ((changedBits & buttonMask) != 0) {
          final isPressed = (outputBitMask & buttonMask) != 0;
          _buttonChangeController.add(
            ButtonChange(
              buttonMask: buttonMask,
              isPressed: isPressed,
              currentState: newState,
            ),
          );
        }
      }
    }

    // Emit overall button state change
    _buttonStateChangedSubject.add(newState);

    // Legacy listeners and stream (for backward compatibility)
    for (final listener in _buttonEventListeners) {
      listener(this, outputBitMask);
    }
    _buttonEventSubject.add(outputBitMask);

    // Update last bitmask after all notifications
    _lastBitMask = outputBitMask;
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
          if (!_connectionLostController.isClosed) {
            _connectionLostController.add(null);
          }
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

    outputBitMask = filterOutputBitMask(outputBitMask);

    notifyButtonListeners(outputBitMask);
  }

  int filterOutputBitMask(int outputBitMask) {
    return outputBitMask;
  }

  /// Get the current button state bitmask
  int get currentButtonState => _lastBitMask;

  /// Get the current button states as a [ButtonStates] object
  ButtonStates get currentButtonStates => ButtonStates(_lastBitMask);

  DeviceType getDeviceType();
  Map<int, int> getButtonMappings();
  int getInputBitmask(ByteData data);
}
