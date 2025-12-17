import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'hid_api_method_channel.dart';

abstract class HidApiPlatform extends PlatformInterface {
  /// Constructs a HidApiPlatform.
  HidApiPlatform() : super(token: _token);

  static final Object _token = Object();

  static HidApiPlatform _instance = MethodChannelHidApi();

  /// The default instance of [HidApiPlatform] to use.
  ///
  /// Defaults to [MethodChannelHidApi].
  static HidApiPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [HidApiPlatform] when
  /// they register themselves.
  static set instance(HidApiPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
