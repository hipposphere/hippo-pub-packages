import 'package:flutter_test/flutter_test.dart';
import 'package:app_permissions/app_permissions.dart';
import 'package:app_permissions/app_permissions_platform_interface.dart';
import 'package:app_permissions/app_permissions_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAppPermissionsPlatform
    with MockPlatformInterfaceMixin
    implements AppPermissionsPlatform {
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

  @override
  Future<bool> isMicrophoneGranted() async {
    return true;
  }

  @override
  Future<bool> requestMicrophone() async {
    return true;
  }

  @override
  Future<PermissionStatus> getMicrophoneStatus() async {
    return PermissionStatus.granted;
  }
}

void main() {
  final AppPermissionsPlatform initialPlatform =
      AppPermissionsPlatform.instance;

  test('$MethodChannelAppPermissions is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAppPermissions>());
  });

  test('isAccessibilityGranted', () async {
    MockAppPermissionsPlatform fakePlatform = MockAppPermissionsPlatform();
    AppPermissionsPlatform.instance = fakePlatform;

    expect(await AppPermissions.isAccessibilityGranted(), true);
  });

  test('getAccessibilityStatus', () async {
    MockAppPermissionsPlatform fakePlatform = MockAppPermissionsPlatform();
    AppPermissionsPlatform.instance = fakePlatform;

    expect(
      await AppPermissions.getAccessibilityStatus(),
      PermissionStatus.granted,
    );
  });
}
