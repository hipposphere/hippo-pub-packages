import 'package:agent_core/agent_core.dart';
import 'package:live_audio/src/gemini/gemini_live_audio_config.dart';
import 'package:live_audio/src/gemini/gemini_live_audio_session.dart';
import 'package:live_audio/src/models/live_audio_event.dart';
import 'package:live_audio/src/models/live_audio_provider.dart';
import 'package:live_audio/src/models/live_audio_socket_message.dart';
import 'package:live_audio/src/models/live_audio_tool_mapping.dart';
import 'package:test/test.dart';

void main() {
  const tool = _TestTool();

  test('maps Agent tool descriptors to OpenAI function tools', () {
    expect(liveAudioOpenAIToolJson(tool), {
      'type': 'function',
      'name': 'lookup',
      'description': 'Looks up a value.',
      'parameters': {
        'type': 'object',
        'properties': {
          'query': {'type': 'string'},
        },
        'required': ['query'],
      },
    });
  });

  test('maps Agent tool descriptors to Gemini function declarations', () {
    final declaration = geminiLiveAudioFunctionDeclaration(tool).toJson();

    expect(declaration['name'], 'lookup');
    expect(declaration['description'], 'Looks up a value.');
    expect(declaration['parameters'], {
      'type': 'OBJECT',
      'properties': {
        'query': {'type': 'STRING'},
      },
      'required': ['query'],
    });
  });

  test('enables Gemini audio transcription with empty config objects', () {
    final json = geminiLiveConfig(
      const GeminiLiveAudioConfig(
        apiKey: 'test-key',
        model: GeminiLiveAudioModels.gemini31FlashLivePreview,
      ),
    ).toJson();

    expect(json['inputAudioTranscription'], isEmpty);
    expect(json['outputAudioTranscription'], isEmpty);
  });

  test('maps provider calls to Agent tool calls', () {
    final call = liveAudioToolCall(
      id: 'call-1',
      name: 'lookup',
      arguments: '{"query":"hours"}',
      metadata: const {'provider': 'openai_realtime'},
    );

    expect(call.id, 'call-1');
    expect(call.name, 'lookup');
    expect(call.arguments, {'query': 'hours'});
    expect(call.metadata, {'provider': 'openai_realtime'});
  });

  test('keeps malformed provider calls observable', () {
    final call = liveAudioToolCall(id: 'call-1', name: 'lookup', arguments: '{invalid');

    expect(call.arguments, isEmpty);
    expect(call.metadata['argumentsError'], isA<String>());
  });

  test('normalizes successful and failed tool results', () {
    expect(
      liveAudioToolResultValue(
        const AgentToolResult<Object?>(callId: 'call-1', name: 'lookup', result: {'value': 'open'}),
      ),
      {'value': 'open'},
    );
    expect(
      liveAudioToolResultObject(
        const AgentToolResult<Object?>(
          callId: 'call-1',
          name: 'lookup',
          result: ['open', 'closed'],
        ),
      ),
      {
        'result': ['open', 'closed'],
      },
    );
    expect(
      liveAudioToolResultValue(
        const AgentToolResult<Object?>(callId: 'call-1', name: 'lookup', error: 'unavailable'),
      ),
      {'error': 'unavailable'},
    );
  });

  test('preserves tool socket wire shapes with Agent models', () {
    const codec = LiveAudioSocketMessageCodec();
    const result = AgentToolResult<Object?>(
      callId: 'call-1',
      name: 'lookup',
      result: {'value': 'open'},
    );

    final encoded = codec.encode(
      const LiveAudioSocketMessage(type: LiveAudioSocketMessageType.toolResult, toolResult: result),
    );
    expect(encoded, {
      'type': 'tool_response',
      'id': 'call-1',
      'name': 'lookup',
      'response': {'value': 'open'},
    });

    final decoded = codec.decode(encoded).toolResult!;
    expect(decoded.callId, 'call-1');
    expect(decoded.name, 'lookup');
    expect(decoded.result, {'value': 'open'});
    expect(decoded.error, isNull);
  });

  test('encodes live audio tool call events with the existing wire shape', () {
    const eventCodec = LiveAudioSocketEventCodec();
    final encoded = eventCodec.encode(
      LiveAudioToolCallEvent(
        provider: LiveAudioProvider.openaiRealtime,
        call: const AgentToolCall<Map<String, Object?>>(
          id: 'call-1',
          name: 'lookup',
          arguments: {'query': 'hours'},
        ),
      ),
    );

    expect(encoded, {
      'type': 'tool_call',
      'name': 'lookup',
      'arguments': {'query': 'hours'},
      'id': 'call-1',
      'provider': 'openaiRealtime',
    });
  });
}

final class _TestTool implements AgentTool<Map<String, Object?>, Map<String, Object?>> {
  const _TestTool();

  @override
  AgentToolDescriptor get descriptor => const AgentToolDescriptor(
    name: 'lookup',
    description: 'Looks up a value.',
    inputSchema: {
      'type': 'object',
      'properties': {
        'query': {'type': 'string'},
      },
      'required': ['query'],
    },
    effect: AgentToolEffect.read,
  );

  @override
  Future<Map<String, Object?>> call(
    Map<String, Object?> arguments,
    AgentToolCallContext context,
  ) async {
    return arguments;
  }
}
