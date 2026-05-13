import 'dart:convert';
import 'dart:typed_data';

import 'live_audio_event.dart';
import 'live_audio_format.dart';

enum LiveAudioSocketMessageType {
  audio,
  text,
  commitAudio,
  clearAudio,
  endAudioInput,
  cancelResponse,
  close,
}

final class LiveAudioSocketMessage {
  const LiveAudioSocketMessage({required this.type, this.text, this.audio, this.reason});

  factory LiveAudioSocketMessage.fromJson(Object? json) {
    if (json is! Map) {
      throw FormatException('Expected live audio socket message object.');
    }

    final type = _typeFromJson(json['type']);
    return LiveAudioSocketMessage(
      type: type,
      text: json['text'] as String?,
      audio: _readAudio(json['audio']),
      reason: json['reason'] as String?,
    );
  }

  factory LiveAudioSocketMessage.fromJsonText(String text) {
    return LiveAudioSocketMessage.fromJson(jsonDecode(text));
  }

  factory LiveAudioSocketMessage.audioBytes(List<int> bytes) {
    return LiveAudioSocketMessage(
      type: LiveAudioSocketMessageType.audio,
      audio: Uint8List.fromList(bytes),
    );
  }

  final LiveAudioSocketMessageType type;
  final String? text;
  final Uint8List? audio;
  final String? reason;

  static LiveAudioSocketMessageType _typeFromJson(Object? value) {
    return switch (value) {
      'audio' => LiveAudioSocketMessageType.audio,
      'text' => LiveAudioSocketMessageType.text,
      'commit_audio' => LiveAudioSocketMessageType.commitAudio,
      'clear_audio' => LiveAudioSocketMessageType.clearAudio,
      'end_audio_input' => LiveAudioSocketMessageType.endAudioInput,
      'cancel_response' => LiveAudioSocketMessageType.cancelResponse,
      'close' => LiveAudioSocketMessageType.close,
      _ => throw FormatException('Unknown live audio socket message type: $value'),
    };
  }

  static Uint8List? _readAudio(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is String) {
      return base64Decode(value);
    }
    if (value is List) {
      return Uint8List.fromList(value.cast<int>());
    }
    throw FormatException('Expected audio as base64 string or byte list.');
  }
}

final class LiveAudioSocketMessageCodec {
  const LiveAudioSocketMessageCodec();

  Object encode(LiveAudioSocketMessage message) {
    return {
      'type': _typeToJson(message.type),
      'text': ?message.text,
      'audio': ?(message.audio == null ? null : base64Encode(message.audio!)),
      'reason': ?message.reason,
    };
  }

  LiveAudioSocketMessage decode(Object? json) {
    return LiveAudioSocketMessage.fromJson(json);
  }

  LiveAudioSocketMessage decodeText(String text) {
    return LiveAudioSocketMessage.fromJsonText(text);
  }

  String _typeToJson(LiveAudioSocketMessageType type) {
    return switch (type) {
      LiveAudioSocketMessageType.audio => 'audio',
      LiveAudioSocketMessageType.text => 'text',
      LiveAudioSocketMessageType.commitAudio => 'commit_audio',
      LiveAudioSocketMessageType.clearAudio => 'clear_audio',
      LiveAudioSocketMessageType.endAudioInput => 'end_audio_input',
      LiveAudioSocketMessageType.cancelResponse => 'cancel_response',
      LiveAudioSocketMessageType.close => 'close',
    };
  }
}

final class LiveAudioSocketJson {
  const LiveAudioSocketJson._();

  static Object? decode(String text) => jsonDecode(text);
}

final class LiveAudioSocketEventCodec {
  const LiveAudioSocketEventCodec({this.includeRawEvents = false});

  final bool includeRawEvents;

  Object? encode(LiveAudioEvent event) {
    if (event is LiveAudioRawEvent && !includeRawEvents) {
      return null;
    }

    return switch (event) {
      LiveAudioSessionStarted(:final sessionId) => {
        'type': 'session_started',
        'session_id': ?sessionId,
        'provider': event.provider.name,
      },
      LiveAudioOutputChunk(:final bytes, :final format, :final responseId) => {
        'type': 'audio',
        'audio': base64Encode(bytes),
        'format': ?(format == null ? null : _formatToJson(format)),
        'response_id': ?responseId,
        'provider': event.provider.name,
      },
      LiveAudioTranscript(
        :final kind,
        :final text,
        :final isDelta,
        :final itemId,
        :final responseId,
      ) =>
        {
          'type': 'transcript',
          'kind': kind.name,
          'text': text,
          'is_delta': isDelta,
          'item_id': ?itemId,
          'response_id': ?responseId,
          'provider': event.provider.name,
        },
      LiveAudioTextDelta(:final text, :final responseId) => {
        'type': 'text_delta',
        'text': text,
        'response_id': ?responseId,
        'provider': event.provider.name,
      },
      LiveAudioTurnComplete() => {'type': 'turn_complete', 'provider': event.provider.name},
      LiveAudioToolCall(:final name, :final arguments, :final id) => {
        'type': 'tool_call',
        'name': name,
        'arguments': arguments,
        'id': ?id,
        'provider': event.provider.name,
      },
      LiveAudioError(:final message, :final code) => {
        'type': 'error',
        'message': message,
        'code': ?code,
        'provider': event.provider.name,
      },
      LiveAudioRawEvent(:final rawEvent) => {
        'type': 'raw',
        'event': rawEvent.toString(),
        'provider': event.provider.name,
      },
    };
  }

  static Object _formatToJson(LiveAudioInputFormat format) {
    return {
      'type': format.format.mimeType,
      'sample_rate': format.sampleRate,
      'channels': format.channels,
    };
  }
}

Object? encodeLiveAudioSocketEvent(LiveAudioEvent event) {
  return const LiveAudioSocketEventCodec().encode(event);
}
