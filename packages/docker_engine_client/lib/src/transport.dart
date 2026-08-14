import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

final class DockerRequest {
  const DockerRequest({
    required this.method,
    required this.path,
    this.queryParameters = const {},
    this.headers = const {},
    this.body,
  });

  final String method;
  final String path;
  final Map<String, String> queryParameters;
  final Map<String, String> headers;
  final List<int>? body;
}

final class DockerResponse {
  const DockerResponse({required this.statusCode, required this.headers, required this.body});

  final int statusCode;
  final Map<String, String> headers;
  final Uint8List body;
}

final class DockerStreamResponse {
  const DockerStreamResponse({
    required this.statusCode,
    required this.headers,
    required this.stream,
  });

  final int statusCode;
  final Map<String, String> headers;
  final Stream<List<int>> stream;
}

abstract interface class DockerEngineTransport {
  Future<DockerResponse> send(DockerRequest request);
  Future<DockerStreamResponse> sendStream(DockerRequest request);
  Future<void> close();
}

/// Docker HTTP transport supporting Unix domain sockets and TCP/TLS endpoints.
final class DockerIoTransport implements DockerEngineTransport {
  DockerIoTransport._({
    required Uri baseUri,
    required this.client,
    required Map<String, String> headers,
    required this.timeout,
  }) : _baseUri = _normalizeBaseUri(baseUri),
       _headers = Map.unmodifiable(headers);

  factory DockerIoTransport.unixSocket({
    String socketPath = '/var/run/docker.sock',
    Map<String, String> headers = const {},
    Duration timeout = const Duration(seconds: 30),
  }) {
    final client = HttpClient();
    client.connectionFactory = (uri, proxyHost, proxyPort) {
      final address = InternetAddress(socketPath, type: InternetAddressType.unix);
      return Socket.startConnect(address, 0);
    };
    return DockerIoTransport._(
      baseUri: Uri.parse('http://localhost/'),
      client: client,
      headers: headers,
      timeout: timeout,
    );
  }

  factory DockerIoTransport.tcp({
    required Uri baseUri,
    SecurityContext? securityContext,
    Map<String, String> headers = const {},
    Duration timeout = const Duration(seconds: 30),
  }) => DockerIoTransport._(
    baseUri: baseUri,
    client: HttpClient(context: securityContext),
    headers: headers,
    timeout: timeout,
  );

  final Uri _baseUri;
  final HttpClient client;
  final Map<String, String> _headers;
  final Duration timeout;

  @override
  Future<DockerResponse> send(DockerRequest request) async {
    final response = await _open(request);
    final builder = BytesBuilder(copy: false);
    await for (final bytes in response) {
      builder.add(bytes);
    }
    return DockerResponse(
      statusCode: response.statusCode,
      headers: _responseHeaders(response),
      body: builder.takeBytes(),
    );
  }

  @override
  Future<DockerStreamResponse> sendStream(DockerRequest request) async {
    final response = await _open(request);
    return DockerStreamResponse(
      statusCode: response.statusCode,
      headers: _responseHeaders(response),
      stream: response,
    );
  }

  Future<HttpClientResponse> _open(DockerRequest request) async {
    final base = _baseUri.resolve(request.path.replaceFirst(RegExp(r'^/'), ''));
    final uri = base.replace(queryParameters: request.queryParameters);
    final outgoing = await client.openUrl(request.method, uri).timeout(timeout);
    for (final entry in _headers.entries) {
      outgoing.headers.set(entry.key, entry.value);
    }
    for (final entry in request.headers.entries) {
      outgoing.headers.set(entry.key, entry.value);
    }
    if (request.body case final body?) outgoing.add(body);
    return outgoing.close().timeout(timeout);
  }

  @override
  Future<void> close() async => client.close(force: true);
}

Uri _normalizeBaseUri(Uri uri) => uri.path.endsWith('/') ? uri : uri.replace(path: '${uri.path}/');

Map<String, String> _responseHeaders(HttpClientResponse response) {
  final result = <String, String>{};
  response.headers.forEach((name, values) => result[name.toLowerCase()] = values.join(','));
  return result;
}
