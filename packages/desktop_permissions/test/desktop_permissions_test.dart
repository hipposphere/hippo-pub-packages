import 'package:flutter_test/flutter_test.dart';
import 'package:desktop_permissions/desktop_permissions.dart';
import 'package:desktop_permissions/desktop_permissions_platform_interface.dart';
import 'package:desktop_permissions/desktop_permissions_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockDesktopPermissionsPlatform
    with MockPlatformInterfaceMixin
    implements DesktopPermissionsPlatform {
  @override
  Future<bool> isAccessibilityGranted() async {
    return true;
  }

  @override
  Future<bool> requestAccessibility({bool openSystemPreferences = true}) async {
    return true;
  }

  @override
  Future<PermissionStatus> getAccessibilityStatus() async {
    return PermissionStatus.granted;
  }

  @override
  Future<bool> isInputMonitoringGranted() async {
    return true;
  }

  @override
  Future<bool> requestInputMonitoring({
    bool openSystemPreferences = true,
  }) async {
    return true;
  }

  @override
  Future<PermissionStatus> getInputMonitoringStatus() async {
    return PermissionStatus.granted;
  }
}

void main() {
  final DesktopPermissionsPlatform initialPlatform =
      DesktopPermissionsPlatform.instance;

  test('$MethodChannelDesktopPermissions is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelDesktopPermissions>());
  });

  test('isAccessibilityGranted', () async {
    DesktopPermissions desktopPermissionsPlugin = DesktopPermissions();
    MockDesktopPermissionsPlatform fakePlatform =
        MockDesktopPermissionsPlatform();
    DesktopPermissionsPlatform.instance = fakePlatform;

    expect(await desktopPermissionsPlugin.isAccessibilityGranted(), true);
  });

  test('getAccessibilityStatus', () async {
    DesktopPermissions desktopPermissionsPlugin = DesktopPermissions();
    MockDesktopPermissionsPlatform fakePlatform =
        MockDesktopPermissionsPlatform();
    DesktopPermissionsPlatform.instance = fakePlatform;

    expect(
      await desktopPermissionsPlugin.getAccessibilityStatus(),
      PermissionStatus.granted,
    );
  });
}
