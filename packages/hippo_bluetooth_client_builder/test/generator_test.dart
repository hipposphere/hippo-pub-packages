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
}
