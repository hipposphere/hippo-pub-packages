import 'dart:convert';
import 'dart:typed_data';

import 'axum_app.dart';
import 'axum_http.dart';

extension AxumMultipartRequestContext on AxumRequestContext {
  AxumMultipartFormData multipartFormData() {
    return AxumMultipartFormData.parse(headers: headers, body: rawBody.bytes);
  }
}

final class AxumMultipartFormData {
  AxumMultipartFormData._(List<AxumMultipartPart> parts)
    : parts = List<AxumMultipartPart>.unmodifiable(parts);

  factory AxumMultipartFormData.parse({required AxumHeaders headers, required Uint8List body}) {
    final contentType = headers.first('content-type');
    final boundary = _parseBoundary(contentType);
    final raw = latin1.decode(body);
    final marker = '--$boundary';

    if (!raw.startsWith(marker)) {
      throw FormatException('Multipart body did not start with the declared boundary.');
    }

    final parts = <AxumMultipartPart>[];
    var cursor = 0;
    while (true) {
      if (!raw.startsWith(marker, cursor)) {
        throw FormatException('Malformed multipart boundary near offset $cursor.');
      }
      cursor += marker.length;

      if (raw.startsWith('--', cursor)) {
        break;
      }

      if (raw.startsWith('\r\n', cursor)) {
        cursor += 2;
      } else if (raw.startsWith('\n', cursor)) {
        cursor += 1;
      } else {
        throw FormatException('Expected a newline after the multipart boundary.');
      }

      final headerEnd = raw.indexOf('\r\n\r\n', cursor);
      if (headerEnd == -1) {
        throw FormatException('Multipart part headers were not terminated correctly.');
      }
      final headerBlock = raw.substring(cursor, headerEnd);
      final partHeaders = _parsePartHeaders(headerBlock);
      cursor = headerEnd + 4;

      final nextBoundary = raw.indexOf('\r\n$marker', cursor);
      if (nextBoundary == -1) {
        throw FormatException('Multipart part body was not followed by a boundary.');
      }

      final dataText = raw.substring(cursor, nextBoundary);
      final part = AxumMultipartPart._(
        headers: AxumHeaders(partHeaders),
        bytes: Uint8List.fromList(latin1.encode(dataText)),
      );
      parts.add(part);
      cursor = nextBoundary + 2;
    }

    return AxumMultipartFormData._(parts);
  }

  final List<AxumMultipartPart> parts;

  List<AxumMultipartPart> byName(String name) {
    return <AxumMultipartPart>[
      for (final part in parts)
        if (part.name == name) part,
    ];
  }

  AxumMultipartPart? firstPart(String name) {
    for (final part in parts) {
      if (part.name == name) {
        return part;
      }
    }
    return null;
  }

  String? field(String name, {Encoding encoding = utf8}) {
    final part = firstPart(name);
    if (part == null || part.isFile) {
      return null;
    }
    return part.text(encoding: encoding);
  }

  String requireField(String name, {Encoding encoding = utf8}) {
    final value = field(name, encoding: encoding);
    if (value == null) {
      throw FormatException('Missing multipart field "$name".');
    }
    return value;
  }

  List<AxumMultipartPart> files(String name) {
    return <AxumMultipartPart>[
      for (final part in parts)
        if (part.name == name && part.isFile) part,
    ];
  }
}

final class AxumMultipartPart {
  AxumMultipartPart._({required this.headers, required Uint8List bytes})
    : bytes = Uint8List.fromList(bytes);

  final AxumHeaders headers;
  final Uint8List bytes;

  bool get isFile => filename != null;

  String? get contentType => headers.first('content-type');

  String? get name => _contentDispositionParameters['name'];

  String? get filename => _contentDispositionParameters['filename'];

  String text({Encoding encoding = utf8}) => encoding.decode(bytes);

  Map<String, String> get _contentDispositionParameters {
    return _parseContentDisposition(headers.first('content-disposition'));
  }
}

String _parseBoundary(String? contentType) {
  if (contentType == null) {
    throw FormatException('Missing Content-Type header for multipart request.');
  }
  final segments = contentType.split(';');
  if (segments.isEmpty || segments.first.trim().toLowerCase() != 'multipart/form-data') {
    throw FormatException('Expected Content-Type "multipart/form-data".');
  }
  for (final segment in segments.skip(1)) {
    final trimmed = segment.trim();
    final separatorIndex = trimmed.indexOf('=');
    if (separatorIndex == -1) {
      continue;
    }
    final key = trimmed.substring(0, separatorIndex).trim().toLowerCase();
    if (key != 'boundary') {
      continue;
    }
    final rawValue = trimmed.substring(separatorIndex + 1).trim();
    return _stripQuotes(rawValue);
  }
  throw FormatException('Missing multipart boundary parameter.');
}

Map<String, List<String>> _parsePartHeaders(String headerBlock) {
  final headers = <String, List<String>>{};
  for (final line in headerBlock.split('\r\n')) {
    final separatorIndex = line.indexOf(':');
    if (separatorIndex == -1) {
      continue;
    }
    final name = line.substring(0, separatorIndex).trim().toLowerCase();
    final value = line.substring(separatorIndex + 1).trim();
    headers.putIfAbsent(name, () => <String>[]).add(value);
  }
  return headers;
}

Map<String, String> _parseContentDisposition(String? headerValue) {
  if (headerValue == null || headerValue.isEmpty) {
    return const <String, String>{};
  }
  final result = <String, String>{};
  for (final segment in headerValue.split(';').skip(1)) {
    final trimmed = segment.trim();
    final separatorIndex = trimmed.indexOf('=');
    if (separatorIndex == -1) {
      continue;
    }
    final key = trimmed.substring(0, separatorIndex).trim().toLowerCase();
    final value = trimmed.substring(separatorIndex + 1).trim();
    result[key] = _stripQuotes(value);
  }
  return result;
}

String _stripQuotes(String value) {
  if (value.length >= 2 && value.startsWith('"') && value.endsWith('"')) {
    return value.substring(1, value.length - 1);
  }
  return value;
}
