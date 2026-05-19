final class LiveAudioTool {
  const LiveAudioTool({
    required this.name,
    this.description,
    this.parameters = const {'type': 'object', 'properties': <String, Object?>{}},
  });

  final String name;
  final String? description;
  final Map<String, Object?> parameters;

  Map<String, dynamic> toOpenAIJson() => {
    'type': 'function',
    'name': name,
    if (description != null) 'description': description,
    'parameters': _jsonObject(parameters),
  };

  Map<String, dynamic> get parametersJson => _jsonObject(parameters);
}

final class LiveAudioToolResponse {
  const LiveAudioToolResponse({required this.name, required this.response, this.id});

  final String name;
  final Map<String, Object?> response;
  final String? id;

  Map<String, dynamic> get responseJson => _jsonObject(response);
}

Map<String, dynamic> _jsonObject(Map<String, Object?> value) => {
  for (final entry in value.entries) entry.key: _jsonValue(entry.value),
};

Object? _jsonValue(Object? value) {
  if (value is Map<String, Object?>) {
    return _jsonObject(value);
  }
  if (value is Map) {
    return {
      for (final entry in value.entries)
        if (entry.key is String) entry.key as String: _jsonValue(entry.value),
    };
  }
  if (value is Iterable) {
    return value.map(_jsonValue).toList(growable: false);
  }
  return value;
}
