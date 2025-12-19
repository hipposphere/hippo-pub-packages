import 'package:hid_api/hid_api.dart';
import 'enums.dart';

class DeviceFilter {
  final int? vendorId;
  final int? productId;
  final int? usagePage;
  final int? usage;

  const DeviceFilter({
    this.vendorId,
    this.productId,
    this.usagePage,
    this.usage,
  });

  bool matches(HidDeviceInfo info) {
    if (vendorId != null && info.vendorId != vendorId) return false;
    if (productId != null && info.productId != productId) return false;
    if (usagePage != null && info.usagePage != usagePage) return false;
    if (usage != null && info.usage != usage) return false;
    return true;
  }
}

const Map<ImplementationType, List<DeviceFilter>> deviceFilters = {
  ImplementationType.speechMikeHid: [
    // Wired SpeechMikes (LFH35xx, LFH36xx, SMP37xx, SMP38xx) in HID mode
    DeviceFilter(
      vendorId: 0x0911,
      productId: 0x0c1c,
      usagePage: 65440,
      usage: 1,
    ),
    // SpeechMike Premium Air (SMP40xx) in HID mode
    DeviceFilter(
      vendorId: 0x0911,
      productId: 0x0c1d,
      usagePage: 65440,
      usage: 1,
    ),
    // SpeechOne (PSM6000) or SpeechMike Ambient (PSM5000) in HID or Browser/Gamepad mode
    DeviceFilter(
      vendorId: 0x0911,
      productId: 0x0c1e,
      usagePage: 65440,
      usage: 1,
    ),
    // All SpeechMikes in Browser/Gamepad mode
    DeviceFilter(
      vendorId: 0x0911,
      productId: 0x0fa0,
      usagePage: 65440,
      usage: 1,
    ),
    // PowerMic IV in HID or Browser/Gamepad mode
    DeviceFilter(
      vendorId: 0x0554,
      productId: 0x0064,
      usagePage: 65440,
      usage: 1,
    ),
  ],
  ImplementationType.speechMikeGamepad: [
    // All SpeechMikes in Browser/Gamepad mode
    DeviceFilter(vendorId: 0x0911, productId: 0x0fa0, usagePage: 1, usage: 4),
    // SpeechOne (PSM6000) or SpeechMike Ambient (PSM5000) in Browser/Gamepad mode
    DeviceFilter(vendorId: 0x0911, productId: 0x0c1e, usagePage: 1, usage: 4),
    // PowerMic IV in Browser/Gamepad mode
    DeviceFilter(vendorId: 0x0554, productId: 0x0064, usagePage: 1, usage: 4),
  ],
  ImplementationType.footControl: [
    // 3-pedal Foot control ACC2310/2320
    DeviceFilter(vendorId: 0x0911, productId: 0x1844, usagePage: 1, usage: 4),
    // 4-pedal Foot control ACC2330
    DeviceFilter(vendorId: 0x0911, productId: 0x091a, usagePage: 1, usage: 4),
  ],
  ImplementationType.powerMic3: [
    // PowerMic III
    DeviceFilter(vendorId: 0x0554, productId: 0x1001, usagePage: 1, usage: 0),
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
