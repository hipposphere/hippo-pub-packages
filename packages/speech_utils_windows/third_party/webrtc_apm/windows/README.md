# Windows WebRTC AudioProcessing (APM) Pipeline

`speech_utils` can use WebRTC AudioProcessing on Windows as the software
voice-processing backend. The build hook discovers a vendored WebRTC APM SDK in
`third_party/webrtc_apm/windows`.

Build hook implementation:
- `hook/src/windows_webrtc_apm_pipeline.dart`
- `hook/src/recorder_assets.dart`

Expected SDK layout:

```text
third_party/webrtc_apm/windows/
  include/
    webrtc-audio-processing-1/modules/audio_processing/include/audio_processing.h
    # (or include/modules/audio_processing/include/audio_processing.h)
    # + transitive WebRTC headers
  lib/
    webrtc-audio-processing-1.lib
    # or webrtc_audio_processing*.lib / audio_processing*.lib
  bin/
    webrtc-audio-processing-*.dll   # optional when linking dynamically
    webrtc-audio-coding-*.dll       # optional dependency runtime
```

Notes:
- The build hook requires this vendored SDK to be complete. Missing headers,
  import libraries, or runtime DLLs fail the Windows recorder native build.
- Runtime WebRTC DLLs are copied/bundled automatically when present.

Validate bundle locally:

```powershell
powershell -ExecutionPolicy Bypass -File packages/speech_utils/tool/verify_windows_webrtc_apm_bundle.ps1
```
