import 'dart:typed_data';

import 'models/live_audio_event.dart';
import 'models/live_audio_provider.dart';
import 'models/live_audio_tool.dart';

export 'models/live_audio_event.dart';
export 'models/live_audio_format.dart';
export 'models/live_audio_provider.dart';

abstract interface class LiveAudioSession {
  LiveAudioProvider get provider;

  Stream<LiveAudioEvent> get events;

  Future<void> sendText(String text);

  Future<void> sendAudio(Uint8List bytes);

  Future<void> commitAudio();

  Future<void> clearAudio();

  Future<void> endAudioInput();

  Future<void> sendToolResponse(LiveAudioToolResponse response);

  Future<void> close();
}
