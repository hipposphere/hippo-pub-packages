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
Dart hook. Keep the FFmpeg build license-compatible with package distribution
requirements and update notices when replacing this SDK.
