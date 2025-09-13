import 'package:flutter/services.dart';
import 'package:hotkey_api/src/models/hot_key_event.dart';

import 'hotkey_api_platform_interface.dart';

class HotkeyApi {
  static Stream<HotkeyEvent> streamHotkeyEvents({
    required List<PhysicalKeyboardKey> keys,
  }) {
    return HotkeyApiPlatform.instance.streamHotkeyEvents(keys: keys);
  }
}
