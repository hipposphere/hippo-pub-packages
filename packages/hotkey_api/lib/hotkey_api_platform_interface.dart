import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'hotkey_api_method_channel.dart';

abstract class HotkeyApiPlatform extends PlatformInterface {
  /// Constructs a HotkeyApiPlatform.
  HotkeyApiPlatform() : super(token: _token);

  static final Object _token = Object();

  static HotkeyApiPlatform _instance = MethodChannelHotkeyApi();

  /// The default instance of [HotkeyApiPlatform] to use.
  ///
  /// Defaults to [MethodChannelHotkeyApi].
  static HotkeyApiPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [HotkeyApiPlatform] when
  /// they register themselves.
  static set instance(HotkeyApiPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
