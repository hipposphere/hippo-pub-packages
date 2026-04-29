part of 'views.dart';

String _endpointUrl(String baseUrl, String routeBasePath, String path) {
  final trimmedBase = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
  return '$trimmedBase${_joinPath(routeBasePath, path)}';
}

String _joinPath(String basePath, String path) {
  final normalizedBase = _normalizeBasePath(basePath);
  final normalizedPath = path.startsWith('/') ? path : '/$path';
  if (normalizedBase.isEmpty) {
    return normalizedPath;
  }
  return '$normalizedBase$normalizedPath';
}

String _normalizeBasePath(String value) {
  var normalized = value.trim();
  if (normalized.isEmpty || normalized == '/') {
    return '';
  }
  if (!normalized.startsWith('/')) {
    normalized = '/$normalized';
  }
  while (normalized.endsWith('/') && normalized.length > 1) {
    normalized = normalized.substring(0, normalized.length - 1);
  }
  return normalized;
}
