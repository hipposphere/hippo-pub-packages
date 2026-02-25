# WIL Vendor Directory

This directory stores vendored WIL headers for `hippo_native_deps`.

Expected layout:

```text
third_party/wil/
  include/
    wil/resource.h
    ...
  LICENSE
  VERSION
```

Install or update WIL:

```bash
bash tool/fetch_wil.sh
```

Install a specific tag:

```bash
bash tool/fetch_wil.sh v1.0.260126.7
```
