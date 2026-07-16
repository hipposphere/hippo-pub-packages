import 'dart:typed_data';

import 'package:agent_core/agent_core.dart';

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
    this.turnId,
    super.rawEvent,
  });

  final Uint8List bytes;
  final LiveAudioInputFormat? format;
  final String? responseId;
  final String? turnId;
}

final class LiveAudioTranscript extends LiveAudioEvent {
  const LiveAudioTranscript({
    required super.provider,
    required this.kind,
    required this.text,
    this.isDelta = false,
    this.itemId,
    this.responseId,
    this.turnId,
    super.rawEvent,
  });

  final LiveAudioTranscriptKind kind;
  final String text;
  final bool isDelta;
  final String? itemId;
  final String? responseId;
  final String? turnId;
}

final class LiveAudioTextDelta extends LiveAudioEvent {
  const LiveAudioTextDelta({
    required super.provider,
    required this.text,
    this.responseId,
    this.turnId,
    super.rawEvent,
  });

  final String text;
  final String? responseId;
  final String? turnId;
}

final class LiveAudioThinking extends LiveAudioEvent {
  const LiveAudioThinking({required super.provider, this.text, this.turnId, super.rawEvent});

  final String? text;
  final String? turnId;
}

final class LiveAudioInterrupted extends LiveAudioEvent {
  const LiveAudioInterrupted({required super.provider, this.turnId, super.rawEvent});

  final String? turnId;
}

final class LiveAudioTurnComplete extends LiveAudioEvent {
  const LiveAudioTurnComplete({required super.provider, this.turnId, super.rawEvent});

  final String? turnId;
}

final class LiveAudioToolCallEvent extends LiveAudioEvent {
  const LiveAudioToolCallEvent({
    required super.provider,
    required this.call,
    super.rawEvent,
  });

  final AgentToolCall<Map<String, Object?>> call;
}

final class LiveAudioError extends LiveAudioEvent {
  const LiveAudioError({required super.provider, required this.message, this.code, super.rawEvent});

  final String message;
  final String? code;
}

final class LiveAudioRawEvent extends LiveAudioEvent {
  const LiveAudioRawEvent({required super.provider, required super.rawEvent});
}
