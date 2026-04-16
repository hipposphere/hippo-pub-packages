import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'axum_codec.dart';
import 'axum_http.dart';
import 'axum_openapi.dart';
import 'axum_type.dart';
import 'internal/axum_native_bridge.dart';

typedef AxumNext = Future<AxumResponse> Function();
typedef AxumMiddleware = FutureOr<AxumResponse> Function(AxumRequestContext context, AxumNext next);
typedef AxumHandler = FutureOr<AxumResponse> Function(AxumRequestContext context);
typedef AxumTypedHandler<TRequest, TResponse> =
    FutureOr<TResponse> Function(AxumContext<TRequest> context);
typedef AxumWebSocketHandler = FutureOr<void> Function(AxumWebSocket socket);
typedef AxumSseHandler = FutureOr<void> Function(AxumSseConnection connection);

abstract base class AxumRouteDefinition<TRequest, TResponse> {
  const AxumRouteDefinition();

  AxumMethod get method;

  String get path;

  AxumBodyDecoder<TRequest> get request;

  AxumBodyEncoder<TResponse> get response;

  AxumRouteDocs? get docs => null;

  List<AxumMiddleware> get middleware => const <AxumMiddleware>[];

  List<AxumSchemaComponent> get components => const <AxumSchemaComponent>[];
}

base class AxumTypedRouteDefinition<TRequest, TResponse>
    extends AxumRouteDefinition<TRequest, TResponse> {
  const AxumTypedRouteDefinition({
    required this.method,
    required this.path,
    required this.request,
    required this.response,
    this.docs,
    this.middleware = const <AxumMiddleware>[],
    this.components = const <AxumSchemaComponent>[],
  });

  @override
  final AxumMethod method;

  @override
  final String path;

  @override
  final AxumBodyDecoder<TRequest> request;

  @override
  final AxumBodyEncoder<TResponse> response;

  @override
  final AxumRouteDocs? docs;

  @override
  final List<AxumMiddleware> middleware;

  @override
  final List<AxumSchemaComponent> components;
}

abstract base class _AxumRouteRegistry {
  final List<AxumMiddleware> _middlewares = <AxumMiddleware>[];
  final List<_AxumRouteBase> _routes = <_AxumRouteBase>[];
  final List<_AxumSseRoute> _sseRoutes = <_AxumSseRoute>[];
  final List<_AxumWebSocketRoute> _webSocketRoutes = <_AxumWebSocketRoute>[];

  void use(AxumMiddleware middleware) {
    _middlewares.add(middleware);
  }

  void route(
    AxumMethod method,
    String path, {
    required AxumHandler handler,
    AxumRouteDocs? docs,
    List<AxumMiddleware> middleware = const <AxumMiddleware>[],
    List<AxumSchemaComponent> components = const <AxumSchemaComponent>[],
  }) {
    _routes.add(
      _AxumRawRoute(
        method: method,
        path: path,
        docs: docs,
        middleware: List<AxumMiddleware>.unmodifiable(middleware),
        components: List<AxumSchemaComponent>.unmodifiable(components),
        handler: handler,
      ),
    );
  }

  void _registerTypedRoute<TRequest, TResponse>(
    AxumMethod method,
    String path, {
    required AxumBodyDecoder<TRequest> request,
    required AxumBodyEncoder<TResponse> response,
    required AxumTypedHandler<TRequest, TResponse> handler,
    AxumRouteDocs? docs,
    List<AxumMiddleware> middleware = const <AxumMiddleware>[],
    List<AxumSchemaComponent> components = const <AxumSchemaComponent>[],
  }) {
    _routes.add(
      _AxumTypedRoute<TRequest, TResponse>(
        method: method,
        path: path,
        request: request,
        response: response,
        docs: docs,
        middleware: List<AxumMiddleware>.unmodifiable(middleware),
        components: List<AxumSchemaComponent>.unmodifiable(components),
        handler: handler,
      ),
    );
  }

  void get(
    String path, {
    required AxumHandler handler,
    AxumRouteDocs? docs,
    List<AxumMiddleware> middleware = const <AxumMiddleware>[],
    List<AxumSchemaComponent> components = const <AxumSchemaComponent>[],
  }) {
    route(
      AxumMethod.get,
      path,
      handler: handler,
      docs: docs,
      middleware: middleware,
      components: components,
    );
  }

  void post(
    String path, {
    required AxumHandler handler,
    AxumRouteDocs? docs,
    List<AxumMiddleware> middleware = const <AxumMiddleware>[],
    List<AxumSchemaComponent> components = const <AxumSchemaComponent>[],
  }) {
    route(
      AxumMethod.post,
      path,
      handler: handler,
      docs: docs,
      middleware: middleware,
      components: components,
    );
  }

  void put(
    String path, {
    required AxumHandler handler,
    AxumRouteDocs? docs,
    List<AxumMiddleware> middleware = const <AxumMiddleware>[],
    List<AxumSchemaComponent> components = const <AxumSchemaComponent>[],
  }) {
    route(
      AxumMethod.put,
      path,
      handler: handler,
      docs: docs,
      middleware: middleware,
      components: components,
    );
  }

  void patch(
    String path, {
    required AxumHandler handler,
    AxumRouteDocs? docs,
    List<AxumMiddleware> middleware = const <AxumMiddleware>[],
    List<AxumSchemaComponent> components = const <AxumSchemaComponent>[],
  }) {
    route(
      AxumMethod.patch,
      path,
      handler: handler,
      docs: docs,
      middleware: middleware,
      components: components,
    );
  }

  void delete(
    String path, {
    required AxumHandler handler,
    AxumRouteDocs? docs,
    List<AxumMiddleware> middleware = const <AxumMiddleware>[],
    List<AxumSchemaComponent> components = const <AxumSchemaComponent>[],
  }) {
    route(
      AxumMethod.delete,
      path,
      handler: handler,
      docs: docs,
      middleware: middleware,
      components: components,
    );
  }

  void register<TRequest, TResponse>(
    AxumRouteDefinition<TRequest, TResponse> route, {
    required AxumTypedHandler<TRequest, TResponse> handler,
  }) {
    _registerTypedRoute<TRequest, TResponse>(
      route.method,
      route.path,
      request: route.request,
      response: route.response,
      handler: handler,
      docs: route.docs,
      middleware: route.middleware,
      components: route.components,
    );
  }

  void mount(String prefix, AxumRouter router) {
    final normalizedPrefix = _normalizePath(prefix);
    for (final route in router._routes) {
      _routes.add(route.withPrefix(normalizedPrefix, middlewarePrefix: router._middlewares));
    }
    for (final route in router._sseRoutes) {
      _sseRoutes.add(route.withPrefix(normalizedPrefix));
    }
    for (final route in router._webSocketRoutes) {
      _webSocketRoutes.add(route.withPrefix(normalizedPrefix));
    }
  }

  void sse(
    String path,
    AxumSseHandler handler, {
    AxumRouteDocs? docs,
    List<AxumSchemaComponent> components = const <AxumSchemaComponent>[],
  }) {
    _sseRoutes.add(
      _AxumSseRoute(
        path: path,
        handler: handler,
        docs: docs,
        components: List<AxumSchemaComponent>.unmodifiable(components),
      ),
    );
  }

  void ws(String path, AxumWebSocketHandler handler) {
    _webSocketRoutes.add(_AxumWebSocketRoute(path: path, handler: handler));
  }
}

final class AxumRouter extends _AxumRouteRegistry {
  AxumRouter({void Function(AxumRouter router)? build}) {
    if (build != null) {
      build(this);
    }
  }
}

final class AxumApp extends _AxumRouteRegistry {
  AxumApp({this.openApi});

  final AxumOpenApi? openApi;

  Future<AxumServer> listen({
    String host = '127.0.0.1',
    int port = 3000,
    int maxBodyBytes = 10 * 1024 * 1024,
  }) {
    if (port < 0 || port > 65535) {
      throw ArgumentError.value(port, 'port', 'Must be in 0..65535');
    }
    if (maxBodyBytes <= 0) {
      throw ArgumentError.value(maxBodyBytes, 'maxBodyBytes', 'Must be > 0');
    }
    return AxumNativeBridge.instance.startServer(
      app: this,
      host: host,
      port: port,
      maxBodyBytes: maxBodyBytes,
    );
  }

  Map<String, Object?> openApiDocument() {
    final config =
        openApi ??
        const AxumOpenApi(
          info: AxumOpenApiInfo(title: 'dart_axum API', version: '0.1.0'),
        );
    final builder = _AxumOpenApiDocumentBuilder(config);
    for (final route in _routes) {
      builder.addRoute(route);
    }
    for (final route in _sseRoutes) {
      builder.addSseRoute(route);
    }
    return builder.build();
  }

  String openApiJsonString({bool pretty = true}) {
    final document = openApiDocument();
    if (!pretty) {
      return jsonEncode(document);
    }
    return const JsonEncoder.withIndent('  ').convert(document);
  }
}

final class AxumServer {
  AxumServer.internal({
    required AxumNativeBridge bridge,
    required AxumApp app,
    required this.id,
    required this.host,
    required this.port,
  }) : _bridge = bridge,
       _app = app;

  final AxumNativeBridge _bridge;
  final AxumApp _app;
  final Map<int, AxumSseConnection> _sseConnections = <int, AxumSseConnection>{};
  final Map<int, AxumWebSocket> _webSockets = <int, AxumWebSocket>{};
  final StreamController<String> _errors = StreamController<String>.broadcast();

  final int id;
  final String host;
  final int port;

  AxumApp get app => _app;

  Uri get baseUri => Uri(scheme: 'http', host: host, port: port);

  Stream<String> get errors => _errors.stream;

  Future<void> close() async {
    for (final connection in _sseConnections.values.toList()) {
      await connection.close();
    }
    _sseConnections.clear();
    for (final socket in _webSockets.values.toList()) {
      socket._completeClose(code: 1001, reason: 'Server shutting down');
    }
    _webSockets.clear();
    await _bridge.stopServer(this);
    await _errors.close();
  }

  void dispatchNativeEvent(Map<String, Object?> event) {
    switch (event['kind']) {
      case 'http_request':
        unawaited(_handleHttpRequest(event));
        break;
      case 'websocket_open':
        _handleWebSocketOpen(event);
        break;
      case 'websocket_message':
        _handleWebSocketMessage(event);
        break;
      case 'websocket_close':
        _handleWebSocketClose(event);
        break;
      case 'server_error':
        final message = event['message'];
        if (message is String) {
          _errors.add(message);
        }
        break;
      default:
        _errors.add('Unknown native event: ${event['kind']}');
    }
  }

  Future<void> _handleHttpRequest(Map<String, Object?> event) async {
    final requestId = event['requestId'] as int?;
    if (requestId == null) {
      return;
    }

    AxumResponse response;
    try {
      final context = _buildRequestContext(event);
      final builtInResponse = await _maybeHandleBuiltinRoute(context);
      if (builtInResponse != null) {
        response = builtInResponse;
      } else if (await _dispatchSseRoute(context, requestId: requestId)) {
        return;
      } else {
        response = await _dispatchRoute(context);
      }
    } on AxumHttpException catch (error) {
      response = error.toResponse();
    } on FormatException catch (error) {
      response = AxumResponse.json(<String, Object?>{'error': error.message}, statusCode: 400);
    } catch (error) {
      response = AxumResponse.json(<String, Object?>{'error': '$error'}, statusCode: 500);
    }

    await _bridge.completeHttpRequest(server: this, requestId: requestId, response: response);
  }

  AxumRequestContext _buildRequestContext(Map<String, Object?> event) {
    final headers = _stringListMapFromDynamic(event['headers']);
    final rawQuery = event['rawQuery'] as String? ?? '';
    return AxumRequestContext._(
      app: _app,
      server: this,
      method: AxumMethod.parse(event['method'] as String? ?? 'GET'),
      path: event['path'] as String? ?? '/',
      rawQuery: rawQuery,
      queryParameters: _queryParametersFromRaw(rawQuery),
      headers: AxumHeaders(headers),
      rawBody: AxumIncomingBody(_decodeBase64Bytes(event['bodyBase64'] as String?)),
      remoteAddress: event['remoteAddress'] as String?,
      params: const <String, String>{},
    );
  }

  Future<AxumResponse?> _maybeHandleBuiltinRoute(AxumRequestContext context) async {
    final config = _app.openApi;
    if (config == null) {
      return null;
    }
    if (context.method == AxumMethod.get && context.path == config.jsonPath) {
      return AxumResponse.json(_app.openApiDocument());
    }
    if (config.docsPath != null &&
        context.method == AxumMethod.get &&
        context.path == config.docsPath) {
      return AxumResponse.html(_redocHtml(config.jsonPath));
    }
    return null;
  }

  Future<AxumResponse> _dispatchRoute(AxumRequestContext context) async {
    for (final route in _app._routes) {
      if (route.method != context.method) {
        continue;
      }
      final match = route.pattern.match(context.path);
      if (match == null) {
        continue;
      }
      return route.handle(context.copyWith(params: match), globalMiddleware: _app._middlewares);
    }
    throw AxumHttpException(
      404,
      message: 'No route matched ${context.method.value} ${context.path}',
    );
  }

  Future<bool> _dispatchSseRoute(AxumRequestContext context, {required int requestId}) async {
    if (context.method != AxumMethod.get) {
      return false;
    }
    for (final route in _app._sseRoutes) {
      final match = route.pattern.match(context.path);
      if (match == null) {
        continue;
      }
      final connection = AxumSseConnection._(
        server: this,
        requestId: requestId,
        path: context.path,
        rawQuery: context.rawQuery,
        queryParameters: context.queryParameters,
        headers: context.headers,
        params: match,
        remoteAddress: context.remoteAddress,
      );
      await _bridge.startSseResponse(
        server: this,
        requestId: requestId,
        statusCode: 200,
        headers: const <String, List<String>>{
          'content-type': <String>['text/event-stream; charset=utf-8'],
          'cache-control': <String>['no-cache'],
          'connection': <String>['keep-alive'],
          'x-accel-buffering': <String>['no'],
        },
      );
      _sseConnections[requestId] = connection;
      unawaited(_runSseHandler(route.handler, connection));
      return true;
    }
    return false;
  }

  Future<void> _runSseHandler(AxumSseHandler handler, AxumSseConnection connection) async {
    try {
      await handler(connection);
    } catch (error) {
      _errors.add('SSE handler failed: $error');
    } finally {
      await connection.close();
      _sseConnections.remove(connection.id);
    }
  }

  void _handleWebSocketOpen(Map<String, Object?> event) {
    final socketId = event['socketId'] as int?;
    if (socketId == null) {
      return;
    }
    final path = event['path'] as String? ?? '/';
    for (final route in _app._webSocketRoutes) {
      final match = route.pattern.match(path);
      if (match == null) {
        continue;
      }
      final rawQuery = event['rawQuery'] as String? ?? '';
      final socket = AxumWebSocket._(
        server: this,
        socketId: socketId,
        path: path,
        rawQuery: rawQuery,
        queryParameters: _queryParametersFromRaw(rawQuery),
        headers: AxumHeaders(_stringListMapFromDynamic(event['headers'])),
        params: match,
        remoteAddress: event['remoteAddress'] as String?,
      );
      _webSockets[socketId] = socket;
      unawaited(_runWebSocketHandler(route.handler, socket));
      return;
    }
    final socket = AxumWebSocket._(
      server: this,
      socketId: socketId,
      path: path,
      rawQuery: event['rawQuery'] as String? ?? '',
      queryParameters: const <String, List<String>>{},
      headers: AxumHeaders(_stringListMapFromDynamic(event['headers'])),
      params: const <String, String>{},
      remoteAddress: event['remoteAddress'] as String?,
    );
    _webSockets[socketId] = socket;
    unawaited(socket.close(code: 1008, reason: 'No websocket route matched $path'));
  }

  Future<void> _runWebSocketHandler(AxumWebSocketHandler handler, AxumWebSocket socket) async {
    try {
      await handler(socket);
    } catch (error) {
      _errors.add('WebSocket handler failed: $error');
      await socket.close(code: 1011, reason: '$error');
    }
  }

  void _handleWebSocketMessage(Map<String, Object?> event) {
    final socketId = event['socketId'] as int?;
    if (socketId == null) {
      return;
    }
    final socket = _webSockets[socketId];
    if (socket == null) {
      return;
    }
    final opcode = event['opcode'] as String? ?? 'text';
    switch (opcode) {
      case 'binary':
        socket._addMessage(
          AxumWebSocketBinaryMessage(_decodeBase64Bytes(event['dataBase64'] as String?)),
        );
        break;
      default:
        socket._addMessage(AxumWebSocketTextMessage(event['text'] as String? ?? ''));
    }
  }

  void _handleWebSocketClose(Map<String, Object?> event) {
    final socketId = event['socketId'] as int?;
    if (socketId == null) {
      return;
    }
    final socket = _webSockets.remove(socketId);
    socket?._completeClose(code: event['code'] as int?, reason: event['reason'] as String?);
  }
}

final class AxumRequestContext {
  AxumRequestContext._({
    required this.app,
    required this.server,
    required this.method,
    required this.path,
    required this.rawQuery,
    required this.queryParameters,
    required this.headers,
    required this.rawBody,
    required Map<String, String> params,
    required this.remoteAddress,
  }) : params = UnmodifiableMapView<String, String>(Map<String, String>.from(params));

  final AxumApp app;
  final AxumServer server;
  final AxumMethod method;
  final String path;
  final String rawQuery;
  final Map<String, List<String>> queryParameters;
  final AxumHeaders headers;
  final AxumIncomingBody rawBody;
  final Map<String, String> params;
  final String? remoteAddress;

  String? query(String name) {
    final values = queryParameters[name];
    if (values == null || values.isEmpty) {
      return null;
    }
    return values.first;
  }

  AxumContext<TBody> withBody<TBody>(TBody body) {
    return AxumContext<TBody>._(base: this, body: body);
  }

  AxumRequestContext copyWith({Map<String, String>? params}) {
    return AxumRequestContext._(
      app: app,
      server: server,
      method: method,
      path: path,
      rawQuery: rawQuery,
      queryParameters: queryParameters,
      headers: headers,
      rawBody: rawBody,
      params: params ?? this.params,
      remoteAddress: remoteAddress,
    );
  }
}

final class AxumContext<TBody> extends AxumRequestContext {
  AxumContext._({required AxumRequestContext base, required this.body})
    : super._(
        app: base.app,
        server: base.server,
        method: base.method,
        path: base.path,
        rawQuery: base.rawQuery,
        queryParameters: base.queryParameters,
        headers: base.headers,
        rawBody: base.rawBody,
        params: base.params,
        remoteAddress: base.remoteAddress,
      );

  final TBody body;
}

final class AxumSseEvent {
  const AxumSseEvent({this.data, this.event, this.id, this.retry, this.comment});

  final String? data;
  final String? event;
  final String? id;
  final int? retry;
  final String? comment;

  String encode() {
    final buffer = StringBuffer();
    if (comment != null) {
      for (final line in _splitSseLines(comment!)) {
        buffer.writeln(': $line');
      }
    }
    if (id != null) {
      buffer.writeln('id: $id');
    }
    if (event != null) {
      buffer.writeln('event: $event');
    }
    if (retry != null) {
      buffer.writeln('retry: $retry');
    }
    if (data != null) {
      for (final line in _splitSseLines(data!)) {
        buffer.writeln('data: $line');
      }
    }
    buffer.writeln();
    return buffer.toString();
  }
}

final class AxumSseConnection {
  AxumSseConnection._({
    required AxumServer server,
    required int requestId,
    required this.path,
    required this.rawQuery,
    required Map<String, List<String>> queryParameters,
    required this.headers,
    required Map<String, String> params,
    required this.remoteAddress,
  }) : _server = server,
       id = requestId,
       queryParameters = UnmodifiableMapView<String, List<String>>(
         Map<String, List<String>>.from(queryParameters),
       ),
       params = UnmodifiableMapView<String, String>(Map<String, String>.from(params));

  final AxumServer _server;

  final int id;
  final String path;
  final String rawQuery;
  final Map<String, List<String>> queryParameters;
  final AxumHeaders headers;
  final Map<String, String> params;
  final String? remoteAddress;

  final Completer<void> _done = Completer<void>();
  bool _closed = false;

  Future<void> get done => _done.future;

  bool get isClosed => _closed;

  String? query(String name) {
    final values = queryParameters[name];
    if (values == null || values.isEmpty) {
      return null;
    }
    return values.first;
  }

  Future<void> send(AxumSseEvent event) async {
    if (_closed) {
      throw StateError('SSE connection has already been closed.');
    }
    await _server._bridge.sendSseChunk(server: _server, streamId: id, chunk: event.encode());
  }

  Future<void> sendText(String data, {String? event, String? id, int? retry}) {
    return send(AxumSseEvent(data: data, event: event, id: id, retry: retry));
  }

  Future<void> sendJson(Object? data, {String? event, String? id, int? retry}) {
    return sendText(jsonEncode(data), event: event, id: id, retry: retry);
  }

  Future<void> comment(String value) {
    return send(AxumSseEvent(comment: value));
  }

  Future<void> close() async {
    if (_closed) {
      return;
    }
    _closed = true;
    try {
      await _server._bridge.closeSseResponse(server: _server, streamId: id);
    } finally {
      if (!_done.isCompleted) {
        _done.complete();
      }
    }
  }
}

sealed class AxumWebSocketMessage {
  const AxumWebSocketMessage();
}

final class AxumWebSocketTextMessage extends AxumWebSocketMessage {
  const AxumWebSocketTextMessage(this.text);

  final String text;
}

final class AxumWebSocketBinaryMessage extends AxumWebSocketMessage {
  AxumWebSocketBinaryMessage(Uint8List bytes) : bytes = Uint8List.fromList(bytes);

  final Uint8List bytes;
}

final class AxumWebSocketClose {
  const AxumWebSocketClose({this.code, this.reason});

  final int? code;
  final String? reason;
}

final class AxumWebSocket {
  AxumWebSocket._({
    required AxumServer server,
    required int socketId,
    required this.path,
    required this.rawQuery,
    required Map<String, List<String>> queryParameters,
    required this.headers,
    required Map<String, String> params,
    required this.remoteAddress,
  }) : _server = server,
       id = socketId,
       queryParameters = UnmodifiableMapView<String, List<String>>(
         Map<String, List<String>>.from(queryParameters),
       ),
       params = UnmodifiableMapView<String, String>(Map<String, String>.from(params));

  final AxumServer _server;

  final int id;
  final String path;
  final String rawQuery;
  final Map<String, List<String>> queryParameters;
  final AxumHeaders headers;
  final Map<String, String> params;
  final String? remoteAddress;

  final StreamController<AxumWebSocketMessage> _messages =
      StreamController<AxumWebSocketMessage>.broadcast();
  final Completer<AxumWebSocketClose> _done = Completer<AxumWebSocketClose>();

  Stream<AxumWebSocketMessage> get messages => _messages.stream;

  Future<AxumWebSocketClose> get done => _done.future;

  String? query(String name) {
    final values = queryParameters[name];
    if (values == null || values.isEmpty) {
      return null;
    }
    return values.first;
  }

  Future<void> sendText(String value) {
    return _server._bridge.sendWebSocketFrame(
      server: _server,
      socketId: id,
      frame: <String, Object?>{'kind': 'text', 'text': value},
    );
  }

  Future<void> sendJson(Object? value) => sendText(jsonEncode(value));

  Future<void> sendBytes(Uint8List bytes) {
    return _server._bridge.sendWebSocketFrame(
      server: _server,
      socketId: id,
      frame: <String, Object?>{'kind': 'binary', 'dataBase64': base64Encode(bytes)},
    );
  }

  Future<void> close({int? code, String? reason}) {
    return _server._bridge.sendWebSocketFrame(
      server: _server,
      socketId: id,
      frame: <String, Object?>{
        'kind': 'close',
        ...?code == null ? null : <String, Object?>{'code': code},
        ...?reason == null ? null : <String, Object?>{'reason': reason},
      },
    );
  }

  void _addMessage(AxumWebSocketMessage message) {
    if (_messages.isClosed) {
      return;
    }
    _messages.add(message);
  }

  void _completeClose({int? code, String? reason}) {
    if (!_done.isCompleted) {
      _done.complete(AxumWebSocketClose(code: code, reason: reason));
    }
    if (!_messages.isClosed) {
      unawaited(_messages.close());
    }
  }
}

abstract base class _AxumRouteBase {
  _AxumRouteBase({
    required this.method,
    required this.path,
    required this.docs,
    required this.middleware,
    required List<AxumSchemaComponent> components,
  }) : components = List<AxumSchemaComponent>.unmodifiable(components),
       pattern = _RoutePattern.parse(path);

  final AxumMethod method;
  final String path;
  final AxumRouteDocs? docs;
  final List<AxumMiddleware> middleware;
  final List<AxumSchemaComponent> components;
  final _RoutePattern pattern;

  Future<AxumResponse> handle(
    AxumRequestContext context, {
    required List<AxumMiddleware> globalMiddleware,
  });

  _AxumRouteBase withPrefix(String prefix, {required List<AxumMiddleware> middlewarePrefix});

  String? get requestContentType;

  AxumSchema? get requestSchema;

  String? get responseContentType;

  AxumSchema? get responseSchema;

  Iterable<AxumSchemaComponent> get openApiComponents sync* {
    yield* components;
    final docs = this.docs;
    if (docs != null) {
      final requestBody = docs.requestBody;
      if (requestBody != null) {
        yield* requestBody.components;
      }
      yield* docs.components;
      for (final response in docs.responses.values) {
        yield* response.components;
      }
    }
  }

  Map<String, Object?> buildOpenApiOperation() {
    return _buildOpenApiOperation(
      pattern: pattern,
      docs: docs,
      requestContentType: requestContentType,
      requestSchema: requestSchema,
      responseContentType: responseContentType,
      responseSchema: responseSchema,
    );
  }
}

final class _AxumRawRoute extends _AxumRouteBase {
  _AxumRawRoute({
    required super.method,
    required super.path,
    required super.docs,
    required super.middleware,
    required super.components,
    required this.handler,
  });

  final AxumHandler handler;

  @override
  String? get requestContentType => null;

  @override
  AxumSchema? get requestSchema => null;

  @override
  String? get responseContentType => null;

  @override
  AxumSchema? get responseSchema => null;

  @override
  Future<AxumResponse> handle(
    AxumRequestContext context, {
    required List<AxumMiddleware> globalMiddleware,
  }) {
    return _runMiddlewareChain(
      context: context,
      middleware: <AxumMiddleware>[...globalMiddleware, ...middleware],
      terminal: () async => handler(context),
    );
  }

  @override
  _AxumRawRoute withPrefix(String prefix, {required List<AxumMiddleware> middlewarePrefix}) {
    return _AxumRawRoute(
      method: method,
      path: _joinPaths(prefix, path),
      docs: docs,
      middleware: <AxumMiddleware>[...middlewarePrefix, ...middleware],
      components: components,
      handler: handler,
    );
  }
}

final class _AxumTypedRoute<TRequest, TResponse> extends _AxumRouteBase {
  _AxumTypedRoute({
    required super.method,
    required super.path,
    required super.docs,
    required super.middleware,
    required super.components,
    required this.request,
    required this.response,
    required this.handler,
  });

  final AxumBodyDecoder<TRequest> request;
  final AxumBodyEncoder<TResponse> response;
  final AxumTypedHandler<TRequest, TResponse> handler;

  @override
  String? get requestContentType => request.contentType;

  @override
  AxumSchema? get requestSchema => request.schema;

  @override
  String? get responseContentType => response.contentType;

  @override
  AxumSchema? get responseSchema => response.schema;

  @override
  Iterable<AxumSchemaComponent> get openApiComponents sync* {
    yield* super.openApiComponents;
    if (request case AxumOpenApiComponentProvider provider) {
      yield* provider.components;
    }
    if (response case AxumOpenApiComponentProvider provider) {
      yield* provider.components;
    }
  }

  @override
  Future<AxumResponse> handle(
    AxumRequestContext context, {
    required List<AxumMiddleware> globalMiddleware,
  }) {
    return _runMiddlewareChain(
      context: context,
      middleware: <AxumMiddleware>[...globalMiddleware, ...middleware],
      terminal: () async {
        final decodedRequest = request.decode(context.rawBody);
        final typedContext = context.withBody(decodedRequest);
        final result = await handler(typedContext);
        return response.encode(result);
      },
    );
  }

  @override
  _AxumTypedRoute<TRequest, TResponse> withPrefix(
    String prefix, {
    required List<AxumMiddleware> middlewarePrefix,
  }) {
    return _AxumTypedRoute<TRequest, TResponse>(
      method: method,
      path: _joinPaths(prefix, path),
      docs: docs,
      middleware: <AxumMiddleware>[...middlewarePrefix, ...middleware],
      components: components,
      request: request,
      response: response,
      handler: handler,
    );
  }
}

final class _AxumWebSocketRoute {
  _AxumWebSocketRoute({required this.path, required this.handler})
    : pattern = _RoutePattern.parse(path);

  final String path;
  final AxumWebSocketHandler handler;
  final _RoutePattern pattern;

  _AxumWebSocketRoute withPrefix(String prefix) {
    return _AxumWebSocketRoute(path: _joinPaths(prefix, path), handler: handler);
  }
}

final class _AxumSseRoute {
  _AxumSseRoute({
    required this.path,
    required this.handler,
    required this.docs,
    required List<AxumSchemaComponent> components,
  }) : components = List<AxumSchemaComponent>.unmodifiable(components),
       pattern = _RoutePattern.parse(path);

  final String path;
  final AxumSseHandler handler;
  final AxumRouteDocs? docs;
  final List<AxumSchemaComponent> components;
  final _RoutePattern pattern;

  Iterable<AxumSchemaComponent> get openApiComponents sync* {
    yield* components;
    final docs = this.docs;
    if (docs != null) {
      final requestBody = docs.requestBody;
      if (requestBody != null) {
        yield* requestBody.components;
      }
      yield* docs.components;
      for (final response in docs.responses.values) {
        yield* response.components;
      }
    }
  }

  Map<String, Object?> buildOpenApiOperation() {
    return _buildOpenApiOperation(
      pattern: pattern,
      docs: docs,
      responseContentType: 'text/event-stream; charset=utf-8',
      responseSchema: const AxumSchema.string(description: 'SSE event stream payload.'),
    );
  }

  _AxumSseRoute withPrefix(String prefix) {
    return _AxumSseRoute(
      path: _joinPaths(prefix, path),
      handler: handler,
      docs: docs,
      components: components,
    );
  }
}

final class _AxumOpenApiDocumentBuilder {
  _AxumOpenApiDocumentBuilder(this.config);

  final AxumOpenApi config;
  final Map<String, Map<String, Object?>> _paths = <String, Map<String, Object?>>{};
  final Map<String, Map<String, Object?>> _componentSchemas = <String, Map<String, Object?>>{};

  void addRoute(_AxumRouteBase route) {
    for (final component in route.openApiComponents) {
      _registerComponent(component);
    }

    final pathItem = _paths.putIfAbsent(route.pattern.openApiPath, () => <String, Object?>{});
    pathItem[route.method.value.toLowerCase()] = route.buildOpenApiOperation();
  }

  void addSseRoute(_AxumSseRoute route) {
    for (final component in route.openApiComponents) {
      _registerComponent(component);
    }

    final pathItem = _paths.putIfAbsent(route.pattern.openApiPath, () => <String, Object?>{});
    pathItem[AxumMethod.get.value.toLowerCase()] = route.buildOpenApiOperation();
  }

  Map<String, Object?> build() {
    return <String, Object?>{
      'openapi': '3.1.0',
      'info': config.info.toJson(),
      if (config.servers.isNotEmpty)
        'servers': <Object?>[for (final server in config.servers) server.toJson()],
      'paths': _paths,
      if (_componentSchemas.isNotEmpty)
        'components': <String, Object?>{'schemas': _componentSchemas},
    };
  }

  void _registerComponent(AxumSchemaComponent component) {
    for (final dependency in component.dependencies) {
      _registerComponent(dependency);
    }

    final existing = _componentSchemas[component.name];
    final next = component.toJson();
    if (existing == null) {
      _componentSchemas[component.name] = next;
      return;
    }
    if (!_jsonEquals(existing, next)) {
      throw StateError('Conflicting OpenAPI schema component name: ${component.name}');
    }
  }
}

Map<String, Object?> _buildOpenApiOperation({
  required _RoutePattern pattern,
  required AxumRouteDocs? docs,
  String? requestContentType,
  AxumSchema? requestSchema,
  String? responseContentType,
  AxumSchema? responseSchema,
}) {
  final parameters = <Object?>[
    for (final pathParameter in pattern.pathParameters)
      <String, Object?>{
        'name': pathParameter,
        'in': 'path',
        'required': true,
        'schema': const AxumSchema.string().toJson(),
      },
    if (docs != null)
      for (final parameter in docs.parameters) parameter.toJson(),
  ];

  final responses = <String, Object?>{};
  if (docs != null && docs.responses.isNotEmpty) {
    for (final entry in docs.responses.entries) {
      responses[entry.key.toString()] = entry.value.toJson();
    }
  } else {
    responses['200'] = AxumResponseDocs(
      description: 'Success',
      schema: responseSchema,
      contentType: responseContentType ?? 'application/json',
    ).toJson();
  }

  final requestBody =
      docs?.requestBody?.toJson() ??
      (requestSchema == null
          ? null
          : <String, Object?>{
              'required': true,
              'content': <String, Object?>{
                requestContentType ?? 'application/json': <String, Object?>{
                  'schema': requestSchema.toJson(),
                },
              },
            });

  return <String, Object?>{
    if (docs?.summary != null) 'summary': docs!.summary,
    if (docs?.description != null) 'description': docs!.description,
    if (docs != null && docs.tags.isNotEmpty) 'tags': docs.tags,
    if (docs?.operationId != null) 'operationId': docs!.operationId,
    if (parameters.isNotEmpty) 'parameters': parameters,
    ...?requestBody == null ? null : <String, Object?>{'requestBody': requestBody},
    'responses': responses,
  };
}

final class _RoutePattern {
  _RoutePattern._(this.segments);

  factory _RoutePattern.parse(String path) {
    final normalized = _normalizePath(path);
    final segments = normalized == '/'
        ? const <_RouteSegment>[]
        : normalized.substring(1).split('/').map(_RouteSegment.parse).toList(growable: false);
    return _RoutePattern._(segments);
  }

  final List<_RouteSegment> segments;

  List<String> get pathParameters {
    return <String>[
      for (final segment in segments)
        if (segment case _ParameterSegment(name: final name)) name,
      for (final segment in segments)
        if (segment case _WildcardSegment(name: final name)) name,
    ];
  }

  String get openApiPath {
    if (segments.isEmpty) {
      return '/';
    }
    return '/${segments.map((segment) => segment.openApi).join('/')}';
  }

  Map<String, String>? match(String path) {
    final normalized = _normalizePath(path);
    final pathSegments = normalized == '/' ? const <String>[] : normalized.substring(1).split('/');
    final params = <String, String>{};
    var pathIndex = 0;
    for (var segmentIndex = 0; segmentIndex < segments.length; segmentIndex++) {
      final segment = segments[segmentIndex];
      if (segment is _WildcardSegment) {
        params[segment.name] = pathSegments.skip(pathIndex).join('/');
        return params;
      }
      if (pathIndex >= pathSegments.length) {
        return null;
      }
      final candidate = pathSegments[pathIndex];
      switch (segment) {
        case _StaticSegment(value: final value):
          if (candidate != value) {
            return null;
          }
        case _ParameterSegment(name: final name):
          params[name] = Uri.decodeComponent(candidate);
        case _WildcardSegment():
          throw StateError('Wildcard segments are handled above');
      }
      pathIndex++;
    }
    if (pathIndex != pathSegments.length) {
      return null;
    }
    return params;
  }
}

sealed class _RouteSegment {
  const _RouteSegment();

  factory _RouteSegment.parse(String raw) {
    if (raw.startsWith(':')) {
      return _ParameterSegment(raw.substring(1));
    }
    if (raw.startsWith('*')) {
      return _WildcardSegment(raw.substring(1));
    }
    return _StaticSegment(raw);
  }

  String get openApi;
}

final class _StaticSegment extends _RouteSegment {
  const _StaticSegment(this.value);

  final String value;

  @override
  String get openApi => value;
}

final class _ParameterSegment extends _RouteSegment {
  const _ParameterSegment(this.name);

  final String name;

  @override
  String get openApi => '{$name}';
}

final class _WildcardSegment extends _RouteSegment {
  const _WildcardSegment(this.name);

  final String name;

  @override
  String get openApi => '{$name}';
}

Future<AxumResponse> _runMiddlewareChain({
  required AxumRequestContext context,
  required List<AxumMiddleware> middleware,
  required FutureOr<AxumResponse> Function() terminal,
}) async {
  Future<AxumResponse> runAt(int index) async {
    if (index >= middleware.length) {
      return terminal();
    }
    return middleware[index](context, () => runAt(index + 1));
  }

  return runAt(0);
}

Map<String, List<String>> _stringListMapFromDynamic(Object? value) {
  if (value is! Map<Object?, Object?>) {
    return const <String, List<String>>{};
  }
  final normalized = <String, List<String>>{};
  for (final entry in value.entries) {
    final key = entry.key;
    if (key is! String) {
      continue;
    }
    final rawValues = entry.value;
    if (rawValues is List<Object?>) {
      normalized[key] = <String>[
        for (final item in rawValues)
          if (item is String) item,
      ];
    } else if (rawValues is String) {
      normalized[key] = <String>[rawValues];
    }
  }
  return freezeStringMultiMap(normalized);
}

Map<String, List<String>> _queryParametersFromRaw(String rawQuery) {
  if (rawQuery.isEmpty) {
    return const <String, List<String>>{};
  }
  return UnmodifiableMapView<String, List<String>>(Uri(query: rawQuery).queryParametersAll);
}

Uint8List _decodeBase64Bytes(String? value) {
  if (value == null || value.isEmpty) {
    return Uint8List(0);
  }
  return Uint8List.fromList(base64Decode(value));
}

String _normalizePath(String path) {
  if (path.isEmpty) {
    return '/';
  }
  var normalized = path.startsWith('/') ? path : '/$path';
  if (normalized.length > 1 && normalized.endsWith('/')) {
    normalized = normalized.substring(0, normalized.length - 1);
  }
  return normalized;
}

List<String> _splitSseLines(String value) {
  return value.replaceAll('\r\n', '\n').replaceAll('\r', '\n').split('\n');
}

String _joinPaths(String prefix, String path) {
  final normalizedPrefix = _normalizePath(prefix);
  final normalizedPath = _normalizePath(path);
  if (normalizedPrefix == '/') {
    return normalizedPath;
  }
  if (normalizedPath == '/') {
    return normalizedPrefix;
  }
  return '$normalizedPrefix$normalizedPath';
}

String _redocHtml(String openApiPath) {
  final encodedPath = jsonEncode(openApiPath);
  return '''
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>API Docs</title>
    <style>
      :root {
        color-scheme: light;
        font-family: "SF Pro Text", "Segoe UI", sans-serif;
      }

      html, body {
        margin: 0;
        min-height: 100%;
        background: #f8fafc;
      }

      #redoc-root {
        min-height: 100vh;
      }

      .axum-docs-error {
        box-sizing: border-box;
        max-width: 720px;
        margin: 64px auto;
        padding: 32px;
        border-radius: 20px;
        border: 1px solid #cbd5e1;
        background: white;
        box-shadow: 0 20px 48px rgba(15, 23, 42, 0.08);
      }

      .axum-docs-error h1 {
        margin: 0 0 12px;
        font-size: 28px;
      }

      .axum-docs-error p {
        margin: 0;
        color: #334155;
        line-height: 1.6;
      }

      .axum-docs-error a {
        color: #0f172a;
      }
    </style>
  </head>
  <body>
    <div id="redoc-root"></div>
    <script>
      window.__axumOpenApiPath = $encodedPath;
    </script>
    <script src="https://cdn.redoc.ly/redoc/latest/bundles/redoc.standalone.js"></script>
    <script>
      (function () {
        const mount = document.getElementById('redoc-root');
        const specUrl = new URL(window.__axumOpenApiPath, window.location.href).toString();

        const renderError = function (details) {
          mount.innerHTML = '';
          const panel = document.createElement('main');
          panel.className = 'axum-docs-error';

          const title = document.createElement('h1');
          title.textContent = 'API docs failed to load';
          panel.appendChild(title);

          const message = document.createElement('p');
          message.textContent = details;
          panel.appendChild(message);

          const link = document.createElement('p');
          const anchor = document.createElement('a');
          anchor.href = specUrl;
          anchor.textContent = 'Open the raw OpenAPI document';
          link.appendChild(anchor);
          panel.appendChild(link);

          mount.appendChild(panel);
        };

        if (!window.Redoc || typeof window.Redoc.init !== 'function') {
          renderError('ReDoc did not load from the configured CDN.');
          return;
        }

        window.Redoc.init(specUrl, {}, mount, function (error) {
          if (error) {
            renderError(String(error));
          }
        });
      })();
    </script>
  </body>
</html>
''';
}

bool _jsonEquals(Object? left, Object? right) {
  if (left is Map<Object?, Object?> && right is Map<Object?, Object?>) {
    if (left.length != right.length) {
      return false;
    }
    for (final entry in left.entries) {
      if (!right.containsKey(entry.key)) {
        return false;
      }
      if (!_jsonEquals(entry.value, right[entry.key])) {
        return false;
      }
    }
    return true;
  }
  if (left is List<Object?> && right is List<Object?>) {
    if (left.length != right.length) {
      return false;
    }
    for (var index = 0; index < left.length; index++) {
      if (!_jsonEquals(left[index], right[index])) {
        return false;
      }
    }
    return true;
  }
  return left == right;
}
