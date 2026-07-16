import 'dart:typed_data';

import 'package:agent_core/agent_core.dart';

import 'models/live_audio_event.dart';
import 'models/live_audio_provider.dart';

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

  Future<void> sendToolResult(AgentToolResult<Object?> result);

  Future<void> close();
}
