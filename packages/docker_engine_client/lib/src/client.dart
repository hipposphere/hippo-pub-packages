import 'dart:convert';

import 'errors.dart';
import 'models.dart';
import 'stream_codecs.dart';
import 'transport.dart';

final class DockerEngineClient {
  DockerEngineClient(
    this.transport, {
    DockerApiVersion? maximumApiVersion,
    DockerApiVersion? minimumApiVersion,
  }) : maximumApiVersion = maximumApiVersion ?? const DockerApiVersion(1, 46),
       minimumApiVersion = minimumApiVersion ?? const DockerApiVersion(1, 40);

  final DockerEngineTransport transport;
  final DockerApiVersion maximumApiVersion;
  final DockerApiVersion minimumApiVersion;

  DockerEngineVersion? _engineVersion;
  DockerApiVersion? _apiVersion;

  DockerEngineVersion get engineVersion =>
      _engineVersion ?? (throw StateError('Call initialize() before using DockerEngineClient.'));
  DockerApiVersion get apiVersion =>
      _apiVersion ?? (throw StateError('Call initialize() before using DockerEngineClient.'));

  Future<DockerEngineVersion> initialize() async {
    final version = DockerEngineVersion.fromJson(await _getObject('/version', versioned: false));
    final engineMaximum = DockerApiVersion.parse(version.apiVersion);
    if (engineMaximum.compareTo(minimumApiVersion) < 0) {
      throw DockerApiVersionException(
        clientMinimum: minimumApiVersion,
        engineMaximum: engineMaximum,
      );
    }
    _engineVersion = version;
    _apiVersion = engineMaximum.compareTo(maximumApiVersion) < 0
        ? engineMaximum
        : maximumApiVersion;
    return version;
  }

  Future<bool> ping() async {
    final response = await transport.send(const DockerRequest(method: 'GET', path: '/_ping'));
    _ensureSuccess(response.statusCode, response.body, '/_ping');
    return utf8.decode(response.body).trim() == 'OK';
  }

  Future<List<DockerContainerSummary>> listContainers({
    bool all = false,
    int? limit,
    String? filters,
  }) async => (await _getList(
    '/containers/json',
    query: {
      'all': '$all',
      if (limit != null) 'limit': '$limit',
      ..._optionalQuery('filters', filters),
    },
  )).map((item) => DockerContainerSummary.fromJson(jsonObject(item))).toList(growable: false);

  Future<DockerContainer> inspectContainer(String id) async =>
      DockerContainer.fromJson(await _getObject('/containers/${_segment(id)}/json'));

  Future<DockerContainerStats> containerStats(String id) async => DockerContainerStats.fromJson(
    await _getObject('/containers/${_segment(id)}/stats', query: const {'stream': 'false'}),
  );

  Stream<DockerContainerStats> watchContainerStats(String id) async* {
    final response = await _stream(
      'GET',
      '/containers/${_segment(id)}/stats',
      query: const {'stream': 'true', 'one-shot': 'false'},
    );
    yield* decodeJsonLines(response.stream).map(DockerContainerStats.fromJson);
  }

  Stream<DockerLogEntry> containerLogs(
    String id, {
    DockerLogOptions options = const DockerLogOptions(),
  }) async* {
    final response = await _stream(
      'GET',
      '/containers/${_segment(id)}/logs',
      query: {
        'follow': '${options.follow}',
        'stdout': '${options.stdout}',
        'stderr': '${options.stderr}',
        'timestamps': '${options.timestamps}',
        if (options.since != null)
          'since': '${options.since!.toUtc().millisecondsSinceEpoch ~/ 1000}',
        if (options.until != null)
          'until': '${options.until!.toUtc().millisecondsSinceEpoch ~/ 1000}',
        if (options.tail != null) 'tail': '${options.tail}',
      },
    );
    final contentType = response.headers['content-type'] ?? '';
    if (contentType.contains('multiplexed-stream')) {
      yield* decodeDockerMultiplexedLogs(response.stream);
      return;
    }
    await for (final bytes in response.stream) {
      yield DockerLogEntry(stream: DockerLogStream.stdout, bytes: bytes);
    }
  }

  Future<void> startContainer(String id) => _postEmpty('/containers/${_segment(id)}/start');
  Future<void> stopContainer(String id, {Duration? timeout}) => _postEmpty(
    '/containers/${_segment(id)}/stop',
    query: {if (timeout != null) 't': '${timeout.inSeconds}'},
  );
  Future<void> restartContainer(String id, {Duration? timeout}) => _postEmpty(
    '/containers/${_segment(id)}/restart',
    query: {if (timeout != null) 't': '${timeout.inSeconds}'},
  );
  Future<void> pauseContainer(String id) => _postEmpty('/containers/${_segment(id)}/pause');
  Future<void> unpauseContainer(String id) => _postEmpty('/containers/${_segment(id)}/unpause');
  Future<void> killContainer(String id, {String? signal}) =>
      _postEmpty('/containers/${_segment(id)}/kill', query: _optionalQuery('signal', signal));

  Future<DockerWaitResult> waitForContainer(String id, {String condition = 'not-running'}) async =>
      DockerWaitResult.fromJson(
        await _postObject('/containers/${_segment(id)}/wait', query: {'condition': condition}),
      );

  Future<List<DockerImageSummary>> listImages({bool all = false, String? filters}) async =>
      (await _getList(
        '/images/json',
        query: {'all': '$all', ..._optionalQuery('filters', filters)},
      )).map((item) => DockerImageSummary.fromJson(jsonObject(item))).toList(growable: false);

  Future<DockerImage> inspectImage(String id) async =>
      DockerImage.fromJson(await _getObject('/images/${_segment(id)}/json'));

  Future<List<DockerVolume>> listVolumes({String? filters}) async {
    final response = await _getObject('/volumes', query: _optionalQuery('filters', filters));
    return jsonList(
      response['Volumes'] ?? const [],
      source: 'Docker volumes',
    ).map((item) => DockerVolume.fromJson(jsonObject(item))).toList(growable: false);
  }

  Future<DockerVolume> inspectVolume(String name) async =>
      DockerVolume.fromJson(await _getObject('/volumes/${_segment(name)}'));

  Future<List<DockerNetwork>> listNetworks({String? filters}) async => (await _getList(
    '/networks',
    query: _optionalQuery('filters', filters),
  )).map((item) => DockerNetwork.fromJson(jsonObject(item))).toList(growable: false);

  Future<DockerNetwork> inspectNetwork(String id) async =>
      DockerNetwork.fromJson(await _getObject('/networks/${_segment(id)}'));

  Stream<DockerEvent> events({
    DockerEventFilter filter = const DockerEventFilter(),
    DateTime? since,
    DateTime? until,
  }) async* {
    final response = await _stream(
      'GET',
      '/events',
      query: {
        if (!filter.isEmpty) 'filters': filter.toJson(),
        if (since != null) 'since': '${since.toUtc().millisecondsSinceEpoch ~/ 1000}',
        if (until != null) 'until': '${until.toUtc().millisecondsSinceEpoch ~/ 1000}',
      },
    );
    yield* decodeJsonLines(response.stream).map(DockerEvent.fromJson);
  }

  Future<void> close() => transport.close();

  Future<JsonObject> _getObject(
    String path, {
    Map<String, String> query = const {},
    bool versioned = true,
  }) async => jsonObject(await _jsonRequest('GET', path, query: query, versioned: versioned));

  Future<List<Object?>> _getList(String path, {Map<String, String> query = const {}}) async =>
      jsonList(await _jsonRequest('GET', path, query: query));

  Future<JsonObject> _postObject(String path, {Map<String, String> query = const {}}) async =>
      jsonObject(await _jsonRequest('POST', path, query: query));

  Future<void> _postEmpty(String path, {Map<String, String> query = const {}}) async {
    final response = await transport.send(
      DockerRequest(method: 'POST', path: _versioned(path), queryParameters: query),
    );
    _ensureSuccess(response.statusCode, response.body, path);
  }

  Future<Object?> _jsonRequest(
    String method,
    String path, {
    Map<String, String> query = const {},
    bool versioned = true,
  }) async {
    final requestPath = versioned ? _versioned(path) : path;
    final response = await transport.send(
      DockerRequest(method: method, path: requestPath, queryParameters: query),
    );
    _ensureSuccess(response.statusCode, response.body, requestPath);
    if (response.body.isEmpty) return null;
    return jsonDecode(utf8.decode(response.body));
  }

  Future<DockerStreamResponse> _stream(
    String method,
    String path, {
    Map<String, String> query = const {},
  }) async {
    final requestPath = _versioned(path);
    final response = await transport.sendStream(
      DockerRequest(method: method, path: requestPath, queryParameters: query),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) return response;
    final bytes = <int>[];
    await for (final chunk in response.stream) {
      bytes.addAll(chunk);
    }
    _ensureSuccess(response.statusCode, bytes, requestPath);
    throw StateError('Unreachable');
  }

  String _versioned(String path) => '/v$apiVersion${path.startsWith('/') ? path : '/$path'}';
}

void _ensureSuccess(int statusCode, List<int> body, String path) {
  if (statusCode >= 200 && statusCode < 300) return;
  Object? decoded;
  try {
    decoded = body.isEmpty ? null : jsonDecode(utf8.decode(body));
  } on FormatException {
    decoded = utf8.decode(body, allowMalformed: true);
  }
  final message = decoded is Map && decoded['message'] != null
      ? decoded['message'].toString()
      : 'Docker Engine request failed.';
  throw DockerEngineException(message: message, statusCode: statusCode, path: path, body: decoded);
}

String _segment(String value) => Uri.encodeComponent(value);

Map<String, String> _optionalQuery(String key, String? value) =>
    value == null ? const {} : {key: value};
