import 'package:hid_api_platform_interface/hid_api_method_channel.dart';
import 'package:hid_api_platform_interface/hid_api_platform_interface.dart';

/// Windows implementation of the federated `hid_api` plugin.
final class HidApiWindows extends MethodChannelHidApi {
  /// Registers this package as the active HID implementation.
  static void registerWith() {
    HidApiPlatform.instance = HidApiWindows();
  }
}
