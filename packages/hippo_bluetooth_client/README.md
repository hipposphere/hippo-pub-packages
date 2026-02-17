# hippo_bluetooth_client

Lean Flutter BLE client package for scanning, connecting, app-level authorization, and typed protocol channel communication.

Built on [flutter_blue_plus](https://pub.dev/packages/flutter_blue_plus), with a small high-level protocol layer modeled after server-side protocol/channel abstractions.

## Features

- Low-level GATT client abstraction (`BleGattClient`) with `flutter_blue_plus` implementation.
- Typed protocol definitions by protocol/service/channel ids.
- Codecs for `bytes`, `utf8`, and broad `json`.
- Chunked sequenced wire transport compatible with server frame format.
- Challenge-response auth helper with HMAC signing.
- Deterministic unit tests with fake transport.

## Quick Start

```dart
import 'dart:typed_data';

import 'package:hippo_bluetooth_client/hippo_bluetooth_client.dart';

final gatt = FlutterBluePlusGattClient();

final protocol = BleProtocolDefinition(
  protocolId: 'device-control',
  serviceUuid: '12345678-1234-5678-1234-56789abc0000',
  channels: <BleChannelDefinition<dynamic>>[
    const BleChannelDefinition<String>(
      channelId: 'status',
      channelUuid: '12345678-1234-5678-1234-56789abc0001',
      properties: BleChannelProperties(read: true, notify: true),
      codec: Utf8ChannelCodec(),
    ),
    const BleChannelDefinition<String>(
      channelId: 'command',
      channelUuid: '12345678-1234-5678-1234-56789abc0002',
      properties: BleChannelProperties(write: true),
      codec: Utf8ChannelCodec(),
    ),
  ],
);

await gatt.connect('AA:BB:CC:DD:EE:FF');

final client = BleProtocolClient(
  gattClient: gatt,
  remoteId: 'AA:BB:CC:DD:EE:FF',
  protocols: <BleProtocolDefinition>[protocol],
);

final status = await client.readChannel<String>('device-control', 'status');
await client.writeChannel<String>('device-control', 'command', 'start');
```

## Protocol Definition Example

```dart
final protocol = BleProtocolDefinition(
  protocolId: 'telemetry',
  serviceUuid: '00000000-0000-0000-0000-00000000a001',
  channels: <BleChannelDefinition<dynamic>>[
    const BleChannelDefinition<Uint8List>(
      channelId: 'raw-bytes',
      channelUuid: '00000000-0000-0000-0000-00000000a101',
      properties: BleChannelProperties(read: true),
      codec: BytesChannelCodec(),
    ),
    const BleChannelDefinition<String>(
      channelId: 'text',
      channelUuid: '00000000-0000-0000-0000-00000000a102',
      properties: BleChannelProperties(read: true, write: true, notify: true),
      codec: Utf8ChannelCodec(),
    ),
    const BleChannelDefinition<dynamic>(
      channelId: 'json-payload',
      channelUuid: '00000000-0000-0000-0000-00000000a103',
      properties: const BleChannelProperties(read: true, write: true),
      codec: ChannelCodecs.json,
    ),
  ],
);
```

## Auth Flow Example

```dart
final authManager = BluetoothLeAuthManager(
  protocolClient: client,
  channels: const BluetoothLeAuthChannels(
    protocolId: 'auth',
    challengeChannelId: 'challenge',
    responseChannelId: 'response',
    resultChannelId: 'result',
  ),
  secret: Uint8List.fromList('shared-secret'.codeUnits),
);

await authManager.authorize();

await authManager.ensureAuthorized<void>(() async {
  await client.writeChannel<String>('device-control', 'command', 'unlock');
});
```

HMAC input format is:

`sessionId + ":" + nonce`

with signature:

`HMAC_SHA256(secret, sessionId + ":" + nonce)` (hex encoded).

## Chunked Transport Example

```dart
await client.sendChunked<String>(
  'device-control',
  'chunked-data',
  largePayload,
  options: const ChunkSendOptions(
    withoutResponse: true,
    // Optional override when needed:
    // maxChunkPayloadSize: 160,
  ),
);

final stream = client.subscribeChunkedChannel<String>(
  'device-control',
  'chunked-data',
);
```

Wire frame format:

- `byte 0`: version (`1`)
- `bytes 1-4`: uint32 sequence (big-endian)
- `bytes 5-6`: uint16 total chunks
- `bytes 7-8`: uint16 chunk index
- `bytes 9..n`: chunk payload

## Production Notes

- Keep BLE pairing/bonding and app-level auth separate concerns.
- Use platform-specific permission and Bluetooth state checks before scan/connect.
- Re-discover services after reconnect (`discoverServices()` must run per connection).
- Tune MTU/chunk sizes for your peripherals and platform characteristics.
- Keep auth secret handling in secure storage, not hardcoded constants.
- Revoke local auth state on disconnect (enabled by default in `BluetoothLeAuthManager`).

## API Map

- Server `protocol/channel` <-> Client `BleProtocolDefinition` / `BleChannelDefinition`
- Server `sendChunked(...)` <-> Client `sendChunked(...)` + `ChunkReassembler`
- Server auth manager <-> Client `BluetoothLeAuthManager`

## Example

A working Flutter example app is included at:

`example/lib/main.dart`

It demonstrates:

- scan + connect
- auth handshake
- typed read/write
- channel subscription
- chunked send/reassembly
