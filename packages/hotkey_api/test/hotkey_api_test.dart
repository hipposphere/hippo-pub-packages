import 'package:flutter_test/flutter_test.dart';
import 'package:hotkey_api/hotkey_api.dart';
import 'package:hotkey_api/hotkey_api_platform_interface.dart';
import 'package:hotkey_api/hotkey_api_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockHotkeyApiPlatform
    with MockPlatformInterfaceMixin
    implements HotkeyApiPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final HotkeyApiPlatform initialPlatform = HotkeyApiPlatform.instance;

  test('$MethodChannelHotkeyApi is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelHotkeyApi>());
  });

  test('getPlatformVersion', () async {
    HotkeyApi hotkeyApiPlugin = HotkeyApi();
    MockHotkeyApiPlatform fakePlatform = MockHotkeyApiPlatform();
    HotkeyApiPlatform.instance = fakePlatform;

    expect(await hotkeyApiPlugin.getPlatformVersion(), '42');
  });
}
