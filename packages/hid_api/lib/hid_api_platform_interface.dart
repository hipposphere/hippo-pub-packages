import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'hid_api_method_channel.dart';
import 'src/hid_device.dart';
import 'src/hid_device_info.dart';

export 'src/hid_device.dart';
export 'src/hid_device_info.dart';
export 'src/hid_report.dart';
export 'src/hid_exception.dart';

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

  Future<void> initialize() {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  Future<void> shutdown() {
    throw UnimplementedError('shutdown() has not been implemented.');
  }

  Future<List<HidDeviceInfo>> enumerate({
    int? vendorId,
    int? productId,
    String? serialNumber,
  }) {
    throw UnimplementedError('enumerate() has not been implemented.');
  }

  Future<HidDevice> open(String devicePath) {
    throw UnimplementedError('open() has not been implemented.');
  }
}
