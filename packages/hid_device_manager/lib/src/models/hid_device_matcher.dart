part of '../hid_device_manager.dart';

class HidDeviceMatcher {
  final int? vendorId;
  final int? productId;
  final int? releaseNumber;
  final int? usagePage;
  final int? usage;
  final int? interfaceNumber;
  final String? manufacturer;
  final String? product;
  final String? serialNumber;
  final bool Function(HidDeviceInfo info)? predicate;

  const HidDeviceMatcher({
    this.vendorId,
    this.productId,
    this.releaseNumber,
    this.usagePage,
    this.usage,
    this.interfaceNumber,
    this.manufacturer,
    this.product,
    this.serialNumber,
    this.predicate,
  });

  bool matches(HidDeviceInfo info) {
    if (vendorId != null && info.vendorId != vendorId) return false;
    if (productId != null && info.productId != productId) return false;
    if (releaseNumber != null && info.releaseNumber != releaseNumber) {
      return false;
    }
    if (usagePage != null && info.usagePage != usagePage) return false;
    if (usage != null && info.usage != usage) return false;
    if (interfaceNumber != null && info.interfaceNumber != interfaceNumber) {
      return false;
    }
    if (manufacturer != null && info.manufacturer != manufacturer) {
      return false;
    }
    if (product != null && info.product != product) return false;
    if (serialNumber != null && info.serialNumber != serialNumber) {
      return false;
    }
    if (predicate != null && !predicate!(info)) return false;
    return true;
  }
}
