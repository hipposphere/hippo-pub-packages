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
- `--default-codec`: One of `bytes`, `utf8`, `json` (default: `bytes`).
- `--codec-overrides`: Optional JSON file with explicit codec overrides.

Codec override file format:

```json
{
  "auth/challenge": "json",
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

For JSON channels, codec metadata can include optional per-direction JSON Schema.
When present, the builder generates typed Dart payload models with `fromJson`/`toJson`.

```json
{
  "id": "command",
  "uuid": "1234567812345678123456789abc0002",
  "properties": ["read", "write", "notify"],
  "codec": {
    "name": "json",
    "jsonSchema": {
      "send": {
        "type": "object",
        "properties": {
          "status": { "type": "string" }
        },
        "required": ["status"],
        "additionalProperties": false
      },
      "receive": {
        "type": "object",
        "properties": {
          "command": { "type": "string" }
        },
        "required": ["command"],
        "additionalProperties": false
      }
    }
  }
}
```

`send` is used for server-to-client payloads (`read/watch`) and `receive` for
client-to-server payloads (`write/sendChunked`).

Codec precedence is:
`--codec-overrides` > contract `codec` > `--default-codec`.
