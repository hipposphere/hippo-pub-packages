# Windows FFmpeg Pipeline

`speech_utils` uses FFmpeg on Windows for native AAC encoding and audio
metadata. The build hook can auto-build a minimal FFmpeg profile when the SDK
is missing.

Build hook implementation:
- `hook/src/windows_ffmpeg_pipeline.dart`
- `hook/src/aac_assets.dart`

Environment variables:
- `SPEECH_UTILS_WINDOWS_FFMPEG_AUTOBUILD=1`
  - Enables auto-build when `include/lib/bin` are missing.
- `SPEECH_UTILS_WINDOWS_FFMPEG_SOURCE_DIR=<path-to-ffmpeg-source>`
  - Optional. Defaults to `third_party/ffmpeg/source/ffmpeg`.
- `SPEECH_UTILS_WINDOWS_FFMPEG_REQUIRED=1`
  - Optional. Forces build failure when FFmpeg SDK artifacts are missing.
  - By default, missing SDK skips Windows AAC/metadata native asset build.

CI prebuild workflow:
- `.github/workflows/build_windows_ffmpeg_lib.yml`
  - Manually trigger with `workflow_dispatch`.
  - Builds a pinned FFmpeg ref on `windows-latest`.
  - Uploads a zip artifact with:
    - `include/`
    - `lib/`
    - `bin/`
    - `BUILD-METADATA.json`

Host prerequisites (Windows):
- Build runs through `bash` + `make` with FFmpeg configured as `--toolchain=msvc`.
- Run from a Visual Studio developer shell so `cl`/`link` are available.

Generated SDK layout:

```text
third_party/ffmpeg/windows/
  include/
    libavcodec/...
    libavformat/...
    libavutil/...
    libswresample/...
  lib/
    avcodec.lib
    avformat.lib
    avutil.lib
    swresample.lib
  bin/
    avcodec-*.dll
    avformat-*.dll
    avutil-*.dll
    swresample-*.dll
```

Notes:
- Runtime DLLs from `bin/` are automatically bundled as native assets.
- The build profile is intentionally minimal (audio-focused, no video pipeline),
  see `SOURCE.txt`.
