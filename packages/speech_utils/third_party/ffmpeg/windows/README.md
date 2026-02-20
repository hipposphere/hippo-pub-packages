# Windows FFmpeg Pipeline

`speech_utils` uses FFmpeg on Windows for native AAC encoding and audio
metadata. The build hook expects a prebuilt FFmpeg SDK in
`third_party/ffmpeg/windows`.

Build hook implementation:
- `hook/src/windows_ffmpeg_pipeline.dart`
- `hook/src/aac_assets.dart`

CI prebuild workflow:
- `.github/workflows/build_windows_ffmpeg_lib.yml`
  - Trigger manually via `workflow_dispatch`.
  - Produces `include/`, `lib/`, and `bin/` for Windows packaging.

Expected SDK layout:

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
    # optional transitive runtime deps:
    # libiconv-2.dll, libwinpthread-1.dll, zlib1.dll
```

Notes:
- The hook only bundles AAC/metadata-relevant FFmpeg runtimes.
- The hook does not auto-build FFmpeg locally.

Validate bundle locally:

```powershell
powershell -ExecutionPolicy Bypass -File packages/speech_utils/tool/verify_windows_ffmpeg_bundle.ps1
```
