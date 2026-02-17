import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hippo_bluetooth_client/hippo_bluetooth_client.dart';

import 'support/fake_ble_gatt_client.dart';

void main() {
  const remoteId = 'Device-42';
  const serviceUuid = '00000000-0000-0000-0000-00000000b001';
  const challengeUuid = '00000000-0000-0000-0000-00000000b101';
  const responseUuid = '00000000-0000-0000-0000-00000000b102';
  const resultUuid = '00000000-0000-0000-0000-00000000b103';

  late FakeBleGattClient gatt;
  late BleProtocolClient protocolClient;

  setUp(() {
    gatt = FakeBleGattClient();
    gatt.servicesByRemoteId[remoteId] = <BleServiceInfo>[
      const BleServiceInfo(
        uuid: serviceUuid,
        characteristics: <BleCharacteristicInfo>[
          BleCharacteristicInfo(
            uuid: challengeUuid,
            properties: BleCharacteristicProperties(read: true),
          ),
          BleCharacteristicInfo(
            uuid: responseUuid,
            properties: BleCharacteristicProperties(write: true),
          ),
          BleCharacteristicInfo(
            uuid: resultUuid,
            properties: BleCharacteristicProperties(read: true),
          ),
        ],
      ),
    ];

    protocolClient = BleProtocolClient(
      gattClient: gatt,
      remoteId: remoteId,
      protocols: <BleProtocolDefinition>[
        BleProtocolDefinition(
          protocolId: 'auth',
          serviceUuid: serviceUuid,
          channels: <BleChannelDefinition<dynamic>>[
            const BleChannelDefinition<dynamic>(
              channelId: 'challenge',
              channelUuid: challengeUuid,
              properties: BleChannelProperties(read: true),
              codec: ChannelCodecs.json,
            ),
            const BleChannelDefinition<dynamic>(
              channelId: 'response',
              channelUuid: responseUuid,
              properties: BleChannelProperties(write: true),
              codec: ChannelCodecs.json,
            ),
            const BleChannelDefinition<dynamic>(
              channelId: 'result',
              channelUuid: resultUuid,
              properties: BleChannelProperties(read: true),
              codec: ChannelCodecs.json,
            ),
          ],
        ),
      ],
    );
  });

  tearDown(() async {
    await protocolClient.dispose();
    await gatt.dispose();
  });

  test('authorize performs challenge-response and tracks state', () async {
    final challengeRef = const BleCharacteristicRef(
      remoteId: remoteId,
      serviceUuid: serviceUuid,
      characteristicUuid: challengeUuid,
    );
    final resultRef = const BleCharacteristicRef(
      remoteId: remoteId,
      serviceUuid: serviceUuid,
      characteristicUuid: resultUuid,
    );

    gatt.setReadValue(
      challengeRef,
      Uint8List.fromList(
        utf8.encode('{"nonce":"n-1","sessionId":"Session:One"}'),
      ),
    );
    gatt.setReadValue(
      resultRef,
      Uint8List.fromList(utf8.encode('{"authorized":true}')),
    );

    final manager = BluetoothLeAuthManager(
      protocolClient: protocolClient,
      channels: const BluetoothLeAuthChannels(
        protocolId: 'auth',
        challengeChannelId: 'challenge',
        responseChannelId: 'response',
        resultChannelId: 'result',
      ),
      secret: Uint8List.fromList(utf8.encode('top-secret')),
    );

    final result = await manager.authorize();

    expect(result.authorized, isTrue);
    expect(result.sessionId, 'sessionone');
    expect(manager.isAuthorized, isTrue);

    expect(gatt.writes.length, 1);
    final writePayload =
        jsonDecode(utf8.decode(gatt.writes.single.value))
            as Map<String, dynamic>;
    expect(writePayload['nonce'], 'n-1');
    expect(writePayload['sessionId'], 'sessionone');
    expect((writePayload['signature'] as String).isNotEmpty, isTrue);

    var ensuredCalls = 0;
    final ensuredValue = await manager.ensureAuthorized<int>(() async {
      ensuredCalls += 1;
      return 7;
    });

    expect(ensuredValue, 7);
    expect(ensuredCalls, 1);
    expect(gatt.writes.length, 1);

    await gatt.disconnect(remoteId);
    await Future<void>.delayed(Duration.zero);
    expect(manager.isAuthorized, isFalse);

    await manager.dispose();
  });

  test('authorize throws when server rejects result', () async {
    final challengeRef = const BleCharacteristicRef(
      remoteId: remoteId,
      serviceUuid: serviceUuid,
      characteristicUuid: challengeUuid,
    );
    final resultRef = const BleCharacteristicRef(
      remoteId: remoteId,
      serviceUuid: serviceUuid,
      characteristicUuid: resultUuid,
    );

    gatt.setReadValue(
      challengeRef,
      Uint8List.fromList(utf8.encode('{"nonce":"n-2"}')),
    );
    gatt.setReadValue(
      resultRef,
      Uint8List.fromList(utf8.encode('{"authorized":false}')),
    );

    final manager = BluetoothLeAuthManager(
      protocolClient: protocolClient,
      channels: const BluetoothLeAuthChannels(
        protocolId: 'auth',
        challengeChannelId: 'challenge',
        responseChannelId: 'response',
        resultChannelId: 'result',
      ),
      secret: Uint8List.fromList(utf8.encode('top-secret')),
    );

    expect(manager.authorize(), throwsA(isA<AuthError>()));

    await manager.dispose();
  });
}
