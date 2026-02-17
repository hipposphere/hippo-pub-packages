# Changelog

## 0.1.2

- Switched JSON channel codec name to `json` in CLI/options/generated code.
- JSON channels now generate `dynamic` payload types for easier usage.
- Codec parsing now strictly supports `bytes`, `utf8`, and `json`.

## 0.1.1

- Added optional per-characteristic `codec` metadata support in BLE contracts.
- Added codec precedence: CLI overrides > contract codec > default codec.

## 0.1.0

- Initial release.
- Added CLI to generate Dart BLE client/services from BLE contract JSON.
