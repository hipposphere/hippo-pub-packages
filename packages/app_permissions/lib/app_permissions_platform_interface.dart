import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'app_permissions_method_channel.dart';
import 'src/permission_status.dart';

abstract class AppPermissionsPlatform extends PlatformInterface {
  /// Constructs a AppPermissionsPlatform.
  AppPermissionsPlatform() : super(token: _token);

  static final Object _token = Object();

  static AppPermissionsPlatform _instance = MethodChannelAppPermissions();

  /// The default instance of [AppPermissionsPlatform] to use.
  ///
  /// Defaults to [MethodChannelAppPermissions].
  static AppPermissionsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AppPermissionsPlatform] when
  /// they register themselves.
  static set instance(AppPermissionsPlatform instance) {
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

  /// Checks if Microphone permission is granted.
  Future<bool> isMicrophoneGranted() {
    throw UnimplementedError('isMicrophoneGranted() has not been implemented.');
  }

  /// Requests Microphone permission.
  Future<bool> requestMicrophone() {
    throw UnimplementedError('requestMicrophone() has not been implemented.');
  }

  /// Gets the detailed status of Microphone permission.
  Future<PermissionStatus> getMicrophoneStatus() {
    throw UnimplementedError('getMicrophoneStatus() has not been implemented.');
  }
}
