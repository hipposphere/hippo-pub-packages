import 'dart:convert';

typedef JsonObject = Map<String, Object?>;

final class DockerEngineVersion {
  const DockerEngineVersion({
    required this.version,
    required this.apiVersion,
    required this.minimumApiVersion,
    required this.os,
    required this.architecture,
    required this.raw,
  });

  factory DockerEngineVersion.fromJson(JsonObject json) => DockerEngineVersion(
    version: _string(json, 'Version'),
    apiVersion: _string(json, 'ApiVersion'),
    minimumApiVersion: json['MinAPIVersion']?.toString(),
    os: json['Os']?.toString(),
    architecture: json['Arch']?.toString(),
    raw: json,
  );

  final String version;
  final String apiVersion;
  final String? minimumApiVersion;
  final String? os;
  final String? architecture;
  final JsonObject raw;
}

final class DockerContainerSummary {
  const DockerContainerSummary({
    required this.id,
    required this.names,
    required this.image,
    required this.imageId,
    required this.command,
    required this.created,
    required this.state,
    required this.status,
    required this.labels,
    required this.raw,
  });

  factory DockerContainerSummary.fromJson(JsonObject json) => DockerContainerSummary(
    id: _string(json, 'Id'),
    names: _strings(json['Names']),
    image: _string(json, 'Image'),
    imageId: _string(json, 'ImageID'),
    command: _string(json, 'Command'),
    created: DateTime.fromMillisecondsSinceEpoch(_integer(json, 'Created') * 1000, isUtc: true),
    state: _string(json, 'State'),
    status: _string(json, 'Status'),
    labels: _stringMap(json['Labels']),
    raw: json,
  );

  final String id;
  final List<String> names;
  final String image;
  final String imageId;
  final String command;
  final DateTime created;
  final String state;
  final String status;
  final Map<String, String> labels;
  final JsonObject raw;
}

final class DockerContainer {
  const DockerContainer({
    required this.id,
    required this.name,
    required this.created,
    required this.path,
    required this.state,
    required this.config,
    required this.raw,
  });

  factory DockerContainer.fromJson(JsonObject json) => DockerContainer(
    id: _string(json, 'Id'),
    name: _string(json, 'Name'),
    created: DateTime.tryParse(_string(json, 'Created'))?.toUtc(),
    path: json['Path']?.toString(),
    state: _objectOrEmpty(json['State']),
    config: _objectOrEmpty(json['Config']),
    raw: json,
  );

  final String id;
  final String name;
  final DateTime? created;
  final String? path;
  final JsonObject state;
  final JsonObject config;
  final JsonObject raw;
}

final class DockerContainerStats {
  const DockerContainerStats({required this.readAt, required this.raw});

  factory DockerContainerStats.fromJson(JsonObject json) => DockerContainerStats(
    readAt: DateTime.tryParse(json['read']?.toString() ?? '')?.toUtc(),
    raw: json,
  );

  final DateTime? readAt;
  final JsonObject raw;

  int? get memoryUsageBytes => _nestedInt(raw, const ['memory_stats', 'usage']);
  int? get memoryLimitBytes => _nestedInt(raw, const ['memory_stats', 'limit']);

  double? get memoryPercent {
    final usage = memoryUsageBytes;
    final limit = memoryLimitBytes;
    if (usage == null || limit == null || limit == 0) return null;
    return usage / limit * 100;
  }

  double? get cpuPercent {
    final total = _nestedInt(raw, const ['cpu_stats', 'cpu_usage', 'total_usage']);
    final previousTotal = _nestedInt(raw, const ['precpu_stats', 'cpu_usage', 'total_usage']);
    final system = _nestedInt(raw, const ['cpu_stats', 'system_cpu_usage']);
    final previousSystem = _nestedInt(raw, const ['precpu_stats', 'system_cpu_usage']);
    final onlineCpus = _nestedInt(raw, const ['cpu_stats', 'online_cpus']) ?? 1;
    if (total == null || previousTotal == null || system == null || previousSystem == null) {
      return null;
    }
    final cpuDelta = total - previousTotal;
    final systemDelta = system - previousSystem;
    if (cpuDelta < 0 || systemDelta <= 0) return null;
    return cpuDelta / systemDelta * onlineCpus * 100;
  }
}

final class DockerImageSummary {
  const DockerImageSummary({
    required this.id,
    required this.repoTags,
    required this.repoDigests,
    required this.created,
    required this.sizeBytes,
    required this.labels,
    required this.raw,
  });

  factory DockerImageSummary.fromJson(JsonObject json) => DockerImageSummary(
    id: _string(json, 'Id'),
    repoTags: _strings(json['RepoTags']),
    repoDigests: _strings(json['RepoDigests']),
    created: DateTime.fromMillisecondsSinceEpoch(_integer(json, 'Created') * 1000, isUtc: true),
    sizeBytes: _integer(json, 'Size'),
    labels: _stringMap(json['Labels']),
    raw: json,
  );

  final String id;
  final List<String> repoTags;
  final List<String> repoDigests;
  final DateTime created;
  final int sizeBytes;
  final Map<String, String> labels;
  final JsonObject raw;
}

final class DockerImage {
  const DockerImage({required this.id, required this.repoTags, required this.raw});

  factory DockerImage.fromJson(JsonObject json) =>
      DockerImage(id: _string(json, 'Id'), repoTags: _strings(json['RepoTags']), raw: json);

  final String id;
  final List<String> repoTags;
  final JsonObject raw;
}

final class DockerVolume {
  const DockerVolume({
    required this.name,
    required this.driver,
    required this.mountpoint,
    required this.labels,
    required this.scope,
    required this.raw,
  });

  factory DockerVolume.fromJson(JsonObject json) => DockerVolume(
    name: _string(json, 'Name'),
    driver: _string(json, 'Driver'),
    mountpoint: _string(json, 'Mountpoint'),
    labels: _stringMap(json['Labels']),
    scope: json['Scope']?.toString(),
    raw: json,
  );

  final String name;
  final String driver;
  final String mountpoint;
  final Map<String, String> labels;
  final String? scope;
  final JsonObject raw;
}

final class DockerNetwork {
  const DockerNetwork({
    required this.id,
    required this.name,
    required this.driver,
    required this.scope,
    required this.internal,
    required this.attachable,
    required this.labels,
    required this.raw,
  });

  factory DockerNetwork.fromJson(JsonObject json) => DockerNetwork(
    id: _string(json, 'Id'),
    name: _string(json, 'Name'),
    driver: _string(json, 'Driver'),
    scope: json['Scope']?.toString(),
    internal: json['Internal'] == true,
    attachable: json['Attachable'] == true,
    labels: _stringMap(json['Labels']),
    raw: json,
  );

  final String id;
  final String name;
  final String driver;
  final String? scope;
  final bool internal;
  final bool attachable;
  final Map<String, String> labels;
  final JsonObject raw;
}

enum DockerLogStream { stdin, stdout, stderr, unknown }

final class DockerLogEntry {
  const DockerLogEntry({required this.stream, required this.bytes});

  final DockerLogStream stream;
  final List<int> bytes;

  String get text => utf8.decode(bytes, allowMalformed: true);
}

final class DockerLogOptions {
  const DockerLogOptions({
    this.follow = false,
    this.stdout = true,
    this.stderr = true,
    this.since,
    this.until,
    this.timestamps = false,
    this.tail,
  });

  final bool follow;
  final bool stdout;
  final bool stderr;
  final DateTime? since;
  final DateTime? until;
  final bool timestamps;
  final int? tail;
}

final class DockerEventFilter {
  const DockerEventFilter({
    this.types = const [],
    this.events = const [],
    this.containers = const [],
    this.images = const [],
  });

  final List<String> types;
  final List<String> events;
  final List<String> containers;
  final List<String> images;

  bool get isEmpty => types.isEmpty && events.isEmpty && containers.isEmpty && images.isEmpty;

  String toJson() => jsonEncode({
    if (types.isNotEmpty) 'type': types,
    if (events.isNotEmpty) 'event': events,
    if (containers.isNotEmpty) 'container': containers,
    if (images.isNotEmpty) 'image': images,
  });
}

final class DockerEvent {
  const DockerEvent({
    required this.type,
    required this.action,
    required this.actorId,
    required this.attributes,
    required this.timestamp,
    required this.raw,
  });

  factory DockerEvent.fromJson(JsonObject json) {
    final actor = _objectOrEmpty(json['Actor']);
    final timeNano = json['timeNano'];
    final time = json['time'];
    final timestamp = switch (timeNano) {
      int() => DateTime.fromMicrosecondsSinceEpoch(timeNano ~/ 1000, isUtc: true),
      num() => DateTime.fromMicrosecondsSinceEpoch(timeNano.toInt() ~/ 1000, isUtc: true),
      _ => DateTime.fromMillisecondsSinceEpoch(((time as num?)?.toInt() ?? 0) * 1000, isUtc: true),
    };
    return DockerEvent(
      type: json['Type']?.toString() ?? json['type']?.toString() ?? '',
      action: json['Action']?.toString() ?? json['status']?.toString() ?? '',
      actorId: actor['ID']?.toString() ?? json['id']?.toString(),
      attributes: _stringMap(actor['Attributes']),
      timestamp: timestamp,
      raw: json,
    );
  }

  final String type;
  final String action;
  final String? actorId;
  final Map<String, String> attributes;
  final DateTime timestamp;
  final JsonObject raw;
}

final class DockerWaitResult {
  const DockerWaitResult({required this.statusCode, required this.errorMessage});

  factory DockerWaitResult.fromJson(JsonObject json) {
    final error = _objectOrEmpty(json['Error']);
    return DockerWaitResult(
      statusCode: _integer(json, 'StatusCode'),
      errorMessage: error['Message']?.toString(),
    );
  }

  final int statusCode;
  final String? errorMessage;
}

JsonObject jsonObject(Object? value, {String source = 'Docker API'}) {
  if (value is! Map) throw FormatException('$source returned a non-object JSON value.');
  return value.map((key, value) => MapEntry(key.toString(), value));
}

List<Object?> jsonList(Object? value, {String source = 'Docker API'}) {
  if (value is! List) throw FormatException('$source returned a non-list JSON value.');
  return List<Object?>.from(value);
}

String _string(JsonObject json, String key) => json[key]?.toString() ?? '';
int _integer(JsonObject json, String key) => switch (json[key]) {
  int value => value,
  num value => value.toInt(),
  String value => int.parse(value),
  _ => 0,
};
List<String> _strings(Object? value) =>
    value is List ? value.map((item) => item.toString()).toList(growable: false) : const [];
Map<String, String> _stringMap(Object? value) =>
    value is Map ? value.map((key, value) => MapEntry(key.toString(), value.toString())) : const {};
JsonObject _objectOrEmpty(Object? value) => value is Map ? jsonObject(value) : const {};

int? _nestedInt(JsonObject json, List<String> path) {
  Object? value = json;
  for (final segment in path) {
    if (value is! Map) return null;
    value = value[segment];
  }
  return switch (value) {
    int number => number,
    num number => number.toInt(),
    String text => int.tryParse(text),
    _ => null,
  };
}
