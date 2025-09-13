import 'package:flutter_test/flutter_test.dart';
import 'package:hid_api/hid_api.dart';
import 'package:hid_api/hid_api_platform_interface.dart';
import 'package:hid_api/hid_api_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockHidApiPlatform
    with MockPlatformInterfaceMixin
    implements HidApiPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final HidApiPlatform initialPlatform = HidApiPlatform.instance;

  test('$MethodChannelHidApi is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelHidApi>());
  });

  test('getPlatformVersion', () async {
    HidApi hidApiPlugin = HidApi();
    MockHidApiPlatform fakePlatform = MockHidApiPlatform();
    HidApiPlatform.instance = fakePlatform;

    expect(await hidApiPlugin.getPlatformVersion(), '42');
  });
}
