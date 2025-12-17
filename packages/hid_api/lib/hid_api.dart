
import 'hid_api_platform_interface.dart';

class HidApi {
  Future<String?> getPlatformVersion() {
    return HidApiPlatform.instance.getPlatformVersion();
  }
}
