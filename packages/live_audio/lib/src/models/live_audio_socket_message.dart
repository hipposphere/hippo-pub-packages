import 'dart:convert';
import 'dart:typed_data';

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
