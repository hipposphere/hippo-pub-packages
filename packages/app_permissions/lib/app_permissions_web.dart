import 'dart:async';
import 'dart:js_interop';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:web/web.dart';

import 'app_permissions_platform_interface.dart';
import 'src/permission_status.dart' as app_perms;

/// A web implementation of the AppPermissionsPlatform of the AppPermissions plugin.
class AppPermissionsWeb extends AppPermissionsPlatform {
  /// Constructs a AppPermissionsWeb.
  AppPermissionsWeb();

  static void registerWith(Registrar registrar) {
    AppPermissionsPlatform.instance = AppPermissionsWeb();
  }

  @override
  Future<bool> isAccessibilityGranted() async {
    return true;
  }

  @override
  Future<bool> requestAccessibility({bool openSystemPreferences = true}) async {
    return true;
  }

  @override
  Future<app_perms.PermissionStatus> getAccessibilityStatus() async {
    return app_perms.PermissionStatus.notRequired;
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
  Future<app_perms.PermissionStatus> getInputMonitoringStatus() async {
    return app_perms.PermissionStatus.notRequired;
  }

  @override
  Future<bool> isMicrophoneGranted() async {
    final status = await getMicrophoneStatus();
    return status == app_perms.PermissionStatus.granted;
  }

  @override
  Future<bool> requestMicrophone() async {
    try {
      final stream = await window.navigator.mediaDevices
          .getUserMedia(MediaStreamConstraints(audio: true.toJS))
          .toDart;
      // Immediately stop the stream as we only wanted to trigger the permission prompt
      final tracks = stream.getTracks().toDart;
      for (var i = 0; i < tracks.length; i++) {
        (tracks[i] as MediaStreamTrack).stop();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<app_perms.PermissionStatus> getMicrophoneStatus() async {
    try {
      final status = await window.navigator.permissions
          .query({'name': 'microphone'}.jsify() as JSObject)
          .toDart;

      final state = (status as PermissionStatus).state;
      switch (state) {
        case 'granted':
          return app_perms.PermissionStatus.granted;
        case 'denied':
          return app_perms.PermissionStatus.denied;
        case 'prompt':
        default:
          return app_perms.PermissionStatus.notDetermined;
      }
    } catch (e) {
      return app_perms.PermissionStatus.notDetermined;
    }
  }
}
