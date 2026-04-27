# TEN VAD Third-Party Assets

This directory vendors TEN VAD artifacts used by `speech_utils`.

Source:
- Repository: `TEN-framework/ten-vad`
- URL: `https://huggingface.co/TEN-framework/ten-vad`
- Revision: `e5da289cbfeaea0b49b9ef14d63c2a97f9c15622`
- Linux C++ runtime: Ubuntu 18.04 packages `libc++1` and `libc++abi1`
  version `6.0-2`

Bundled files:
- `include/ten_vad.h`
- `include/ten_vad_ffi_bridge.h` (local bridge for compact `ffigen` output)
- `lib/windows/x64/ten_vad.dll`
- `lib/linux/x64/libten_vad.so`
- `lib/linux/x64/runtime/libc++.so.1`
- `lib/linux/x64/runtime/libc++abi.so.1`
- `lib/linux/x64/runtime/COPYRIGHT.libc++`
- `lib/linux/x64/runtime/COPYRIGHT.libc++abi`
- `lib/android/arm64-v8a/libten_vad.so`
- `lib/android/armeabi-v7a/libten_vad.so`
- `lib/ios/ten_vad.framework/ten_vad`
- `lib/macos/ten_vad`
- `LICENSE`
- `NOTICES`

Checksums (SHA-256):
- `lib/windows/x64/ten_vad.dll`
  `38937f5604fa93a7941db7b9326992b792fa3731ebf9353973b3234457c6064b`
- `lib/linux/x64/libten_vad.so`
  `c93b21b24091cdf02df1e3f5c3a09acd6606c1393e52b10271a38cb5dcbfff29`
- `lib/linux/x64/runtime/libc++.so.1`
  `59105258aab1c4ad430a4f13204fd0047ed8c398588c9d356670652427742fd6`
- `lib/linux/x64/runtime/libc++abi.so.1`
  `b46964f5041f02eacaff6e46c22cf56e9d16e5dd8d633ba7b3f8b989d3af94f5`
- `lib/android/arm64-v8a/libten_vad.so`
  `317401e21b06e433dd2b457934d357664ff7e0a2ae0d815f0751ac730b1fe7b6`
- `lib/android/armeabi-v7a/libten_vad.so`
  `cc8b5ae17ceb87c49669d310c81bedf84c15c2086a7e0c98a25b415c79f0fe14`
- `lib/ios/ten_vad.framework/ten_vad`
  `bea8d9de252b41a23674e819b35781a55ecd6b9b71f8de52b9633ed201e0fd67`
- `lib/macos/ten_vad`
  `81b2de13710670bb94fef315ab50fedc903a21c04c4290c6c2ac28d8b42e715a`
