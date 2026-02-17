import 'package:hippo_bluetooth_client_builder/hippo_bluetooth_client_builder.dart';
import 'package:test/test.dart';

void main() {
  test('generates protocol definitions and service wrappers for hippo client', () {
    final contract = parseBleContractJsonObject(<String, Object?>{
      'bleContract': '1.0.0',
      'info': <String, Object?>{
        'title': 'Door Lock',
        'version': '1.2.3',
        'generatedAt': '2026-02-15T20:00:00.000Z',
      },
      'source': <String, Object?>{'kind': 'protocols'},
      'services': <Object?>[
        <String, Object?>{
          'id': 'door-lock',
          'uuid': '1234567812345678123456789abc0000',
          'advertise': true,
          'characteristics': <Object?>[
            <String, Object?>{
              'id': 'status',
              'uuid': '1234567812345678123456789abc0001',
              'properties': <Object?>['read', 'notify'],
            },
            <String, Object?>{
              'id': 'command',
              'uuid': '1234567812345678123456789abc0002',
              'properties': <Object?>['writeWithoutResponse'],
            },
            <String, Object?>{
              'id': 'result',
              'uuid': '1234567812345678123456789abc0003',
              'properties': <Object?>['read', 'write', 'indicate'],
            },
          ],
        },
      ],
    });

    final output = generateBleClientDart(
      contract: resolveBleContract(contract),
      options: const BleClientCodegenOptions(),
      sourceContractPath: '/tmp/door-lock-contract.json',
    );

    expect(output, contains('class DoorLockBleClient {'));
    expect(output, contains('class DoorLockBleService {'));
    expect(output, contains("protocolId: 'door-lock'"));
    expect(output, contains("channelUuid: '12345678-1234-5678-1234-56789abc0001'"));
    expect(
      output,
      contains('properties: BleChannelProperties(read: true, write: true, notify: true)'),
    );
    expect(output, contains('Future<void> writeCommand(Uint8List value, {'));
    expect(output, contains('withoutResponse: true,'));
  });

  test('uses one initializer list colon for aggregate client with multiple services', () {
    final contract = parseBleContractJsonObject(<String, Object?>{
      'bleContract': '1.0.0',
      'info': <String, Object?>{
        'title': 'Multi Service',
        'version': '1.0.0',
        'generatedAt': '2026-02-15T20:00:00.000Z',
      },
      'source': <String, Object?>{'kind': 'protocols'},
      'services': <Object?>[
        <String, Object?>{
          'id': 'alpha',
          'uuid': '1234567812345678123456789abc1001',
          'advertise': true,
          'characteristics': <Object?>[
            <String, Object?>{
              'id': 'status',
              'uuid': '1234567812345678123456789abc1002',
              'properties': <Object?>['read'],
            },
          ],
        },
        <String, Object?>{
          'id': 'beta',
          'uuid': '1234567812345678123456789abc1003',
          'advertise': true,
          'characteristics': <Object?>[
            <String, Object?>{
              'id': 'status',
              'uuid': '1234567812345678123456789abc1004',
              'properties': <Object?>['read'],
            },
          ],
        },
      ],
    });

    final output = generateBleClientDart(
      contract: resolveBleContract(contract),
      options: const BleClientCodegenOptions(),
      sourceContractPath: '/tmp/multi-service-contract.json',
    );

    expect(
      output,
      contains(
        RegExp(
          r'MultiServiceBleClient\(this\.protocolClient\)\s*:\s*'
          r'alpha = AlphaBleService\(protocolClient\),\s*'
          r'beta = BetaBleService\(protocolClient\);',
          dotAll: true,
        ),
      ),
    );
    expect(output, isNot(contains(RegExp(r'\n\s*:\s*beta = BetaBleService\(protocolClient\);'))));
  });

  test('fills missing ids for contracts generated from services input', () {
    final contract = parseBleContractJsonObject(<String, Object?>{
      'bleContract': '1.0.0',
      'info': <String, Object?>{
        'title': 'Device Contract',
        'version': '1.0.0',
        'generatedAt': '2026-02-15T20:00:00.000Z',
      },
      'source': <String, Object?>{'kind': 'services'},
      'services': <Object?>[
        <String, Object?>{
          'uuid': 'abcd1234',
          'advertise': true,
          'characteristics': <Object?>[
            <String, Object?>{
              'uuid': 'beef',
              'properties': <Object?>['read'],
            },
          ],
        },
      ],
    });

    final output = generateBleClientDart(
      contract: resolveBleContract(contract),
      options: const BleClientCodegenOptions(),
      sourceContractPath: '/tmp/device-contract.json',
    );

    expect(output, contains("protocolId: 'service_abcd1234'"));
    expect(output, contains("channelId: 'channel_beef'"));
  });

  test('rejects unsupported characteristic property', () {
    expect(
      () => parseBleContractJsonObject(<String, Object?>{
        'bleContract': '1.0.0',
        'info': <String, Object?>{
          'title': 'Invalid Contract',
          'version': '1.0.0',
          'generatedAt': '2026-02-15T20:00:00.000Z',
        },
        'source': <String, Object?>{'kind': 'protocols'},
        'services': <Object?>[
          <String, Object?>{
            'id': 'invalid',
            'uuid': '1234',
            'advertise': true,
            'characteristics': <Object?>[
              <String, Object?>{
                'id': 'broken',
                'uuid': '1235',
                'properties': <Object?>['execute'],
              },
            ],
          },
        ],
      }),
      throwsA(isA<FormatException>()),
    );
  });

  test('uses per-channel contract codec when no override is provided', () {
    final contract = parseBleContractJsonObject(<String, Object?>{
      'bleContract': '1.0.0',
      'info': <String, Object?>{
        'title': 'Mixed Codec Contract',
        'version': '1.0.0',
        'generatedAt': '2026-02-15T20:00:00.000Z',
      },
      'source': <String, Object?>{'kind': 'protocols'},
      'services': <Object?>[
        <String, Object?>{
          'id': 'mixed-codec',
          'uuid': '1234567812345678123456789abc0100',
          'advertise': true,
          'characteristics': <Object?>[
            <String, Object?>{
              'id': 'plain-text',
              'uuid': '1234567812345678123456789abc0101',
              'properties': <Object?>['read'],
              'codec': 'utf8',
            },
            <String, Object?>{
              'id': 'payload',
              'uuid': '1234567812345678123456789abc0102',
              'properties': <Object?>['read'],
              'codec': 'json',
            },
            <String, Object?>{
              'id': 'raw',
              'uuid': '1234567812345678123456789abc0103',
              'properties': <Object?>['read'],
            },
          ],
        },
      ],
    });

    final output = generateBleClientDart(
      contract: resolveBleContract(contract),
      options: const BleClientCodegenOptions(defaultCodec: GeneratedChannelCodec.bytes),
      sourceContractPath: '/tmp/mixed-codec-contract.json',
    );

    expect(output, contains('Future<String> readPlainText({'));
    expect(output, contains('Future<dynamic> readPayload({'));
    expect(output, contains('Future<Uint8List> readRaw({'));
    expect(output, contains('codec: ChannelCodecs.utf8,'));
    expect(output, contains('codec: ChannelCodecs.json,'));
    expect(output, contains('codec: ChannelCodecs.bytes,'));
  });

  test('resolves codecs with precedence: override > contract codec > default', () {
    final contract = parseBleContractJsonObject(<String, Object?>{
      'bleContract': '1.0.0',
      'info': <String, Object?>{
        'title': 'Codec Priority Contract',
        'version': '1.0.0',
        'generatedAt': '2026-02-15T20:00:00.000Z',
      },
      'source': <String, Object?>{'kind': 'protocols'},
      'services': <Object?>[
        <String, Object?>{
          'id': 'priority',
          'uuid': '1234567812345678123456789abc0200',
          'advertise': true,
          'characteristics': <Object?>[
            <String, Object?>{
              'id': 'status',
              'uuid': '1234567812345678123456789abc0201',
              'properties': <Object?>['read'],
              'codec': 'utf8',
            },
            <String, Object?>{
              'id': 'contract-only',
              'uuid': '1234567812345678123456789abc0202',
              'properties': <Object?>['read'],
              'codec': 'json',
            },
            <String, Object?>{
              'id': 'fallback',
              'uuid': '1234567812345678123456789abc0203',
              'properties': <Object?>['read'],
            },
          ],
        },
      ],
    });

    final output = generateBleClientDart(
      contract: resolveBleContract(contract),
      options: const BleClientCodegenOptions(
        defaultCodec: GeneratedChannelCodec.bytes,
        codecOverrides: <String, GeneratedChannelCodec>{
          'status': GeneratedChannelCodec.bytes,
          'priority/status': GeneratedChannelCodec.json,
        },
      ),
      sourceContractPath: '/tmp/codec-priority-contract.json',
    );

    expect(output, contains('Future<dynamic> readStatus({'));
    expect(output, contains('Future<dynamic> readContractOnly({'));
    expect(output, contains('Future<Uint8List> readFallback({'));
  });

  test('generates typed json payload models from codec jsonSchema metadata', () {
    final contract = parseBleContractJsonObject(<String, Object?>{
      'bleContract': '1.0.0',
      'info': <String, Object?>{
        'title': 'Schema Contract',
        'version': '1.0.0',
        'generatedAt': '2026-02-17T18:00:00.000Z',
      },
      'source': <String, Object?>{'kind': 'protocols'},
      'services': <Object?>[
        <String, Object?>{
          'id': 'control',
          'uuid': '1234567812345678123456789abc0300',
          'advertise': true,
          'characteristics': <Object?>[
            <String, Object?>{
              'id': 'command',
              'uuid': '1234567812345678123456789abc0301',
              'properties': <Object?>['read', 'write', 'notify'],
              'codec': <String, Object?>{
                'name': 'json',
                'jsonSchema': <String, Object?>{
                  'send': <String, Object?>{
                    'type': 'object',
                    'properties': <String, Object?>{
                      'status': <String, Object?>{'type': 'string'},
                    },
                    'required': <Object?>['status'],
                    'additionalProperties': false,
                  },
                  'receive': <String, Object?>{
                    'type': 'object',
                    'properties': <String, Object?>{
                      'command': <String, Object?>{'type': 'string'},
                    },
                    'required': <Object?>['command'],
                    'additionalProperties': false,
                  },
                },
              },
            },
          ],
        },
      ],
    });

    final output = generateBleClientDart(
      contract: resolveBleContract(contract),
      options: const BleClientCodegenOptions(),
      sourceContractPath: '/tmp/schema-contract.json',
    );

    expect(output, contains('class ControlCommandSendPayload {'));
    expect(output, contains('class ControlCommandReceivePayload {'));
    expect(output, contains('Future<ControlCommandSendPayload> readCommand({'));
    expect(output, contains('return ControlCommandSendPayload.fromJson(value);'));
    expect(output, contains('Future<void> writeCommand(ControlCommandReceivePayload value, {'));
    expect(output, contains('return _client.writeChannel<dynamic>('));
    expect(output, contains('value.toJson(),'));
    expect(output, contains('.map(ControlCommandSendPayload.fromJson);'));
    expect(output, contains("codec: ChannelCodecs.json,"));
  });

  test('rejects jsonSchema metadata for non-json codecs', () {
    expect(
      () => parseBleContractJsonObject(<String, Object?>{
        'bleContract': '1.0.0',
        'info': <String, Object?>{
          'title': 'Invalid JsonSchema Contract',
          'version': '1.0.0',
          'generatedAt': '2026-02-17T18:00:00.000Z',
        },
        'source': <String, Object?>{'kind': 'protocols'},
        'services': <Object?>[
          <String, Object?>{
            'id': 'invalid-schema',
            'uuid': '1234567812345678123456789abc0400',
            'advertise': true,
            'characteristics': <Object?>[
              <String, Object?>{
                'id': 'broken',
                'uuid': '1234567812345678123456789abc0401',
                'properties': <Object?>['read'],
                'codec': 'utf8',
                'jsonSchema': <String, Object?>{
                  'type': 'object',
                  'properties': <String, Object?>{
                    'value': <String, Object?>{'type': 'string'},
                  },
                },
              },
            ],
          },
        ],
      }),
      throwsA(isA<FormatException>()),
    );
  });

  test('rejects unsupported channel codec metadata', () {
    expect(
      () => parseBleContractJsonObject(<String, Object?>{
        'bleContract': '1.0.0',
        'info': <String, Object?>{
          'title': 'Invalid Codec Contract',
          'version': '1.0.0',
          'generatedAt': '2026-02-15T20:00:00.000Z',
        },
        'source': <String, Object?>{'kind': 'protocols'},
        'services': <Object?>[
          <String, Object?>{
            'id': 'invalid',
            'uuid': '1234',
            'advertise': true,
            'characteristics': <Object?>[
              <String, Object?>{
                'id': 'broken',
                'uuid': '1235',
                'properties': <Object?>['read'],
                'codec': 'utf16',
              },
            ],
          },
        ],
      }),
      throwsA(isA<FormatException>()),
    );
  });
}
