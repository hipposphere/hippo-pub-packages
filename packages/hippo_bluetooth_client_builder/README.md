# hippo_bluetooth_client_builder

Generate ready-to-use Dart BLE protocol/service clients from a BLE `contract.json`.

The generated Dart is directly compatible with
`package:hippo_bluetooth_client/hippo_bluetooth_client.dart`.

## Usage

```bash
dart run hippo_bluetooth_client_builder:hippo_bluetooth_client_builder \
  --input ./ble-contract.json \
  --output ./lib/ble/generated_ble_client.dart \
  --class-prefix Device
```

## Options

- `--input` (`-i`): Path to BLE contract JSON.
- `--output` (`-o`): Output Dart file path.
- `--class-prefix` (`-p`): Optional class prefix for generated types.
- `--library-name` (`-l`): Optional Dart library name for generated file.
- `--default-codec`: One of `bytes`, `utf8`, `jsonMap` (default: `bytes`).
- `--codec-overrides`: Optional JSON file with explicit codec overrides.

Codec override file format:

```json
{
  "auth/challenge": "jsonMap",
  "device-control/status": "utf8"
}
```

Keys are `protocolId/channelId`.

Contract characteristics can also define `codec` directly:

```json
{
  "id": "status",
  "uuid": "1234567812345678123456789abc0001",
  "properties": ["read", "notify"],
  "codec": "utf8"
}
```

Codec precedence is:
`--codec-overrides` > contract `codec` > `--default-codec`.
