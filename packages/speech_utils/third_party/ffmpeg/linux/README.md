# Linux FFmpeg SDK

The Linux AAC encoder and audio metadata native asset expects a vendored
FFmpeg SDK here:

```text
third_party/ffmpeg/linux/
  include/
    libavcodec/
    libavformat/
    libavutil/
    libswresample/
  lib/
    libavcodec.so
    libavcodec.so.*
    libavformat.so
    libavformat.so.*
    libavutil.so
    libavutil.so.*
    libswresample.so
    libswresample.so.*
```

The unversioned `lib*.so` files are required for linking. Versioned runtime
libraries are bundled next to `libspeech_utils_linux_audio_encoder.so` by the
Dart hook.

Build the SDK from the repository root:

```bash
packages/speech_utils/tool/build_linux_ffmpeg_sdk.sh
```

On non-Linux hosts this uses Docker and defaults to `--docker-platform
linux/amd64`. To build for Linux arm64 instead:

```bash
packages/speech_utils/tool/build_linux_ffmpeg_sdk.sh --docker-platform linux/arm64
```

Validate an existing bundle:

```bash
packages/speech_utils/tool/verify_linux_ffmpeg_bundle.sh
```

The build is pinned to FFmpeg `n8.0.1` by default and writes
`BUILD-METADATA.txt` with the exact commit/configure flags. Keep the FFmpeg
build license-compatible with package distribution requirements and update
notices when replacing this SDK.
