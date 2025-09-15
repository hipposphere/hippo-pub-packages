import 'package:hotkey_api/hotkey_api.dart';
import 'hotkey_api_platform_interface.dart';

class HotkeyApi {
  static Stream<HotkeyEvent> streamHotkeyEvents() {
    return HotkeyApiPlatform.instance.streamHotkeyEvents();
  }
}
