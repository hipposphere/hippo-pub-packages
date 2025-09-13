import 'package:flutter/services.dart';
import 'package:hotkey_api/hotkey_api.dart';

abstract class HotkeyApiPlatformInterface {
  Stream<HotkeyEvent> streamHotkeys({required List<PhysicalKeyboardKey> keys});
}
