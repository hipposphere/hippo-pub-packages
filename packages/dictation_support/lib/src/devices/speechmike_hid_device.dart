import 'dart:async';
import 'dart:typed_data';
import 'dart:math';
import 'package:hid_api/hid_api.dart';
import '../dictation_device.dart';
import '../enums.dart';
import 'speechmike_gamepad_device.dart';

enum _Command {
  setLed(0x02),
  setEventMode(0x0d),
  buttonPressEvent(0x80),
  isSpeechMikePremium(0x83),
  getDeviceCodeSm3(0x87),
  getDeviceCodeSmp(0x8b),
  getDeviceCodeSo(0x96),
  getEventMode(0x8d),
  wirelessStatusEvent(0x94),
  motionEvent(0x9e),
  getFirmwareVersion(0x91);

  final int value;
  const _Command(this.value);

  static _Command? fromValue(int value) {
    for (final cmd in _Command.values) {
      if (cmd.value == value) return cmd;
    }
    return null;
  }
}

class SpeechMikeHidDevice extends DictationDevice {
  @override
  ImplementationType get implType => ImplementationType.speechMikeHid;

  int _deviceCode = 0;
  final Map<LedIndex, LedMode> _ledState = {};
  int _sliderBitsFilter = 0;
  int _lastSliderValue = 0;
  int _lastButtonValue = 0;

  final Map<int, Completer<ByteData>> _commandResolvers = {};
  final Map<int, Timer> _commandTimeouts = {};

  final Set<MotionEventListener> _motionEventListeners = {};

  SpeechMikeGamepadDevice? _proxyDevice;

  static const int _commandTimeoutMs = 5000;

  static const Map<int, int> _buttonMappingsSpeechMike = {
    ButtonEvent.rewind: 1 << 12,
    ButtonEvent.play: 1 << 10,
    ButtonEvent.forward: 1 << 11,
    ButtonEvent.insOvr: 1 << 14,
    ButtonEvent.record: 1 << 8,
    ButtonEvent.command: 1 << 5,
    ButtonEvent.stop: 1 << 9,
    ButtonEvent.instr: 1 << 15,
    ButtonEvent.f1A: 1 << 1,
    ButtonEvent.f2B: 1 << 2,
    ButtonEvent.f3C: 1 << 3,
    ButtonEvent.f4D: 1 << 4,
    ButtonEvent.eolPrio: 1 << 13,
    ButtonEvent.scanEnd: 1 << 0,
    ButtonEvent.scanSuccess: 1 << 7,
  };

  static const Map<int, int> _buttonMappingsPowerMic4 = {
    ButtonEvent.tabBackward: 1 << 12,
    ButtonEvent.play: 1 << 10,
    ButtonEvent.tabForward: 1 << 11,
    ButtonEvent.forward: 1 << 14,
    ButtonEvent.record: 1 << 8,
    ButtonEvent.command: 1 << 5,
    ButtonEvent.enterSelect: 1 << 15,
    ButtonEvent.f1A: 1 << 1,
    ButtonEvent.f2B: 1 << 2,
    ButtonEvent.f3C: 1 << 3,
    ButtonEvent.f4D: 1 << 4,
    ButtonEvent.rewind: 1 << 13,
  };

  static const List<DeviceType> _phiSliders = [
    DeviceType.speechMikeLfh3220,
    DeviceType.speechMikeLfh3520,
    DeviceType.speechMikeSmp3720,
  ];

  static const List<DeviceType> _intSliders = [
    DeviceType.speechMikeLfh3210,
    DeviceType.speechMikeLfh3310,
    DeviceType.speechMikeLfh3510,
    DeviceType.speechMikeLfh3610,
    DeviceType.speechMikeSmp3710,
    DeviceType.speechMikeSmp3810,
    DeviceType.speechMikeSmp4010,
  ];

  SpeechMikeHidDevice(super.hidDevice) {
    for (final index in LedIndex.values) {
      _ledState[index] = LedMode.off;
    }
  }

  @override
  Future<void> init() async {
    await super.init();
    await _fetchDeviceCode();
    _determineSliderBitsFilter();
  }

  @override
  Future<void> shutdown({bool closeDevice = true}) async {
    await super.shutdown(closeDevice: closeDevice);
    if (_proxyDevice != null) {
      await _proxyDevice!.shutdown();
    }
  }

  void addMotionEventListener(MotionEventListener listener) {
    _motionEventListeners.add(listener);
  }

  int getDeviceCode() => _deviceCode;

  @override
  DeviceType getDeviceType() {
    if (hidDevice.info.vendorId == 0x0554) {
      if (hidDevice.info.productId == 0x0064) {
        return DeviceType.powerMic4;
      }
      return DeviceType.unknown;
    } else if (hidDevice.info.vendorId == 0x0911) {
      return DeviceType.fromValue(_deviceCode);
    }
    return DeviceType.unknown;
  }

  Future<void> setSimpleLedState(SimpleLedState simpleLedState) async {
    _applySimpleLedState(simpleLedState);
    await _sendLedState();
  }

  void _applySimpleLedState(SimpleLedState state) {
    // Reset all
    for (final index in LedIndex.values) {
      _ledState[index] = LedMode.off;
    }

    switch (state) {
      case SimpleLedState.off:
        break;
      case SimpleLedState.recordInsert:
        _ledState[LedIndex.recordLedGreen] = LedMode.on;
        _ledState[LedIndex.insOwrButtonLedGreen] = LedMode.on;
        break;
      case SimpleLedState.recordOverwrite:
        _ledState[LedIndex.recordLedRed] = LedMode.on;
        break;
      case SimpleLedState.recordStandbyInsert:
        _ledState[LedIndex.recordLedGreen] = LedMode.blinkSlow;
        _ledState[LedIndex.insOwrButtonLedGreen] = LedMode.blinkSlow;
        break;
      case SimpleLedState.recordStandbyOverwrite:
        _ledState[LedIndex.recordLedRed] = LedMode.blinkSlow;
        break;
    }
  }

  Future<void> setLed(LedIndex index, LedMode mode) async {
    _ledState[index] = mode;
    await _sendLedState();
  }

  Future<void> _sendLedState() async {
    final input = Uint8List(8);

    input[4] |= _ledState[LedIndex.recordLedGreen]!.value << 0;
    input[4] |= _ledState[LedIndex.recordLedRed]!.value << 2;
    input[4] |= _ledState[LedIndex.instructionLedGreen]!.value << 4;
    input[4] |= _ledState[LedIndex.instructionLedRed]!.value << 6;

    input[5] |= _ledState[LedIndex.insOwrButtonLedGreen]!.value << 4;
    input[5] |= _ledState[LedIndex.insOwrButtonLedRed]!.value << 6;

    input[6] |= _ledState[LedIndex.f4ButtonLed]!.value << 0;
    input[6] |= _ledState[LedIndex.f3ButtonLed]!.value << 2;
    input[6] |= _ledState[LedIndex.f2ButtonLed]!.value << 4;
    input[6] |= _ledState[LedIndex.f1ButtonLed]!.value << 6;

    await _sendCommand(_Command.setLed, input);
  }

  void assignProxyDevice(SpeechMikeGamepadDevice proxyDevice) {
    if (_proxyDevice != null) {
      throw Exception(
        'Proxy device already assigned. Adding multiple SpeechMikes in Browser/Gamepad mode at the same time is not supported.',
      );
    }
    _proxyDevice = proxyDevice;
    _proxyDevice!.addButtonEventListener(
      (device, bitMask) => _onProxyButtonEvent(bitMask),
    );
  }

  void _onProxyButtonEvent(int bitMask) {
    notifyButtonListeners(bitMask);
  }

  Future<void> _handleCommandResponse(int commandValue, ByteData data) async {
    final completer = _commandResolvers.remove(commandValue);
    if (completer == null) {
      return; // Or throw? The TS version throws.
    }
    _commandTimeouts.remove(commandValue)?.cancel();
    completer.complete(data);
  }

  Future<EventMode> getEventMode() async {
    final response = await _sendCommandAndWaitForResponse(
      _Command.getEventMode,
    );
    return EventMode.fromValue(response.getInt8(8));
  }

  Future<void> setEventMode(EventMode eventMode) async {
    final input = Uint8List(8);
    input[7] = eventMode.value;
    await _sendCommand(_Command.setEventMode, input);
  }

  Future<void> _fetchDeviceCode() async {
    var response = await _sendCommandAndWaitForResponse(
      _Command.isSpeechMikePremium,
    );

    if ((response.getUint8(8) & 0x80) != 0) {
      response = await _sendCommandAndWaitForResponse(
        _Command.getDeviceCodeSmp,
      );

      if (response.getUint8(1) != 0) {
        response = await _sendCommandAndWaitForResponse(
          _Command.getDeviceCodeSo,
        );
        _deviceCode = response.getUint16(7);
      } else {
        final smpaCode = response.getUint16(2);
        final smptCode = response.getUint16(4);
        final smpCode = response.getUint16(6);

        _deviceCode = [smpCode, smptCode, smpaCode].reduce(max);

        if ([
          DeviceType.speechMikeSmp4000.value,
          DeviceType.speechMikeSmp4010.value,
        ].contains(_deviceCode)) {
          response = await _sendCommandAndWaitForResponse(
            _Command.getFirmwareVersion,
          );
          if (response.getUint8(5) == 6) {
            response = await _sendCommandAndWaitForResponse(
              _Command.getDeviceCodeSo,
            );
            final smAmbientDeviceCode = response.getUint16(5);
            if (smAmbientDeviceCode != 0) {
              _deviceCode = smAmbientDeviceCode;
            }
          }
        }
      }
    } else {
      response = await _sendCommandAndWaitForResponse(
        _Command.getDeviceCodeSm3,
      );
      _deviceCode = response.getUint16(7);
    }
  }

  void _determineSliderBitsFilter() {
    final type = DeviceType.fromValue(_deviceCode);
    if (_phiSliders.contains(type)) {
      _sliderBitsFilter =
          ButtonEvent.forward |
          ButtonEvent.stop |
          ButtonEvent.play |
          ButtonEvent.rewind;
    } else if (_intSliders.contains(type)) {
      _sliderBitsFilter =
          ButtonEvent.record |
          ButtonEvent.stop |
          ButtonEvent.play |
          ButtonEvent.rewind;
    }
  }

  @override
  Future<void> handleInputReport(int reportId, ByteData data) async {
    final commandValue = data.getUint8(0);
    final command = _Command.fromValue(commandValue);

    if (command == _Command.buttonPressEvent) {
      await handleButtonPress(data);
    } else if (command == _Command.motionEvent) {
      await _handleMotionEvent(data);
    } else if (command == _Command.wirelessStatusEvent) {
      // Do nothing
    } else if (_commandResolvers.containsKey(commandValue)) {
      await _handleCommandResponse(commandValue, data);
    } else {
      // Ignore unknown reports or throw if critical
    }
  }

  @override
  Map<int, int> getButtonMappings() {
    if (hidDevice.info.vendorId == 0x0554 &&
        hidDevice.info.productId == 0x0064) {
      return _buttonMappingsPowerMic4;
    }
    return _buttonMappingsSpeechMike;
  }

  @override
  int getInputBitmask(ByteData data) {
    return data.getUint16(7, Endian.little);
  }

  Future<void> _handleMotionEvent(ByteData data) async {
    final inputBitMask = data.getUint8(8);
    final motionEvent = inputBitMask == 1
        ? MotionEvent.layedDown
        : MotionEvent.pickedUp;

    for (final listener in _motionEventListeners) {
      listener(this, motionEvent);
    }
  }

  Future<void> _sendCommand(_Command command, [Uint8List? input]) async {
    final data = Uint8List(1 + (input?.length ?? 0));
    data[0] = command.value;
    if (input != null) {
      data.setRange(1, data.length, input);
    }
    await hidDevice.write(HidOutputReport(0, data));
  }

  Future<ByteData> _sendCommandAndWaitForResponse(
    _Command command, [
    Uint8List? input,
  ]) async {
    if (_commandResolvers.containsKey(command.value)) {
      throw Exception('Command ${command.name} is already running');
    }

    final completer = Completer<ByteData>();
    _commandResolvers[command.value] = completer;

    final timer = Timer(Duration(milliseconds: _commandTimeoutMs), () {
      final comp = _commandResolvers.remove(command.value);
      if (comp != null) {
        comp.completeError(
          TimeoutException(
            'Command ${command.name} timed out after $_commandTimeoutMs ms',
          ),
        );
      }
      _commandTimeouts.remove(command.value);
    });
    _commandTimeouts[command.value] = timer;

    await _sendCommand(command, input);

    return completer.future;
  }

  @override
  int filterOutputBitMask(int outputBitMask) {
    if (_sliderBitsFilter == 0) return outputBitMask;

    final buttonBitsFilter = ~_sliderBitsFilter;

    final sliderValue = outputBitMask & _sliderBitsFilter;
    final buttonValue = outputBitMask & buttonBitsFilter;

    final sliderChanged = sliderValue != _lastSliderValue;
    final buttonChanged = buttonValue != _lastButtonValue;

    _lastSliderValue = sliderValue;
    _lastButtonValue = buttonValue;

    if (sliderChanged && buttonChanged) {
      return outputBitMask & buttonBitsFilter;
    } else if (sliderChanged) {
      return outputBitMask & _sliderBitsFilter;
    } else if (buttonChanged) {
      return outputBitMask & buttonBitsFilter;
    }

    return outputBitMask;
  }
}
