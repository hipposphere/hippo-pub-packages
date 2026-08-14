final class DockerEngineException implements Exception {
  const DockerEngineException({required this.message, this.statusCode, this.path, this.body});

  final String message;
  final int? statusCode;
  final String? path;
  final Object? body;

  @override
  String toString() {
    final status = statusCode == null ? '' : ' ($statusCode)';
    final requestPath = path == null ? '' : ' for $path';
    return 'DockerEngineException$status$requestPath: $message';
  }
}

final class DockerApiVersionException implements Exception {
  const DockerApiVersionException({required this.clientMinimum, required this.engineMaximum});

  final DockerApiVersion clientMinimum;
  final DockerApiVersion engineMaximum;

  @override
  String toString() =>
      'DockerApiVersionException: engine maximum $engineMaximum is below client minimum '
      '$clientMinimum.';
}

final class DockerApiVersion implements Comparable<DockerApiVersion> {
  const DockerApiVersion(this.major, this.minor);

  factory DockerApiVersion.parse(String value) {
    final parts = value.split('.');
    if (parts.length != 2) throw FormatException('Invalid Docker API version: $value');
    return DockerApiVersion(int.parse(parts[0]), int.parse(parts[1]));
  }

  final int major;
  final int minor;

  @override
  int compareTo(DockerApiVersion other) {
    final majorComparison = major.compareTo(other.major);
    return majorComparison == 0 ? minor.compareTo(other.minor) : majorComparison;
  }

  @override
  String toString() => '$major.$minor';
}
