# Changelog

## 0.1.0

- Add `hippo_native_deps` package with hook metadata for vendored RapidJSON.
- Vendor RapidJSON headers (`v1.1.0`) under `third_party/rapidjson/include`.
- Add `tool/fetch_rapidjson.sh` to populate `third_party/rapidjson/include`.
- Add hook metadata for vendored WIL (`wil_include_dir`, `wil_version`).
- Add `tool/fetch_wil.sh` and vendor WIL headers (`v1.0.260126.7`) under `third_party/wil/include`.
- Add reusable hook helper APIs for metadata lookup and include-dir resolution.
