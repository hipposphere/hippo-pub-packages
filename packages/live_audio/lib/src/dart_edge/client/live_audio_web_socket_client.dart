import 'dart:async';

import 'package:dart_edge_core/dart_edge_core.dart';

import '../../models/live_audio_socket_message.dart';

final class LiveAudioDartEdgeWebSocketClient {
  LiveAudioDartEdgeWebSocketClient(this._socket);

  final DartEdgeClientWebSocket _socket;

  Stream<WebSocketMessage> get frames => _socket.messages;

  Stream<Object?> jsonEvents() {
    return _socket.messages
        .where((message) => message.kind == WebSocketMessageKind.text)
        .map((message) => LiveAudioSocketJson.decode(message.text));
  }

  Stream<List<int>> audioChunks() {
    return _socket.messages
        .where((message) => message.kind == WebSocketMessageKind.binary)
        .map((message) => message.bytes);
  }

  Future<void> sendAudio(List<int> bytes) => _socket.sendBinary(bytes);

  Future<void> sendAudioJson(List<int> bytes) {
    return _socket.sendJson(
      const LiveAudioSocketMessageCodec().encode(LiveAudioSocketMessage.audioBytes(bytes)),
    );
  }

  Future<void> sendText(String text) {
    return _send(LiveAudioSocketMessage(type: LiveAudioSocketMessageType.text, text: text));
  }

  Future<void> commitAudio() {
    return _send(const LiveAudioSocketMessage(type: LiveAudioSocketMessageType.commitAudio));
  }

  Future<void> clearAudio() {
    return _send(const LiveAudioSocketMessage(type: LiveAudioSocketMessageType.clearAudio));
  }

  Future<void> endAudioInput() {
    return _send(const LiveAudioSocketMessage(type: LiveAudioSocketMessageType.endAudioInput));
  }

  Future<void> cancelResponse() {
    return _send(const LiveAudioSocketMessage(type: LiveAudioSocketMessageType.cancelResponse));
  }

  Future<void> close([int? code, String? reason]) async {
    if (reason != null) {
      await _send(LiveAudioSocketMessage(type: LiveAudioSocketMessageType.close, reason: reason));
    }
    await _socket.close(code, reason);
  }

  Future<void> _send(LiveAudioSocketMessage message) {
    return _socket.sendJson(const LiveAudioSocketMessageCodec().encode(message));
  }
}
