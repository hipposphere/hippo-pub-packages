import 'dart:async';
import 'dart:convert';
import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart';

import '../axum_app.dart';
import '../axum_http.dart';
import '../ffi/dart_axum_bindings.dart' as bindings;

final class AxumNativeBridge {
  AxumNativeBridge._();

  static final AxumNativeBridge instance = AxumNativeBridge._();

  final Map<int, AxumServer> _servers = <int, AxumServer>{};

  late final ffi.NativeCallable<bindings.dart_axum_dispatch_callback_t> _dispatchCallback =
      ffi.NativeCallable<bindings.dart_axum_dispatch_callback_t>.listener(
        _handleNativeEventPointer,
      );

  bool _dispatchInstalled = false;

  Future<AxumServer> startServer({
    required AxumApp app,
    required String host,
    required int port,
    required int maxBodyBytes,
  }) async {
    _installDispatchCallback();

    final configPointer = jsonEncode(<String, Object?>{
      'host': host,
      'port': port,
      'maxBodyBytes': maxBodyBytes,
    }).toNativeUtf8(allocator: calloc).cast<ffi.Char>();
    final serverIdPointer = calloc<ffi.Int64>();
    final portPointer = calloc<ffi.Uint16>();

    try {
      _throwIfError(
        bindings.dart_axum_start_server(configPointer, serverIdPointer, portPointer),
        action: 'start native Axum server',
      );
      final server = AxumServer.internal(
        bridge: this,
        app: app,
        id: serverIdPointer.value,
        host: host,
        port: portPointer.value,
      );
      _servers[server.id] = server;
      return server;
    } finally {
      calloc.free(configPointer);
      calloc.free(serverIdPointer);
      calloc.free(portPointer);
    }
  }

  Future<void> stopServer(AxumServer server) async {
    _throwIfError(bindings.dart_axum_stop_server(server.id), action: 'stop native Axum server');
    _servers.remove(server.id);
  }

  Future<void> completeHttpRequest({
    required AxumServer server,
    required int requestId,
    required AxumResponse response,
  }) async {
    final responsePointer = jsonEncode(<String, Object?>{
      'status': response.statusCode,
      'headers': response.headers,
      'bodyBase64': base64Encode(response.body),
    }).toNativeUtf8(allocator: calloc).cast<ffi.Char>();
    try {
      _throwIfError(
        bindings.dart_axum_complete_http_request(server.id, requestId, responsePointer),
        action: 'complete HTTP request',
      );
    } finally {
      calloc.free(responsePointer);
    }
  }

  Future<void> startSseResponse({
    required AxumServer server,
    required int requestId,
    required int statusCode,
    required Map<String, List<String>> headers,
  }) async {
    final responsePointer = jsonEncode(<String, Object?>{
      'status': statusCode,
      'headers': headers,
    }).toNativeUtf8(allocator: calloc).cast<ffi.Char>();
    try {
      _throwIfError(
        bindings.dart_axum_start_sse_response(server.id, requestId, responsePointer),
        action: 'start SSE response',
      );
    } finally {
      calloc.free(responsePointer);
    }
  }

  Future<void> sendSseChunk({
    required AxumServer server,
    required int streamId,
    required String chunk,
  }) async {
    final chunkPointer = chunk.toNativeUtf8(allocator: calloc).cast<ffi.Char>();
    try {
      _throwIfError(
        bindings.dart_axum_sse_send(server.id, streamId, chunkPointer),
        action: 'send SSE chunk',
      );
    } finally {
      calloc.free(chunkPointer);
    }
  }

  Future<void> closeSseResponse({required AxumServer server, required int streamId}) async {
    _throwIfError(bindings.dart_axum_sse_close(server.id, streamId), action: 'close SSE response');
  }

  Future<void> sendWebSocketFrame({
    required AxumServer server,
    required int socketId,
    required Map<String, Object?> frame,
  }) async {
    final framePointer = jsonEncode(frame).toNativeUtf8(allocator: calloc).cast<ffi.Char>();
    try {
      _throwIfError(
        bindings.dart_axum_websocket_send(server.id, socketId, framePointer),
        action: 'send websocket frame',
      );
    } finally {
      calloc.free(framePointer);
    }
  }

  void _installDispatchCallback() {
    if (_dispatchInstalled) {
      return;
    }
    _throwIfError(
      bindings.dart_axum_set_dispatch_callback(_dispatchCallback.nativeFunction),
      action: 'install native dispatch callback',
    );
    _dispatchInstalled = true;
  }

  void _handleNativeEventPointer(ffi.Pointer<ffi.Char> eventPointer) {
    try {
      final payload = eventPointer.cast<Utf8>().toDartString();
      final decoded = jsonDecode(payload);
      if (decoded is! Map<Object?, Object?>) {
        return;
      }
      final event = decoded.cast<String, Object?>();
      final serverId = event['serverId'];
      if (serverId is! int) {
        return;
      }
      final server = _servers[serverId];
      if (server == null) {
        return;
      }
      server.dispatchNativeEvent(event);
    } finally {
      bindings.dart_axum_string_free(eventPointer);
    }
  }

  void _throwIfError(ffi.Pointer<ffi.Char> errorPointer, {required String action}) {
    if (errorPointer == ffi.nullptr) {
      return;
    }
    try {
      final message = errorPointer.cast<Utf8>().toDartString();
      throw AxumNativeException('$action failed: $message');
    } finally {
      bindings.dart_axum_string_free(errorPointer);
    }
  }
}

final class AxumNativeException implements Exception {
  AxumNativeException(this.message);

  final String message;

  @override
  String toString() => 'AxumNativeException: $message';
}
