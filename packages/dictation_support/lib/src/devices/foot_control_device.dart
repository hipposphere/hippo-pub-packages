import 'dart:typed_data';
import '../dictation_device.dart';
import '../enums.dart';

class FootControlDevice extends DictationDevice {
  @override
  ImplementationType get implType => ImplementationType.footControl;

  static const Map<int, int> _buttonMappings = {
    ButtonEvent.rewind: 1 << 0,
    ButtonEvent.play: 1 << 1,
    ButtonEvent.forward: 1 << 2,
    ButtonEvent.eolPrio: 1 << 3,
  };

  FootControlDevice(super.hidDevice);

  @override
  DeviceType getDeviceType() {
    if (hidDevice.info.vendorId == 0x0911) {
      if (hidDevice.info.productId == 0x1844) {
        return DeviceType.footControlAcc2310_2320;
      } else if (hidDevice.info.productId == 0x091a) {
        return DeviceType.footControlAcc2330;
      }
    }
    return DeviceType.unknown;
  }

  @override
  Map<int, int> getButtonMappings() => _buttonMappings;

  @override
  int getInputBitmask(ByteData data) {
    return data.getUint8(0);
  }
}
