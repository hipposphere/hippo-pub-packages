import 'package:flutter/services.dart';
import 'src/models/hot_key_event.dart';
import 'hotkey_api_platform_interface.dart';

export 'src/models/hot_key_event.dart';
export 'src/utils/map_physical_keyboard_key.dart';

class HotkeyApi {
  static Stream<HotkeyEvent> streamHotkeyEvents({
    required List<PhysicalKeyboardKey> keys,
  }) {
    return HotkeyApiPlatform.instance.streamHotkeyEvents(keys: keys);
  }
}
