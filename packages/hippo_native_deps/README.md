# hippo_native_deps

Shared native dependency package for hook-based C/C++ builds in this monorepo.

Currently published metadata:

- `rapidjson_include_dir`
- `rapidjson_version`
- `wil_include_dir`
- `wil_version`

## RapidJSON setup

Vendor RapidJSON once into this package:

```bash
cd packages/hippo_native_deps
bash tool/fetch_rapidjson.sh
```

## WIL setup

Vendor WIL once into this package:

```bash
cd packages/hippo_native_deps
bash tool/fetch_wil.sh
```

## Using in another hook

Consumer packages can depend on `hippo_native_deps` and use the shared helper
APIs in `hook/build.dart`:

```dart
import 'package:hippo_native_deps/hippo_native_deps.dart';

final includes = requireNativeDepsWindowsIncludeDirs(input);
// or:
final rapidjson = requireRapidjsonIncludeDir(input);
final wil = requireWilIncludeDir(input);
```

Recommended: add `hippo_native_deps` as a dependency for every package that
compiles native code in hooks.
