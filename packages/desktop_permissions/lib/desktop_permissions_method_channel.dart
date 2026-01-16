import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'desktop_permissions_platform_interface.dart';
import 'src/permission_status.dart';

/// An implementation of [DesktopPermissionsPlatform] that uses method channels.
class MethodChannelDesktopPermissions extends DesktopPermissionsPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('desktop_permissions');

  @override
  Future<bool> isAccessibilityGranted() async {
    final result = await methodChannel.invokeMethod<bool>(
      'isAccessibilityGranted',
    );
    return result ?? false;
  }

  @override
  Future<bool> requestAccessibility({bool openSystemPreferences = true}) async {
    final result = await methodChannel.invokeMethod<bool>(
      'requestAccessibility',
      {'openSystemPreferences': openSystemPreferences},
    );
    return result ?? false;
  }

  @override
  Future<PermissionStatus> getAccessibilityStatus() async {
    final result = await methodChannel.invokeMethod<String>(
      'getAccessibilityStatus',
    );
    return _parsePermissionStatus(result);
  }

  @override
  Future<bool> isInputMonitoringGranted() async {
    final result = await methodChannel.invokeMethod<bool>(
      'isInputMonitoringGranted',
    );
    return result ?? false;
  }

  @override
  Future<bool> requestInputMonitoring({
    bool openSystemPreferences = true,
  }) async {
    final result = await methodChannel.invokeMethod<bool>(
      'requestInputMonitoring',
      {'openSystemPreferences': openSystemPreferences},
    );
    return result ?? false;
  }

  @override
  Future<PermissionStatus> getInputMonitoringStatus() async {
    final result = await methodChannel.invokeMethod<String>(
      'getInputMonitoringStatus',
    );
    return _parsePermissionStatus(result);
  }

  PermissionStatus _parsePermissionStatus(String? status) {
    switch (status) {
      case 'granted':
        return PermissionStatus.granted;
      case 'denied':
        return PermissionStatus.denied;
      case 'notDetermined':
        return PermissionStatus.notDetermined;
      case 'notRequired':
        return PermissionStatus.notRequired;
      default:
        return PermissionStatus.notRequired;
    }
  }
}
