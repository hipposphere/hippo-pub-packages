import 'dart:async';
import 'dart:typed_data';

import 'package:hid_device_manager/hid_device_manager.dart';
import 'package:hippo_core/hippo_core.dart';

import 'enums.dart';

typedef ButtonEventListener =
    void Function(DictationDevice device, int bitMask);
typedef MotionEventListener =
    void Function(DictationDevice device, MotionEvent event);

abstract class DictationDevice extends HidDeviceController {
  DictationDevice(super.managedDevice);

  static int _nextId = 0;

  final int id = _nextId++;

  static const Duration defaultDeduplicationInterval = Duration(
    milliseconds: 50,
  );

  ImplementationType get implType;

  final Set<ButtonEventListener> _buttonEventListeners = {};
  int _lastBitMask = 0;

  StreamSubscription<HidReport>? _reportSubscription;
  final DataSubject<int> _buttonEventSubject = DataSubject<int>.seeded(0);
  final DataSubject<ButtonStates> _buttonStateChangedSubject =
      DataSubject<ButtonStates>.seeded(ButtonStates(0));
  final StreamController<ButtonChange> _buttonChangeController =
      StreamController<ButtonChange>.broadcast();

  Stream<int> get buttonEvents => _buttonEventSubject.stream;
  DataSubject<int> get buttonEventsSubject => _buttonEventSubject;

  Stream<ButtonStates> get onButtonStateChanged =>
      _buttonStateChangedSubject.stream;
  DataSubject<ButtonStates> get buttonStateSubject =>
      _buttonStateChangedSubject;

  Stream<ButtonChange> get onButtonChange => _buttonChangeController.stream;

  @override
  Future<void> onAttached() async {
    _reportSubscription =
        deduplicatedInputReports(
          deduplicationInterval: defaultDeduplicationInterval,
        ).listen(
          (report) async {
            if (report.normalizedData.isNotEmpty) {
              await handleInputReport(
                report.reportId,
                ByteData.sublistView(report.normalizedData),
              );
            }
          },
          onError: (_) {},
          cancelOnError: false,
        );
  }

  @override
  Future<void> recoverConnection() async {
    await super.recoverConnection();
  }

  @override
  Future<void> dispose() async {
    await _reportSubscription?.cancel();
    _buttonEventListeners.clear();
    _buttonEventSubject.close();
    _buttonStateChangedSubject.close();
    await _buttonChangeController.close();
  }

  void addButtonEventListener(ButtonEventListener listener) {
    _buttonEventListeners.add(listener);
  }

  void removeButtonEventListener(ButtonEventListener listener) {
    _buttonEventListeners.remove(listener);
  }

  void notifyButtonListeners(int outputBitMask) {
    if (outputBitMask == _lastBitMask) return;

    final changedBits = _lastBitMask ^ outputBitMask;
    final newState = ButtonStates(outputBitMask);

    if (changedBits != 0 && !_buttonChangeController.isClosed) {
      for (int i = 0; i < 32; i++) {
        final buttonMask = 1 << i;
        if ((changedBits & buttonMask) != 0) {
          _buttonChangeController.add(
            ButtonChange(
              buttonMask: buttonMask,
              isPressed: (outputBitMask & buttonMask) != 0,
              currentState: newState,
            ),
          );
        }
      }
    }

    _buttonStateChangedSubject.add(newState);

    for (final listener in _buttonEventListeners) {
      listener(this, outputBitMask);
    }
    _buttonEventSubject.add(outputBitMask);

    _lastBitMask = outputBitMask;
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

    notifyButtonListeners(filterOutputBitMask(outputBitMask));
  }

  int filterOutputBitMask(int outputBitMask) => outputBitMask;

  int get currentButtonState => _lastBitMask;
  ButtonStates get currentButtonStates => ButtonStates(_lastBitMask);

  DeviceType getDeviceType();
  Map<int, int> getButtonMappings();
  int getInputBitmask(ByteData data);
}
