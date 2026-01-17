import 'app_permissions_platform_interface.dart';
import 'src/permission_status.dart';

export 'src/permission_status.dart';

/// Main class for permissions management.
class AppPermissions {
  AppPermissions._();

  /// Checks if Accessibility permission is granted WITHOUT requesting it.
  ///
  /// This method only reads the current permission status and will NOT
  /// trigger any system permission dialogs or prompts. Use this to check
  /// the permission state without disturbing the user.
  ///
  /// On macOS, this checks if the app has been granted Accessibility permission
  /// which is required for:
  /// - Global keyboard/mouse monitoring
  /// - Simulating keyboard/mouse input
  /// - UI element inspection
  ///
  /// NOTE: On macOS, Accessibility and Input Monitoring are separate permissions:
  /// - Accessibility: For manipulating UI elements and simulating input
  /// - Input Monitoring: For monitoring keyboard/mouse events system-wide
  ///
  /// On Windows and other platforms, this always returns true as no special
  /// permissions are required.
  static Future<bool> isAccessibilityGranted() {
    return AppPermissionsPlatform.instance.isAccessibilityGranted();
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
  static Future<bool> requestAccessibility({
    bool openSystemPreferences = true,
  }) {
    return AppPermissionsPlatform.instance.requestAccessibility(
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
  static Future<PermissionStatus> getAccessibilityStatus() {
    return AppPermissionsPlatform.instance.getAccessibilityStatus();
  }

  /// Checks if Input Monitoring permission is granted WITHOUT requesting it.
  ///
  /// This method only reads the current permission status and will NOT
  /// trigger any system permission dialogs or prompts. Use this to check
  /// the permission state without disturbing the user.
  ///
  /// On macOS (10.15+), Input Monitoring permission is separate from
  /// Accessibility permission and is specifically required for:
  /// - Monitoring keyboard input events system-wide
  /// - Monitoring mouse events when the app is not focused
  /// - Capturing global hotkeys and shortcuts
  ///
  /// On Windows and other platforms, this always returns true.
  static Future<bool> isInputMonitoringGranted() {
    return AppPermissionsPlatform.instance.isInputMonitoringGranted();
  }

  /// Requests Input Monitoring permission.
  ///
  /// On macOS, opens System Settings to the Input Monitoring pane.
  /// On Windows and other platforms, this is a no-op and returns true.
  static Future<bool> requestInputMonitoring({
    bool openSystemPreferences = true,
  }) {
    return AppPermissionsPlatform.instance.requestInputMonitoring(
      openSystemPreferences: openSystemPreferences,
    );
  }

  /// Gets the detailed status of Input Monitoring permission.
  static Future<PermissionStatus> getInputMonitoringStatus() {
    return AppPermissionsPlatform.instance.getInputMonitoringStatus();
  }

  /// Checks if Microphone permission is granted WITHOUT requesting it.
  ///
  /// This method only reads the current permission status and will NOT
  /// trigger any system permission dialogs or prompts. Use this to check
  /// the permission state without disturbing the user.
  ///
  /// On macOS, this checks if the app has been granted Microphone permission
  /// which is required for recording audio.
  ///
  /// On Windows and other platforms, this always returns true.
  static Future<bool> isMicrophoneGranted() {
    return AppPermissionsPlatform.instance.isMicrophoneGranted();
  }

  /// Requests Microphone permission.
  ///
  /// On macOS, this will trigger the system permission dialog asking the user
  /// to grant microphone access. The dialog appears automatically when you
  /// attempt to access the microphone.
  ///
  /// IMPORTANT: For the permission dialog to appear, you must add the
  /// following to your Info.plist (in macos/Runner/Info.plist):
  /// ```xml
  /// <key>NSMicrophoneUsageDescription</key>
  /// <string>This app needs access to the microphone for voice recording.</string>
  /// ```
  ///
  /// On Windows and other platforms, this is a no-op and returns true.
  ///
  /// Returns true if permission is granted, false if denied.
  static Future<bool> requestMicrophone() {
    return AppPermissionsPlatform.instance.requestMicrophone();
  }

  /// Gets the detailed status of Microphone permission.
  ///
  /// Returns a [PermissionStatus] indicating whether the permission is:
  /// - [PermissionStatus.granted]: Permission has been granted
  /// - [PermissionStatus.denied]: Permission has been explicitly denied
  /// - [PermissionStatus.notDetermined]: Permission hasn't been requested yet
  /// - [PermissionStatus.notRequired]: Platform doesn't require this permission
  static Future<PermissionStatus> getMicrophoneStatus() {
    return AppPermissionsPlatform.instance.getMicrophoneStatus();
  }
}
