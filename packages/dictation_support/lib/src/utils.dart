import 'package:hid_device_manager/hid_device_manager.dart';

import 'devices/foot_control_device.dart';
import 'devices/powermic_3_device.dart';
import 'devices/speechmike_gamepad_device.dart';
import 'devices/speechmike_hid_device.dart';
import 'dictation_device.dart';
import 'enums.dart';

typedef DeviceFilter = HidDeviceMatcher;

const Map<ImplementationType, List<HidDeviceMatcher>> deviceFilters = {
  ImplementationType.speechMikeHid: [
    HidDeviceMatcher(
      vendorId: 0x0911,
      productId: 0x0c1c,
      usagePage: 65440,
      usage: 1,
    ),
    HidDeviceMatcher(
      vendorId: 0x0911,
      productId: 0x0c1d,
      usagePage: 65440,
      usage: 1,
    ),
    HidDeviceMatcher(
      vendorId: 0x0911,
      productId: 0x0c1e,
      usagePage: 65440,
      usage: 1,
    ),
    HidDeviceMatcher(
      vendorId: 0x0911,
      productId: 0x0fa0,
      usagePage: 65440,
      usage: 1,
    ),
    HidDeviceMatcher(
      vendorId: 0x0554,
      productId: 0x0064,
      usagePage: 65440,
      usage: 1,
    ),
  ],
  ImplementationType.speechMikeGamepad: [
    HidDeviceMatcher(
      vendorId: 0x0911,
      productId: 0x0fa0,
      usagePage: 1,
      usage: 4,
    ),
    HidDeviceMatcher(
      vendorId: 0x0911,
      productId: 0x0c1e,
      usagePage: 1,
      usage: 4,
    ),
    HidDeviceMatcher(
      vendorId: 0x0554,
      productId: 0x0064,
      usagePage: 1,
      usage: 4,
    ),
  ],
  ImplementationType.footControl: [
    HidDeviceMatcher(
      vendorId: 0x0911,
      productId: 0x1844,
      usagePage: 1,
      usage: 4,
    ),
    HidDeviceMatcher(
      vendorId: 0x0911,
      productId: 0x091a,
      usagePage: 1,
      usage: 4,
    ),
  ],
  ImplementationType.powerMic3: [
    HidDeviceMatcher(
      vendorId: 0x0554,
      productId: 0x1001,
      usagePage: 1,
      usage: 0,
    ),
  ],
};

ImplementationType? getImplType(HidDeviceInfo info) {
  for (final entry in deviceFilters.entries) {
    if (entry.value.any((filter) => filter.matches(info))) {
      return entry.key;
    }
  }
  return null;
}

List<HidDeviceDefinition<DictationDevice>> buildDictationDeviceDefinitions({
  HidOpenMode openMode = HidOpenMode.preferExclusive,
}) {
  return [
    HidDeviceDefinition<DictationDevice>(
      id: 'dictation.speechmike-hid',
      label: 'SpeechMike HID',
      matchers: deviceFilters[ImplementationType.speechMikeHid]!,
      openMode: openMode,
      controllerFactory: SpeechMikeHidDevice.new,
    ),
    HidDeviceDefinition<DictationDevice>(
      id: 'dictation.speechmike-gamepad',
      label: 'SpeechMike Gamepad',
      matchers: deviceFilters[ImplementationType.speechMikeGamepad]!,
      openMode: openMode,
      controllerFactory: SpeechMikeGamepadDevice.new,
    ),
    HidDeviceDefinition<DictationDevice>(
      id: 'dictation.foot-control',
      label: 'Foot Control',
      matchers: deviceFilters[ImplementationType.footControl]!,
      openMode: openMode,
      controllerFactory: FootControlDevice.new,
    ),
    HidDeviceDefinition<DictationDevice>(
      id: 'dictation.powermic3',
      label: 'PowerMic 3',
      matchers: deviceFilters[ImplementationType.powerMic3]!,
      openMode: openMode,
      controllerFactory: PowerMic3Device.new,
    ),
  ];
}
