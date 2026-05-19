import 'dart:typed_data';

import 'live_audio_format.dart';
import 'live_audio_provider.dart';

enum LiveAudioTranscriptKind { input, output }

sealed class LiveAudioEvent {
  const LiveAudioEvent({required this.provider, this.rawEvent});

  final LiveAudioProvider provider;
  final Object? rawEvent;
}

final class LiveAudioSessionStarted extends LiveAudioEvent {
  const LiveAudioSessionStarted({required super.provider, this.sessionId, super.rawEvent});

  final String? sessionId;
}

final class LiveAudioOutputChunk extends LiveAudioEvent {
  const LiveAudioOutputChunk({
    required super.provider,
    required this.bytes,
    this.format,
    this.responseId,
    super.rawEvent,
  });

  final Uint8List bytes;
  final LiveAudioInputFormat? format;
  final String? responseId;
}

final class LiveAudioTranscript extends LiveAudioEvent {
  const LiveAudioTranscript({
    required super.provider,
    required this.kind,
    required this.text,
    this.isDelta = false,
    this.itemId,
    this.responseId,
    super.rawEvent,
  });

  final LiveAudioTranscriptKind kind;
  final String text;
  final bool isDelta;
  final String? itemId;
  final String? responseId;
}

final class LiveAudioTextDelta extends LiveAudioEvent {
  const LiveAudioTextDelta({
    required super.provider,
    required this.text,
    this.responseId,
    super.rawEvent,
  });

  final String text;
  final String? responseId;
}

final class LiveAudioThinking extends LiveAudioEvent {
  const LiveAudioThinking({required super.provider, this.text, super.rawEvent});

  final String? text;
}

final class LiveAudioInterrupted extends LiveAudioEvent {
  const LiveAudioInterrupted({required super.provider, super.rawEvent});
}

final class LiveAudioTurnComplete extends LiveAudioEvent {
  const LiveAudioTurnComplete({required super.provider, super.rawEvent});
}

final class LiveAudioToolCall extends LiveAudioEvent {
  const LiveAudioToolCall({
    required super.provider,
    required this.name,
    required this.arguments,
    this.id,
    super.rawEvent,
  });

  final String name;
  final Map<String, dynamic> arguments;
  final String? id;
}

final class LiveAudioError extends LiveAudioEvent {
  const LiveAudioError({required super.provider, required this.message, this.code, super.rawEvent});

  final String message;
  final String? code;
}

final class LiveAudioRawEvent extends LiveAudioEvent {
  const LiveAudioRawEvent({required super.provider, required super.rawEvent});
}
