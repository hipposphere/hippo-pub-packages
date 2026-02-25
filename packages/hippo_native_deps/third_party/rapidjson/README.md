# RapidJSON Vendor Directory

This directory stores vendored RapidJSON headers for `hippo_native_deps`.

Expected layout:

```text
third_party/rapidjson/
  include/
    rapidjson/document.h
    ...
  LICENSE
  VERSION
```

Install or update RapidJSON:

```bash
bash tool/fetch_rapidjson.sh
```

Install a specific tag:

```bash
bash tool/fetch_rapidjson.sh v1.1.0
```
