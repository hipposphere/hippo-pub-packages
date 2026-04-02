import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:hid_device_manager/hid_device_manager.dart';

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
    for (final command in _Command.values) {
      if (command.value == value) {
        return command;
      }
    }
    return null;
  }
}

class SpeechMikeHidDevice extends DictationDevice {
  SpeechMikeHidDevice(super.managedDevice) {
    for (final index in LedIndex.values) {
      _ledState[index] = LedMode.off;
    }
  }

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
  ButtonEventListener? _proxyButtonListener;
  bool _isRecoveringConnection = false;

  static const int _commandTimeoutMs = 100;

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

  void addMotionEventListener(MotionEventListener listener) {
    _motionEventListeners.add(listener);
  }

  void removeMotionEventListener(MotionEventListener listener) {
    _motionEventListeners.remove(listener);
  }

  @override
  Future<void> onConnected() async {
    if (_deviceCode == 0) {
      await _fetchDeviceCode();
      _determineSliderBitsFilter();
    }

    try {
      await _restoreHidEventMode(force: true);
      // ignore: avoid_print
      print('SpeechMike: Event mode set to HID');
    } catch (error) {
      // ignore: avoid_print
      print('SpeechMike: Failed to set event mode to HID: $error');
    }
  }

  @override
  Future<void> onDisconnected() async {
    _clearPendingCommands(HidException('SpeechMike disconnected'));
  }

  @override
  Future<void> dispose() async {
    _clearPendingCommands(HidException('SpeechMike disposed'));

    final proxyDevice = _proxyDevice;
    final proxyButtonListener = _proxyButtonListener;
    if (proxyDevice != null && proxyButtonListener != null) {
      proxyDevice.removeButtonEventListener(proxyButtonListener);
    }
    _proxyDevice = null;
    _proxyButtonListener = null;

    await super.dispose();
  }

  @override
  Future<void> recoverConnection() async {
    await super.recoverConnection();

    if (_isRecoveringConnection || _commandResolvers.isNotEmpty) {
      return;
    }

    _isRecoveringConnection = true;
    try {
      await _restoreHidEventMode();
    } finally {
      _isRecoveringConnection = false;
    }
  }

  int getDeviceCode() => _deviceCode;

  @override
  DeviceType getDeviceType() {
    if (info.vendorId == 0x0554) {
      if (info.productId == 0x0064) {
        return DeviceType.powerMic4;
      }
      return DeviceType.unknown;
    }

    if (info.vendorId == 0x0911) {
      return DeviceType.fromValue(_deviceCode);
    }

    return DeviceType.unknown;
  }

  Future<void> setSimpleLedState(SimpleLedState simpleLedState) async {
    _applySimpleLedState(simpleLedState);
    await _sendLedState();
  }

  void _applySimpleLedState(SimpleLedState state) {
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
    final data = Uint8List(8);

    data[5] |= _ledState[LedIndex.recordLedGreen]!.value << 0;
    data[5] |= _ledState[LedIndex.recordLedRed]!.value << 2;
    data[5] |= _ledState[LedIndex.instructionLedGreen]!.value << 4;
    data[5] |= _ledState[LedIndex.instructionLedRed]!.value << 6;

    data[6] |= _ledState[LedIndex.insOwrButtonLedGreen]!.value << 0;
    data[6] |= _ledState[LedIndex.insOwrButtonLedRed]!.value << 2;
    data[6] |= _ledState[LedIndex.f1ButtonLed]!.value << 4;
    data[6] |= _ledState[LedIndex.f2ButtonLed]!.value << 6;

    data[7] |= _ledState[LedIndex.f3ButtonLed]!.value << 0;
    data[7] |= _ledState[LedIndex.f4ButtonLed]!.value << 2;

    await hidDevice.sendReport(HidReport(2, data), HidReportType.output);
  }

  void assignProxyDevice(SpeechMikeGamepadDevice proxyDevice) {
    if (identical(_proxyDevice, proxyDevice)) {
      return;
    }

    final currentProxy = _proxyDevice;
    final proxyButtonListener = _proxyButtonListener;
    if (currentProxy != null && proxyButtonListener != null) {
      currentProxy.removeButtonEventListener(proxyButtonListener);
    }

    _proxyDevice = proxyDevice;
    _proxyButtonListener = (device, bitMask) => notifyButtonListeners(bitMask);
    proxyDevice.addButtonEventListener(_proxyButtonListener!);
  }

  Future<void> _handleCommandResponse(int commandValue, ByteData data) async {
    final completer = _commandResolvers.remove(commandValue);
    if (completer == null) {
      return;
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

  Future<void> _restoreHidEventMode({bool force = false}) async {
    if (!force) {
      try {
        final eventMode = await getEventMode();
        if (eventMode == EventMode.hid) {
          return;
        }

        // ignore: avoid_print
        print('SpeechMike: Restoring HID event mode from ${eventMode.name}');
      } on TimeoutException {
        // ignore: avoid_print
        print(
          'SpeechMike: Event mode probe timed out, forcing HID mode restore',
        );
      }
    }

    await setEventMode(EventMode.hid);
  }

  Future<void> _fetchDeviceCode() async {
    ByteData? response;
    bool isPremium = false;

    final pid = info.productId;
    final isKnownPremium = pid == 0x0c1d || pid == 0x0c1e;

    if (isKnownPremium) {
      isPremium = true;
    } else {
      try {
        response = await _sendCommandAndWaitForResponse(
          _Command.isSpeechMikePremium,
        );
        isPremium = (response.getUint8(8) & 0x80) != 0;
      } on TimeoutException {
        isPremium = false;
      }
    }

    if (isPremium) {
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
      try {
        response = await _sendCommandAndWaitForResponse(
          _Command.getDeviceCodeSm3,
        );
        _deviceCode = response.getUint16(7);
      } on TimeoutException {
        // ignore: avoid_print
        print(
          'SpeechMike: getDeviceCodeSm3 command timed out, using default device code',
        );
        _deviceCode = 0;
      }
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
      return;
    }

    if (command == _Command.motionEvent) {
      await _handleMotionEvent(data);
      return;
    }

    if (command == _Command.wirelessStatusEvent) {
      return;
    }

    if (_commandResolvers.containsKey(commandValue)) {
      await _handleCommandResponse(commandValue, data);
    }
  }

  @override
  Map<int, int> getButtonMappings() {
    if (info.vendorId == 0x0554 && info.productId == 0x0064) {
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
    await hidDevice.sendReport(HidReport(1, data), HidReportType.output);
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
      final running = _commandResolvers.remove(command.value);
      if (running != null) {
        running.completeError(
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

  void _clearPendingCommands(Object error) {
    final runningCommands = _commandResolvers.values.toList(growable: false);
    _commandResolvers.clear();

    for (final timer in _commandTimeouts.values) {
      timer.cancel();
    }
    _commandTimeouts.clear();

    for (final completer in runningCommands) {
      if (!completer.isCompleted) {
        completer.completeError(error);
      }
    }
  }

  @override
  int filterOutputBitMask(int outputBitMask) {
    if (_sliderBitsFilter == 0) {
      return outputBitMask;
    }

    final buttonBitsFilter = ~_sliderBitsFilter;
    final sliderValue = outputBitMask & _sliderBitsFilter;
    final buttonValue = outputBitMask & buttonBitsFilter;

    final sliderChanged = sliderValue != _lastSliderValue;
    final buttonChanged = buttonValue != _lastButtonValue;

    _lastSliderValue = sliderValue;
    _lastButtonValue = buttonValue;

    if (sliderChanged && buttonChanged) {
      return outputBitMask & buttonBitsFilter;
    }
    if (sliderChanged) {
      return outputBitMask & _sliderBitsFilter;
    }
    if (buttonChanged) {
      return outputBitMask & buttonBitsFilter;
    }

    return outputBitMask;
  }
}
