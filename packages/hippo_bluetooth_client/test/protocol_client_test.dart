import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hippo_bluetooth_client/hippo_bluetooth_client.dart';

import 'support/fake_ble_gatt_client.dart';

void main() {
  const remoteId = 'AA:BB:CC:DD:EE:FF';
  const serviceUuid = '00000000-0000-0000-0000-00000000a001';
  const textUuid = '00000000-0000-0000-0000-00000000a101';
  const writeUuid = '00000000-0000-0000-0000-00000000a102';
  const chunkUuid = '00000000-0000-0000-0000-00000000a103';

  late FakeBleGattClient gatt;
  late BleProtocolClient client;

  setUp(() {
    gatt = FakeBleGattClient();
    gatt.servicesByRemoteId[remoteId] = <BleServiceInfo>[
      const BleServiceInfo(
        uuid: serviceUuid,
        characteristics: <BleCharacteristicInfo>[
          BleCharacteristicInfo(
            uuid: textUuid,
            properties: BleCharacteristicProperties(read: true, notify: true),
          ),
          BleCharacteristicInfo(
            uuid: writeUuid,
            properties: BleCharacteristicProperties(write: true),
          ),
          BleCharacteristicInfo(
            uuid: chunkUuid,
            properties: BleCharacteristicProperties(
              writeWithoutResponse: true,
              notify: true,
            ),
          ),
        ],
      ),
    ];

    client = BleProtocolClient(
      gattClient: gatt,
      remoteId: remoteId,
      protocols: <BleProtocolDefinition>[
        BleProtocolDefinition(
          protocolId: 'demo',
          serviceUuid: serviceUuid,
          channels: <BleChannelDefinition<dynamic>>[
            const BleChannelDefinition<String>(
              channelId: 'text',
              channelUuid: textUuid,
              properties: BleChannelProperties(read: true, notify: true),
              codec: Utf8ChannelCodec(),
            ),
            const BleChannelDefinition<String>(
              channelId: 'write',
              channelUuid: writeUuid,
              properties: BleChannelProperties(write: true),
              codec: Utf8ChannelCodec(),
            ),
            const BleChannelDefinition<String>(
              channelId: 'chunk',
              channelUuid: chunkUuid,
              properties: BleChannelProperties(write: true, notify: true),
              codec: Utf8ChannelCodec(),
            ),
          ],
        ),
      ],
    );
  });

  tearDown(() async {
    await client.dispose();
    await gatt.dispose();
  });

  test('readChannel decodes typed data', () async {
    final ref = const BleCharacteristicRef(
      remoteId: remoteId,
      serviceUuid: serviceUuid,
      characteristicUuid: textUuid,
    );
    gatt.setReadValue(ref, Uint8List.fromList(utf8.encode('ready')));

    final value = await client.readChannel<String>('demo', 'text');
    expect(value, 'ready');
  });

  test('writeChannel encodes and writes bytes', () async {
    await client.writeChannel<String>('demo', 'write', 'ping');

    expect(gatt.writes.length, 1);
    final body = utf8.decode(gatt.writes.single.value);
    expect(body, 'ping');
    expect(gatt.writes.single.withoutResponse, isFalse);
  });

  test('subscribeChannel decodes notifications', () async {
    final ref = const BleCharacteristicRef(
      remoteId: remoteId,
      serviceUuid: serviceUuid,
      characteristicUuid: textUuid,
    );

    final nextValue = client.subscribeChannel<String>('demo', 'text').first;
    while (gatt.discoverServicesCalls == 0) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }
    gatt.emitNotification(ref, Uint8List.fromList(utf8.encode('hello')));

    await expectLater(nextValue, completion('hello'));
  });

  test('sendChunked writes framed sequence', () async {
    await client.sendChunked<String>(
      'demo',
      'chunk',
      'abcdefghijklmnopqrstuvwxyz',
      options: const ChunkSendOptions(
        sequence: 77,
        maxChunkPayloadSize: 5,
        withoutResponse: true,
      ),
    );

    expect(gatt.writes.length, greaterThan(1));

    final reassembler = ChunkReassembler();
    Uint8List? output;
    for (final write in gatt.writes) {
      expect(write.withoutResponse, isTrue);
      final frame = decodeChunkFrame(write.value);
      expect(frame.sequence, 77);
      output = reassembler.addFrame(sessionId: 'test', frame: frame) ?? output;
    }

    expect(utf8.decode(output!), 'abcdefghijklmnopqrstuvwxyz');
  });

  test('reuses cached channel mapping', () async {
    await client.getChannelCharacteristicRef('demo', 'text');
    await client.getChannelCharacteristicRef('demo', 'text');

    expect(gatt.discoverServicesCalls, 1);
  });

  test('throws when channel is not writable', () async {
    expect(
      () => client.writeChannel<String>('demo', 'text', 'nope'),
      throwsA(isA<ProtocolError>()),
    );
  });

  test(
    'matches dashless 128-bit UUIDs against discovered dashed UUIDs',
    () async {
      const dashlessServiceUuid = '0000000000000000000000000000a001';
      const dashlessTextUuid = '0000000000000000000000000000a101';

      final dashlessClient = BleProtocolClient(
        gattClient: gatt,
        remoteId: remoteId,
        protocols: <BleProtocolDefinition>[
          BleProtocolDefinition(
            protocolId: 'demo',
            serviceUuid: dashlessServiceUuid,
            channels: <BleChannelDefinition<dynamic>>[
              const BleChannelDefinition<String>(
                channelId: 'text',
                channelUuid: dashlessTextUuid,
                properties: BleChannelProperties(read: true, notify: true),
                codec: Utf8ChannelCodec(),
              ),
            ],
          ),
        ],
      );
      addTearDown(dashlessClient.dispose);

      gatt.setReadValue(
        const BleCharacteristicRef(
          remoteId: remoteId,
          serviceUuid: serviceUuid,
          characteristicUuid: textUuid,
        ),
        Uint8List.fromList(utf8.encode('dashless-ok')),
      );

      final value = await dashlessClient.readChannel<String>('demo', 'text');
      expect(value, 'dashless-ok');
    },
  );

  test('expands 16-bit UUIDs to Bluetooth base UUID for matching', () async {
    const batteryRemoteId = '11:22:33:44:55:66';
    const batteryServiceUuid = '0000180f-0000-1000-8000-00805f9b34fb';
    const batteryLevelUuid = '00002a19-0000-1000-8000-00805f9b34fb';

    gatt.servicesByRemoteId[batteryRemoteId] = <BleServiceInfo>[
      const BleServiceInfo(
        uuid: batteryServiceUuid,
        characteristics: <BleCharacteristicInfo>[
          BleCharacteristicInfo(
            uuid: batteryLevelUuid,
            properties: BleCharacteristicProperties(read: true, notify: true),
          ),
        ],
      ),
    ];

    final batteryClient = BleProtocolClient(
      gattClient: gatt,
      remoteId: batteryRemoteId,
      protocols: <BleProtocolDefinition>[
        BleProtocolDefinition(
          protocolId: 'battery',
          serviceUuid: '180f',
          channels: <BleChannelDefinition<dynamic>>[
            const BleChannelDefinition<String>(
              channelId: 'level',
              channelUuid: '2a19',
              properties: BleChannelProperties(read: true),
              codec: Utf8ChannelCodec(),
            ),
          ],
        ),
      ],
    );
    addTearDown(batteryClient.dispose);

    gatt.setReadValue(
      const BleCharacteristicRef(
        remoteId: batteryRemoteId,
        serviceUuid: batteryServiceUuid,
        characteristicUuid: batteryLevelUuid,
      ),
      Uint8List.fromList(utf8.encode('91')),
    );

    final value = await batteryClient.readChannel<String>('battery', 'level');
    expect(value, '91');
  });
}
