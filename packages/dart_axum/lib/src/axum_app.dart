import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'axum_codec.dart';
import 'axum_http.dart';
import 'axum_openapi.dart';
import 'internal/axum_native_bridge.dart';

typedef AxumNext = Future<AxumResponse> Function();
typedef AxumMiddleware = FutureOr<AxumResponse> Function(AxumRequestContext context, AxumNext next);
typedef AxumHandler = FutureOr<AxumResponse> Function(AxumRequestContext context);
typedef AxumTypedHandler<TRequest, TResponse> =
    FutureOr<TResponse> Function(AxumContext<TRequest> context);
typedef AxumWebSocketHandler = FutureOr<void> Function(AxumWebSocket socket);

final class AxumApp {
  AxumApp({this.openApi});

  final AxumOpenApi? openApi;

  final List<AxumMiddleware> _middlewares = <AxumMiddleware>[];
  final List<_AxumRouteBase> _routes = <_AxumRouteBase>[];
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
  }) {
    _routes.add(
      _AxumRawRoute(
        method: method,
        path: path,
        docs: docs,
        middleware: List<AxumMiddleware>.unmodifiable(middleware),
        handler: handler,
      ),
    );
  }

  void routeTyped<TRequest, TResponse>(
    AxumMethod method,
    String path, {
    required AxumBodyDecoder<TRequest> request,
    required AxumBodyEncoder<TResponse> response,
    required AxumTypedHandler<TRequest, TResponse> handler,
    AxumRouteDocs? docs,
    List<AxumMiddleware> middleware = const <AxumMiddleware>[],
  }) {
    _routes.add(
      _AxumTypedRoute<TRequest, TResponse>(
        method: method,
        path: path,
        request: request,
        response: response,
        docs: docs,
        middleware: List<AxumMiddleware>.unmodifiable(middleware),
        handler: handler,
      ),
    );
  }

  void get(
    String path, {
    required AxumHandler handler,
    AxumRouteDocs? docs,
    List<AxumMiddleware> middleware = const <AxumMiddleware>[],
  }) {
    route(AxumMethod.get, path, handler: handler, docs: docs, middleware: middleware);
  }

  void post(
    String path, {
    required AxumHandler handler,
    AxumRouteDocs? docs,
    List<AxumMiddleware> middleware = const <AxumMiddleware>[],
  }) {
    route(AxumMethod.post, path, handler: handler, docs: docs, middleware: middleware);
  }

  void put(
    String path, {
    required AxumHandler handler,
    AxumRouteDocs? docs,
    List<AxumMiddleware> middleware = const <AxumMiddleware>[],
  }) {
    route(AxumMethod.put, path, handler: handler, docs: docs, middleware: middleware);
  }

  void patch(
    String path, {
    required AxumHandler handler,
    AxumRouteDocs? docs,
    List<AxumMiddleware> middleware = const <AxumMiddleware>[],
  }) {
    route(AxumMethod.patch, path, handler: handler, docs: docs, middleware: middleware);
  }

  void delete(
    String path, {
    required AxumHandler handler,
    AxumRouteDocs? docs,
    List<AxumMiddleware> middleware = const <AxumMiddleware>[],
  }) {
    route(AxumMethod.delete, path, handler: handler, docs: docs, middleware: middleware);
  }

  void getTyped<TRequest, TResponse>(
    String path, {
    required AxumBodyDecoder<TRequest> request,
    required AxumBodyEncoder<TResponse> response,
    required AxumTypedHandler<TRequest, TResponse> handler,
    AxumRouteDocs? docs,
    List<AxumMiddleware> middleware = const <AxumMiddleware>[],
  }) {
    routeTyped<TRequest, TResponse>(
      AxumMethod.get,
      path,
      request: request,
      response: response,
      handler: handler,
      docs: docs,
      middleware: middleware,
    );
  }

  void postTyped<TRequest, TResponse>(
    String path, {
    required AxumBodyDecoder<TRequest> request,
    required AxumBodyEncoder<TResponse> response,
    required AxumTypedHandler<TRequest, TResponse> handler,
    AxumRouteDocs? docs,
    List<AxumMiddleware> middleware = const <AxumMiddleware>[],
  }) {
    routeTyped<TRequest, TResponse>(
      AxumMethod.post,
      path,
      request: request,
      response: response,
      handler: handler,
      docs: docs,
      middleware: middleware,
    );
  }

  void putTyped<TRequest, TResponse>(
    String path, {
    required AxumBodyDecoder<TRequest> request,
    required AxumBodyEncoder<TResponse> response,
    required AxumTypedHandler<TRequest, TResponse> handler,
    AxumRouteDocs? docs,
    List<AxumMiddleware> middleware = const <AxumMiddleware>[],
  }) {
    routeTyped<TRequest, TResponse>(
      AxumMethod.put,
      path,
      request: request,
      response: response,
      handler: handler,
      docs: docs,
      middleware: middleware,
    );
  }

  void patchTyped<TRequest, TResponse>(
    String path, {
    required AxumBodyDecoder<TRequest> request,
    required AxumBodyEncoder<TResponse> response,
    required AxumTypedHandler<TRequest, TResponse> handler,
    AxumRouteDocs? docs,
    List<AxumMiddleware> middleware = const <AxumMiddleware>[],
  }) {
    routeTyped<TRequest, TResponse>(
      AxumMethod.patch,
      path,
      request: request,
      response: response,
      handler: handler,
      docs: docs,
      middleware: middleware,
    );
  }

  void deleteTyped<TRequest, TResponse>(
    String path, {
    required AxumBodyDecoder<TRequest> request,
    required AxumBodyEncoder<TResponse> response,
    required AxumTypedHandler<TRequest, TResponse> handler,
    AxumRouteDocs? docs,
    List<AxumMiddleware> middleware = const <AxumMiddleware>[],
  }) {
    routeTyped<TRequest, TResponse>(
      AxumMethod.delete,
      path,
      request: request,
      response: response,
      handler: handler,
      docs: docs,
      middleware: middleware,
    );
  }

  void ws(String path, AxumWebSocketHandler handler) {
    _webSocketRoutes.add(_AxumWebSocketRoute(path: path, handler: handler));
  }

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
    final paths = <String, Map<String, Object?>>{};
    for (final route in _routes) {
      final pathItem = paths.putIfAbsent(route.pattern.openApiPath, () => <String, Object?>{});
      pathItem[route.method.value.toLowerCase()] = route.buildOpenApiOperation();
    }

    return {
      'openapi': '3.1.0',
      'info': config.info.toJson(),
      if (config.servers.isNotEmpty)
        'servers': <Object?>[for (final server in config.servers) server.toJson()],
      'paths': paths,
    };
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
  final Map<int, AxumWebSocket> _webSockets = <int, AxumWebSocket>{};
  final StreamController<String> _errors = StreamController<String>.broadcast();

  final int id;
  final String host;
  final int port;

  AxumApp get app => _app;

  Uri get baseUri => Uri(scheme: 'http', host: host, port: port);

  Stream<String> get errors => _errors.stream;

  Future<void> close() async {
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
      response = await _maybeHandleBuiltinRoute(context) ?? await _dispatchRoute(context);
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
  }) : pattern = _RoutePattern.parse(path);

  final AxumMethod method;
  final String path;
  final AxumRouteDocs? docs;
  final List<AxumMiddleware> middleware;
  final _RoutePattern pattern;

  Future<AxumResponse> handle(
    AxumRequestContext context, {
    required List<AxumMiddleware> globalMiddleware,
  });

  String? get requestContentType;

  AxumSchema? get requestSchema;

  String? get responseContentType;

  AxumSchema? get responseSchema;

  Map<String, Object?> buildOpenApiOperation() {
    final docs = this.docs;
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

    final requestBody = requestSchema == null
        ? null
        : <String, Object?>{
            'required': true,
            'content': <String, Object?>{
              requestContentType ?? 'application/json': <String, Object?>{
                'schema': requestSchema!.toJson(),
              },
            },
          };

    return {
      if (docs?.summary != null) 'summary': docs!.summary,
      if (docs?.description != null) 'description': docs!.description,
      if (docs != null && docs.tags.isNotEmpty) 'tags': docs.tags,
      if (docs?.operationId != null) 'operationId': docs!.operationId,
      if (parameters.isNotEmpty) 'parameters': parameters,
      ...?requestBody == null ? null : <String, Object?>{'requestBody': requestBody},
      'responses': responses,
    };
  }
}

final class _AxumRawRoute extends _AxumRouteBase {
  _AxumRawRoute({
    required super.method,
    required super.path,
    required super.docs,
    required super.middleware,
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
}

final class _AxumTypedRoute<TRequest, TResponse> extends _AxumRouteBase {
  _AxumTypedRoute({
    required super.method,
    required super.path,
    required super.docs,
    required super.middleware,
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
}

final class _AxumWebSocketRoute {
  _AxumWebSocketRoute({required this.path, required this.handler})
    : pattern = _RoutePattern.parse(path);

  final String path;
  final AxumWebSocketHandler handler;
  final _RoutePattern pattern;
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

String _redocHtml(String openApiPath) {
  return '''
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>API Docs</title>
    <style>
      body { margin: 0; padding: 0; }
    </style>
  </head>
  <body>
    <redoc spec-url="$openApiPath"></redoc>
    <script src="https://cdn.jsdelivr.net/npm/redoc@next/bundles/redoc.standalone.js"></script>
  </body>
</html>
''';
}
