import 'package:flutter_test/flutter_test.dart';
import 'package:hid_api/hid_api.dart';
import 'package:hid_api_platform_interface/hid_api_platform_interface.dart';

void main() {
  late HidApiPlatform previousPlatform;
  late _RecordingHidApiPlatform platform;

  setUp(() {
    previousPlatform = HidApiPlatform.instance;
    platform = _RecordingHidApiPlatform();
    HidApiPlatform.instance = platform;
  });

  tearDown(() {
    HidApiPlatform.instance = previousPlatform;
  });

  test('delegates app-facing calls to the registered implementation', () async {
    await HidApi.initialize();
    expect(platform.initialized, isTrue);

    final devices = await HidApi.enumerate(vendorId: 0x1234, productId: 0x5678);
    expect(devices, same(platform.devices));
    expect(platform.vendorId, 0x1234);
    expect(platform.productId, 0x5678);

    await HidApi.shutdown();
    expect(platform.initialized, isFalse);
  });
}

final class _RecordingHidApiPlatform extends HidApiPlatform {
  bool initialized = false;
  int? vendorId;
  int? productId;

  final List<HidDeviceInfo> devices = <HidDeviceInfo>[
    HidDeviceInfo(
      path: 'test-device',
      vendorId: 0x1234,
      productId: 0x5678,
      releaseNumber: 1,
      usagePage: 1,
      usage: 1,
      interfaceNumber: 0,
    ),
  ];

  @override
  Future<void> initialize() async {
    initialized = true;
  }

  @override
  Future<void> shutdown() async {
    initialized = false;
  }

  @override
  Future<List<HidDeviceInfo>> enumerate({
    int? vendorId,
    int? productId,
    String? serialNumber,
  }) async {
    this.vendorId = vendorId;
    this.productId = productId;
    return devices;
  }

  @override
  Future<HidDevice> open(String devicePath, {bool exclusive = false}) {
    throw UnimplementedError();
  }

  @override
  Stream<List<HidDeviceInfo>> get deviceListStream => const Stream.empty();
}
