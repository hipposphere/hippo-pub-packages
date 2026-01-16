import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'desktop_permissions_method_channel.dart';
import 'src/permission_status.dart';

abstract class DesktopPermissionsPlatform extends PlatformInterface {
  /// Constructs a DesktopPermissionsPlatform.
  DesktopPermissionsPlatform() : super(token: _token);

  static final Object _token = Object();

  static DesktopPermissionsPlatform _instance =
      MethodChannelDesktopPermissions();

  /// The default instance of [DesktopPermissionsPlatform] to use.
  ///
  /// Defaults to [MethodChannelDesktopPermissions].
  static DesktopPermissionsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [DesktopPermissionsPlatform] when
  /// they register themselves.
  static set instance(DesktopPermissionsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Checks if Accessibility permission is granted.
  Future<bool> isAccessibilityGranted() {
    throw UnimplementedError(
      'isAccessibilityGranted() has not been implemented.',
    );
  }

  /// Requests Accessibility permission.
  Future<bool> requestAccessibility({bool openSystemPreferences = true}) {
    throw UnimplementedError(
      'requestAccessibility() has not been implemented.',
    );
  }

  /// Gets the detailed status of Accessibility permission.
  Future<PermissionStatus> getAccessibilityStatus() {
    throw UnimplementedError(
      'getAccessibilityStatus() has not been implemented.',
    );
  }

  /// Checks if Input Monitoring permission is granted.
  Future<bool> isInputMonitoringGranted() {
    throw UnimplementedError(
      'isInputMonitoringGranted() has not been implemented.',
    );
  }

  /// Requests Input Monitoring permission.
  Future<bool> requestInputMonitoring({bool openSystemPreferences = true}) {
    throw UnimplementedError(
      'requestInputMonitoring() has not been implemented.',
    );
  }

  /// Gets the detailed status of Input Monitoring permission.
  Future<PermissionStatus> getInputMonitoringStatus() {
    throw UnimplementedError(
      'getInputMonitoringStatus() has not been implemented.',
    );
  }
}
