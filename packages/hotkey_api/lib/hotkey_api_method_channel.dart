import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_api/src/models/hot_key_event.dart';
import 'package:hotkey_api/src/utils/map_physical_keyboard_key.dart';

import 'hotkey_api_platform_interface.dart';

/// An implementation of [HotkeyApiPlatform] that uses method channels.
class MethodChannelHotkeyApi extends HotkeyApiPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('hotkey_api/methods');
  final eventChannel = const EventChannel('hotkey_api/events');

  @override
  Stream<HotkeyEvent> streamHotkeyEvents({
    required List<PhysicalKeyboardKey> keys,
  }) {
    return eventChannel
        .receiveBroadcastStream({
          'keys': keys.map((e) => mapPhysicalKeyboardKey(e)).toList(),
        })
        .map((event) => HotkeyEvent.fromMap(event));
  }
}
