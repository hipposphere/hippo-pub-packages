import 'desktop_permissions_platform_interface.dart';
import 'src/permission_status.dart';

export 'src/permission_status.dart';

/// Main class for desktop permissions management.
class DesktopPermissions {
  /// Checks if Accessibility permission is granted.
  ///
  /// On macOS, this checks if the app has been granted Accessibility permission
  /// which is required for:
  /// - Global keyboard/mouse monitoring
  /// - Simulating keyboard/mouse input
  /// - UI element inspection
  ///
  /// On Windows and other platforms, this always returns true as no special
  /// permissions are required.
  Future<bool> isAccessibilityGranted() {
    return DesktopPermissionsPlatform.instance.isAccessibilityGranted();
  }

  /// Requests Accessibility permission.
  ///
  /// On macOS:
  /// - If [openSystemPreferences] is true (default), opens System Settings
  ///   to the Privacy & Security > Accessibility pane where the user can
  ///   manually grant permission.
  /// - If [openSystemPreferences] is false, shows the system permission prompt
  ///   (only works if the app hasn't been previously denied).
  ///
  /// On Windows and other platforms, this is a no-op and returns true.
  ///
  /// Returns true if permission is already granted or successfully requested.
  Future<bool> requestAccessibility({bool openSystemPreferences = true}) {
    return DesktopPermissionsPlatform.instance.requestAccessibility(
      openSystemPreferences: openSystemPreferences,
    );
  }

  /// Gets the detailed status of Accessibility permission.
  ///
  /// Returns a [PermissionStatus] indicating whether the permission is:
  /// - [PermissionStatus.granted]: Permission has been granted
  /// - [PermissionStatus.denied]: Permission has been explicitly denied
  /// - [PermissionStatus.notDetermined]: Permission hasn't been requested yet
  /// - [PermissionStatus.notRequired]: Platform doesn't require this permission
  Future<PermissionStatus> getAccessibilityStatus() {
    return DesktopPermissionsPlatform.instance.getAccessibilityStatus();
  }

  /// Checks if Input Monitoring permission is granted.
  ///
  /// On macOS, this is similar to Accessibility permission but specifically
  /// for monitoring keyboard and mouse input when the app is not focused.
  ///
  /// On Windows and other platforms, this always returns true.
  Future<bool> isInputMonitoringGranted() {
    return DesktopPermissionsPlatform.instance.isInputMonitoringGranted();
  }

  /// Requests Input Monitoring permission.
  ///
  /// On macOS, opens System Settings to the Input Monitoring pane.
  /// On Windows and other platforms, this is a no-op and returns true.
  Future<bool> requestInputMonitoring({bool openSystemPreferences = true}) {
    return DesktopPermissionsPlatform.instance.requestInputMonitoring(
      openSystemPreferences: openSystemPreferences,
    );
  }

  /// Gets the detailed status of Input Monitoring permission.
  Future<PermissionStatus> getInputMonitoringStatus() {
    return DesktopPermissionsPlatform.instance.getInputMonitoringStatus();
  }
}
