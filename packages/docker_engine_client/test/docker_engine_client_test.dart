import 'dart:convert';
import 'dart:typed_data';

import 'package:docker_engine_client/docker_engine_client.dart';
import 'package:test/test.dart';

void main() {
  group('DockerEngineClient', () {
    test('negotiates API version and lists resources', () async {
      final transport = _FakeTransport({
        '/version': _jsonResponse({
          'Version': '27.0.0',
          'ApiVersion': '1.47',
          'MinAPIVersion': '1.24',
          'Os': 'linux',
          'Arch': 'amd64',
        }),
        '/v1.46/containers/json': _jsonResponse([
          {
            'Id': 'container-1',
            'Names': ['/dicto'],
            'Image': 'dicto:latest',
            'ImageID': 'sha256:image',
            'Command': 'server',
            'Created': 1710000000,
            'State': 'running',
            'Status': 'Up 1 hour',
            'Labels': {'app': 'dicto'},
          },
        ]),
        '/v1.46/images/json': _jsonResponse([
          {
            'Id': 'sha256:image',
            'RepoTags': ['dicto:latest'],
            'RepoDigests': <String>[],
            'Created': 1710000000,
            'Size': 1000,
            'Labels': <String, String>{},
          },
        ]),
        '/v1.46/volumes': _jsonResponse({
          'Volumes': [
            {
              'Name': 'data',
              'Driver': 'local',
              'Mountpoint': '/data',
              'Labels': <String, String>{},
              'Scope': 'local',
            },
          ],
        }),
        '/v1.46/networks': _jsonResponse([
          {
            'Id': 'network-1',
            'Name': 'dicto',
            'Driver': 'bridge',
            'Scope': 'local',
            'Internal': false,
            'Attachable': true,
            'Labels': <String, String>{},
          },
        ]),
      });
      final client = DockerEngineClient(transport);

      await client.initialize();

      expect(client.apiVersion.toString(), '1.46');
      expect((await client.listContainers()).single.names, ['/dicto']);
      expect((await client.listImages()).single.repoTags, ['dicto:latest']);
      expect((await client.listVolumes()).single.name, 'data');
      expect((await client.listNetworks()).single.name, 'dicto');
    });

    test('uses typed lifecycle endpoints', () async {
      final transport = _FakeTransport({
        '/version': _jsonResponse({'Version': '27', 'ApiVersion': '1.46'}),
        '/v1.46/containers/dicto/restart': _emptyResponse(204),
        '/v1.46/containers/dicto/stop': _emptyResponse(204),
      });
      final client = DockerEngineClient(transport);
      await client.initialize();

      await client.restartContainer('dicto', timeout: const Duration(seconds: 10));
      await client.stopContainer('dicto');

      expect(transport.requests[1].method, 'POST');
      expect(transport.requests[1].queryParameters, {'t': '10'});
      expect(transport.requests[2].path, '/v1.46/containers/dicto/stop');
    });

    test('decodes fragmented stats and event streams', () async {
      final transport = _FakeTransport(
        {
          '/version': _jsonResponse({'Version': '27', 'ApiVersion': '1.46'}),
        },
        streams: {
          '/v1.46/containers/dicto/stats': DockerStreamResponse(
            statusCode: 200,
            headers: const {'content-type': 'application/json'},
            stream: Stream.fromIterable([
              utf8.encode('{"read":"2024-01-01T00:00:00Z","memory_stats":{"usage":50,'),
              utf8.encode('"limit":100}}\n'),
            ]),
          ),
          '/v1.46/events': DockerStreamResponse(
            statusCode: 200,
            headers: const {'content-type': 'application/x-ndjson'},
            stream: Stream.value(
              utf8.encode(
                '{"Type":"container","Action":"restart","Actor":{"ID":"abc",'
                '"Attributes":{"name":"dicto"}},"time":1710000000}\n',
              ),
            ),
          ),
        },
      );
      final client = DockerEngineClient(transport);
      await client.initialize();

      final stats = await client.watchContainerStats('dicto').first;
      final event = await client.events().first;

      expect(stats.memoryPercent, 50);
      expect(event.action, 'restart');
      expect(event.attributes['name'], 'dicto');
    });

    test('decodes multiplexed log frames split across chunks', () async {
      final frame = Uint8List.fromList([2, 0, 0, 0, 0, 0, 0, 5, ...utf8.encode('error')]);
      final transport = _FakeTransport(
        {
          '/version': _jsonResponse({'Version': '27', 'ApiVersion': '1.46'}),
        },
        streams: {
          '/v1.46/containers/dicto/logs': DockerStreamResponse(
            statusCode: 200,
            headers: const {'content-type': 'application/vnd.docker.multiplexed-stream'},
            stream: Stream.fromIterable([frame.sublist(0, 4), frame.sublist(4)]),
          ),
        },
      );
      final client = DockerEngineClient(transport);
      await client.initialize();

      final entry = await client.containerLogs('dicto').first;

      expect(entry.stream, DockerLogStream.stderr);
      expect(entry.text, 'error');
    });

    test('maps Docker errors', () async {
      final transport = _FakeTransport({
        '/version': _jsonResponse({'Version': '27', 'ApiVersion': '1.46'}),
        '/v1.46/containers/missing/json': _jsonResponse({'message': 'No such container'}, 404),
      });
      final client = DockerEngineClient(transport);
      await client.initialize();

      await expectLater(
        client.inspectContainer('missing'),
        throwsA(
          isA<DockerEngineException>()
              .having((error) => error.statusCode, 'statusCode', 404)
              .having((error) => error.message, 'message', 'No such container'),
        ),
      );
    });
  });
}

final class _FakeTransport implements DockerEngineTransport {
  _FakeTransport(this.responses, {this.streams = const {}});

  final Map<String, DockerResponse> responses;
  final Map<String, DockerStreamResponse> streams;
  final List<DockerRequest> requests = [];

  @override
  Future<DockerResponse> send(DockerRequest request) async {
    requests.add(request);
    return responses[request.path] ?? _jsonResponse({'message': 'No fixture'}, 500);
  }

  @override
  Future<DockerStreamResponse> sendStream(DockerRequest request) async {
    requests.add(request);
    return streams[request.path] ??
        DockerStreamResponse(
          statusCode: 500,
          headers: const {},
          stream: Stream.value(utf8.encode('{"message":"No fixture"}')),
        );
  }

  @override
  Future<void> close() async {}
}

DockerResponse _jsonResponse(Object value, [int statusCode = 200]) => DockerResponse(
  statusCode: statusCode,
  headers: const {'content-type': 'application/json'},
  body: Uint8List.fromList(utf8.encode(jsonEncode(value))),
);

DockerResponse _emptyResponse(int statusCode) =>
    DockerResponse(statusCode: statusCode, headers: const {}, body: Uint8List(0));
