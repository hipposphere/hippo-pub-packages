import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'desktop_autopaste_platform_interface.dart';

/// An implementation of [DesktopAutopastePlatform] that uses method channels.
class MethodChannelDesktopAutopaste extends DesktopAutopastePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('desktop_autopaste');

  @override
  Future<bool> pasteIntoCursor(String text) async {
    final result = await methodChannel.invokeMethod('pasteIntoCursor', text);
    return result;
  }

  @override
  Future<bool> pasteIntoCursorViaClipboard(String text) async {
    final result = await methodChannel.invokeMethod(
      'pasteIntoCursorViaClipboard',
      text,
    );
    return result;
  }
}
