import 'dart:convert';

import 'package:agent_core/agent_core.dart';

Map<String, dynamic> liveAudioOpenAIToolJson(AgentTool<dynamic, dynamic> tool) {
  final descriptor = tool.descriptor;
  return {
    'type': 'function',
    'name': descriptor.name,
    if (descriptor.description != null) 'description': descriptor.description,
    'parameters': liveAudioJsonObject(descriptor.inputSchema),
  };
}

AgentToolCall<Map<String, Object?>> liveAudioToolCall({
  required String id,
  required String name,
  required Object? arguments,
  Map<String, Object?> metadata = const <String, Object?>{},
}) {
  final parsed = _toolArguments(arguments);
  return AgentToolCall<Map<String, Object?>>(
    id: id,
    name: name,
    arguments: parsed.arguments,
    metadata: {...metadata, if (parsed.error != null) 'argumentsError': parsed.error},
  );
}

Object? liveAudioToolResultValue(AgentToolResult<Object?> result, {bool requireObject = false}) {
  if (result.error case final error?) {
    return <String, Object?>{'error': error};
  }

  final value = _jsonValue(result.result);
  if (!requireObject || value is Map<String, dynamic>) {
    return value;
  }
  return <String, Object?>{'result': value};
}

Map<String, dynamic> liveAudioToolResultObject(AgentToolResult<Object?> result) {
  final value = liveAudioToolResultValue(result, requireObject: true);
  return {
    for (final entry in (value! as Map).entries)
      if (entry.key case final String key) key: _jsonValue(entry.value),
  };
}

Map<String, dynamic> liveAudioJsonObject(Map<String, Object?> value) => {
  for (final entry in value.entries) entry.key: _jsonValue(entry.value),
};

_ToolArguments _toolArguments(Object? value) {
  if (value is String) {
    try {
      return _toolArguments(jsonDecode(value));
    } on FormatException catch (error) {
      return _ToolArguments(const <String, Object?>{}, error.toString());
    }
  }
  if (value is Map) {
    return _ToolArguments(<String, Object?>{
      for (final entry in value.entries)
        if (entry.key case final String key) key: entry.value,
    }, null);
  }
  return _ToolArguments(const <String, Object?>{}, 'Tool arguments must be a JSON object.');
}

Object? _jsonValue(Object? value) {
  if (value is Map<String, Object?>) {
    return liveAudioJsonObject(value);
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

final class _ToolArguments {
  const _ToolArguments(this.arguments, this.error);

  final Map<String, Object?> arguments;
  final String? error;
}
