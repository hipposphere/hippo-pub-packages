import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'desktop_autopaste_method_channel.dart';

abstract class DesktopAutopastePlatform extends PlatformInterface {
  /// Constructs a DesktopAutopastePlatform.
  DesktopAutopastePlatform() : super(token: _token);

  static final Object _token = Object();

  static DesktopAutopastePlatform _instance = MethodChannelDesktopAutopaste();

  /// The default instance of [DesktopAutopastePlatform] to use.
  ///
  /// Defaults to [MethodChannelDesktopAutopaste].
  static DesktopAutopastePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [DesktopAutopastePlatform] when
  /// they register themselves.
  static set instance(DesktopAutopastePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<bool> pasteIntoCursor(String text) {
    throw UnimplementedError('pasteIntoCursor() has not been implemented.');
  }

  Future<bool> pasteIntoCursorViaClipboard(String text) {
    throw UnimplementedError(
      'pasteIntoCursorViaClipboard() has not been implemented.',
    );
  }
}
