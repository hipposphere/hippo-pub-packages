# sherpa-onnx native runtime

This directory vendors the keyword-spotting C API and prebuilt native runtime
from `k2-fsa/sherpa-onnx` version 1.13.4.

- Repository: https://github.com/k2-fsa/sherpa-onnx
- Tag: `v1.13.4`
- Header: `sherpa-onnx/c-api/c-api.h`
- `include/keyword_spotter_ffi_bridge.h`: local declaration-only subset used by
  ffigen; keep its layouts in sync with the upstream header.
- License: Apache-2.0 (see `LICENSE`)

Only `sherpa-onnx-c-api` and its ONNX Runtime dependencies are bundled. The
C++ API library distributed in the upstream Flutter platform packages is not
included.

The iOS binaries are extracted from the upstream XCFramework. Other binaries
come from the corresponding upstream Flutter platform packages. Update all
platforms, the header, generated Dart bindings, and this version together.
