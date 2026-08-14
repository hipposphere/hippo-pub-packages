# observability_query_client

Read-only, server-side Dart clients for Prometheus, Loki, and Grafana Tempo.

The package intentionally does not implement authorization, user-facing query limits, or a generic proxy API. Applications should keep credentials server-side and enforce their own access policy before calling these clients.

```dart
final transport = ObservabilityHttpClient(
  baseUri: Uri.parse('http://prometheus.internal:9090'),
  client: http.Client(),
  headers: {'Authorization': 'Bearer <server-held-token>'},
);
final prometheus = PrometheusClient(transport);

final result = await prometheus.queryRange(
  'sum(rate(http_requests_total[5m]))',
  start: DateTime.now().toUtc().subtract(const Duration(hours: 1)),
  end: DateTime.now().toUtc(),
  step: const Duration(minutes: 1),
);
```

Use `PrometheusClient.metricNames`, `labelNames`, `labelValues`, and `series` to build a bounded metrics explorer.
