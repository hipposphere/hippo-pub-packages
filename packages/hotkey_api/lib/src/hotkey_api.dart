import 'package:flutter/services.dart';
import 'package:hotkey_api/hotkey_api.dart';

class HotkeyApi {
  static HotkeyApiPlatformInterface? _instance;

  static HotkeyApiPlatformInterface get _platform => _instance!;

  static Stream<HotkeyEvent> streamHotkeys({
    required List<PhysicalKeyboardKey> keys,
  }) {
    return _platform.streamHotkeys(keys: keys);
  }
}
