import 'src/models/hot_key_event.dart';
import 'hotkey_api_platform_interface.dart';

export 'src/models/hot_key_event.dart';
export 'src/utils/physical_keyboard_helper.dart';

class HotkeyApi {
  static Stream<HotkeyEvent> streamHotkeyEvents() {
    return HotkeyApiPlatform.instance.streamHotkeyEvents();
  }
}
