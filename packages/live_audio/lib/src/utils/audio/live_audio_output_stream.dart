import 'dart:typed_data';

import '../../live_audio_session.dart';

extension LiveAudioEventAudioStream on Stream<LiveAudioEvent> {
  Stream<Uint8List> outputAudioStream() {
    return LiveAudioOutputAudioStream(events: this).chunks;
  }
}

final class LiveAudioOutputAudioStream {
  LiveAudioOutputAudioStream({required this.events});

  final Stream<LiveAudioEvent> events;

  Stream<Uint8List> get chunks async* {
    await for (final event in events) {
      if (event is LiveAudioOutputChunk && event.bytes.isNotEmpty) {
        yield event.bytes;
      }
    }
  }
}
