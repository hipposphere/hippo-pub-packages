import 'dart:typed_data';
import 'package:hid_api/hid_api.dart';
import '../dictation_device.dart';
import '../enums.dart';

class PowerMic3Device extends DictationDevice {
  @override
  ImplementationType get implType => ImplementationType.powerMic3;

  static const Map<int, int> _buttonMappings = {
    ButtonEvent.transcribe: 1 << 0,
    ButtonEvent.tabBackward: 1 << 1,
    ButtonEvent.record: 1 << 2,
    ButtonEvent.tabForward: 1 << 3,
    ButtonEvent.rewind: 1 << 4,
    ButtonEvent.forward: 1 << 5,
    ButtonEvent.play: 1 << 6,
    ButtonEvent.customLeft: 1 << 7,
    ButtonEvent.enterSelect: 1 << 8,
    ButtonEvent.customRight: 1 << 9,
  };

  PowerMic3Device(super.hidDevice);

  @override
  DeviceType getDeviceType() => DeviceType.powerMic3;

  Future<void> setLed(int state) async {
    final data = Uint8List.fromList([state]);
    await hidDevice.write(HidOutputReport(0, data));
  }

  @override
  Map<int, int> getButtonMappings() => _buttonMappings;

  @override
  int getInputBitmask(ByteData data) {
    // Offset 1, little endian
    return data.getUint16(1, Endian.little);
  }
}
