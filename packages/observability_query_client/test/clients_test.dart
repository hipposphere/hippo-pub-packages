import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:observability_query_client/observability_query_client.dart';
import 'package:test/test.dart';

void main() {
  group('PrometheusClient', () {
    test('queries a range and parses a matrix response', () async {
      late Uri requestUri;
      final client = PrometheusClient(
        ObservabilityHttpClient(
          baseUri: Uri.parse('http://prometheus:9090'),
          client: MockClient((request) async {
            requestUri = request.url;
            return http.Response(
              jsonEncode({
                'status': 'success',
                'data': {
                  'resultType': 'matrix',
                  'result': [
                    {
                      'metric': {'job': 'dicto'},
                      'values': [
                        [1710000000, '2.5'],
                      ],
                    },
                  ],
                },
              }),
              200,
            );
          }),
        ),
      );

      final result = await client.queryRange(
        'sum(rate(dicto_requests_total[5m]))',
        start: DateTime.utc(2024, 3, 9, 16),
        end: DateTime.utc(2024, 3, 9, 17),
        step: const Duration(minutes: 1),
      );

      expect(requestUri.path, '/api/v1/query_range');
      expect(requestUri.queryParameters['query'], 'sum(rate(dicto_requests_total[5m]))');
      expect(requestUri.queryParameters['step'], '60000ms');
      expect(result.type, PrometheusResultType.matrix);
      expect(result.series.single.labels, {'job': 'dicto'});
      expect(result.series.single.values.single.value, '2.5');
    });

    test('discovers metric names', () async {
      final client = PrometheusClient(
        ObservabilityHttpClient(
          baseUri: Uri.parse('http://prometheus:9090'),
          client: MockClient((request) async {
            expect(request.url.path, '/api/v1/label/__name__/values');
            return http.Response(
              jsonEncode({
                'status': 'success',
                'data': ['up', 'dicto_requests_total'],
              }),
              200,
            );
          }),
        ),
      );

      expect(await client.metricNames(), ['up', 'dicto_requests_total']);
    });
  });

  test('Loki query range parses streams', () async {
    final client = LokiClient(
      ObservabilityHttpClient(
        baseUri: Uri.parse('http://loki:3100'),
        client: MockClient((request) async {
          expect(request.url.path, '/loki/api/v1/query_range');
          expect(request.url.queryParameters['direction'], 'BACKWARD');
          return http.Response(
            jsonEncode({
              'status': 'success',
              'data': {
                'resultType': 'streams',
                'result': [
                  {
                    'stream': {'service_name': 'dicto'},
                    'values': [
                      ['1710000000000000000', 'request failed'],
                    ],
                  },
                ],
              },
            }),
            200,
          );
        }),
      ),
    );

    final result = await client.queryRange(
      '{service_name="dicto"}',
      start: DateTime.utc(2024, 3, 9, 16),
      end: DateTime.utc(2024, 3, 9, 17),
    );

    expect(result.streams.single.entries.single.line, 'request failed');
  });

  test('Tempo search uses TraceQL and parses trace summaries', () async {
    final client = TempoClient(
      ObservabilityHttpClient(
        baseUri: Uri.parse('http://tempo:3200'),
        client: MockClient((request) async {
          expect(request.url.path, '/api/search');
          expect(request.url.queryParameters['q'], '{ resource.service.name = "dicto" }');
          return http.Response(
            jsonEncode({
              'traces': [
                {
                  'traceID': 'abc123',
                  'rootServiceName': 'dicto-server',
                  'rootTraceName': 'POST /transcribe',
                  'startTimeUnixNano': '1710000000000000000',
                  'durationMs': 125,
                },
              ],
            }),
            200,
          );
        }),
      ),
    );

    final result = await client.search('{ resource.service.name = "dicto" }');

    expect(result.traces.single.traceId, 'abc123');
    expect(result.traces.single.durationMs, 125);
  });

  test('Tempo tag discovery qualifies returned tag names by scope', () async {
    final client = TempoClient(
      ObservabilityHttpClient(
        baseUri: Uri.parse('http://tempo:3200'),
        client: MockClient((request) async {
          expect(request.url.path, '/api/v2/search/tags');
          return http.Response(
            jsonEncode({
              'scopes': [
                {
                  'name': 'resource',
                  'tags': ['service.name'],
                },
                {
                  'name': 'span',
                  'tags': ['http.method'],
                },
                {
                  'name': 'intrinsic',
                  'tags': ['duration'],
                },
              ],
            }),
            200,
          );
        }),
      ),
    );

    expect(await client.tagNames(), ['resource.service.name', 'span.http.method', 'duration']);
  });
}
