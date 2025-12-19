import 'dart:typed_data';
import '../dictation_device.dart';
import '../enums.dart';

class SpeechMikeGamepadDevice extends DictationDevice {
  @override
  ImplementationType get implType => ImplementationType.speechMikeGamepad;

  static const Map<int, int> _buttonMappingsSpeechMike = {
    ButtonEvent.rewind: 1 << 0,
    ButtonEvent.play: 1 << 1,
    ButtonEvent.forward: 1 << 2,
    ButtonEvent.insOvr: 1 << 4,
    ButtonEvent.record: 1 << 5,
    ButtonEvent.command: 1 << 6,
    ButtonEvent.instr: 1 << 9,
    ButtonEvent.f1A: 1 << 10,
    ButtonEvent.f2B: 1 << 11,
    ButtonEvent.f3C: 1 << 12,
    ButtonEvent.f4D: 1 << 13,
    ButtonEvent.eolPrio: 1 << 14,
  };

  static const Map<int, int> _buttonMappingsPowerMic4 = {
    ButtonEvent.tabBackward: 1 << 0,
    ButtonEvent.play: 1 << 1,
    ButtonEvent.tabForward: 1 << 2,
    ButtonEvent.forward: 1 << 4,
    ButtonEvent.record: 1 << 5,
    ButtonEvent.command: 1 << 6,
    ButtonEvent.enterSelect: 1 << 9,
    ButtonEvent.f1A: 1 << 10,
    ButtonEvent.f2B: 1 << 11,
    ButtonEvent.f3C: 1 << 12,
    ButtonEvent.f4D: 1 << 13,
    ButtonEvent.rewind: 1 << 14,
  };

  SpeechMikeGamepadDevice(super.hidDevice);

  @override
  DeviceType getDeviceType() => DeviceType.unknown;

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
    return data.getUint16(0, Endian.little);
  }
}
