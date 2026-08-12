## Unreleased

- Breaking: Replace `SubjectTextField`'s deprecated
  `TextEditingDataSubject` input with separate `TextEditingController` and
  `DataSubject<String>` inputs.
- Re-export secure-storage and shared-preferences key-value stores from their
  dedicated `hippo_core_flutter` adapter packages.
- Breaking: Replace the local `JsonSchema`, `JsonSchemaModel`, and `JsonPointer`
  implementations with `json_schema` 0.1.4 from
  `https://pub.hippolabs.org` while retaining the editor node APIs.

## 0.3.3

- Breaking: Move the `KeyValueStore` contract to `hippo_core`; keep concrete key-value store implementations in `hippo_utils`.
- Add compatibility exports for Flutter-facing core APIs moved to `hippo_core_flutter`.
- Add JSON Pointer-based value lookup helpers for decoded JSON documents.
- Add conversion helpers from `JsonSchemaPath` to JSON Pointer strings.
- Update app links, audio, file, sharing, and package info dependency
  constraints.

## 0.1.0:
- First release
