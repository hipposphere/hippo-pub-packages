class HidDeviceInfo {
  final String path; // OS-specific device path
  final int vendorId;
  final int productId;
  final int releaseNumber;

  final int usagePage;
  final int usage;

  final String? manufacturer;
  final String? product;
  final String? serialNumber;

  final int interfaceNumber;

  HidDeviceInfo({
    required this.path,
    required this.vendorId,
    required this.productId,
    required this.releaseNumber,
    required this.usagePage,
    required this.usage,
    this.manufacturer,
    this.product,
    this.serialNumber,
    required this.interfaceNumber,
  });
}
