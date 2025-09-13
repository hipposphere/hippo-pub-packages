import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'hid_api_platform_interface.dart';

/// An implementation of [HidApiPlatform] that uses method channels.
class MethodChannelHidApi extends HidApiPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('hid_api');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
