# Windows AAC Native Architecture

This folder keeps Windows AAC/metadata native logic split by responsibility while preserving one public DLL export surface.

## File layout

- `windows_ffmpeg_common.h/.cpp`
  - Shared FFmpeg helpers (`WriteError`, `AvErrorToString`, output text helpers, duration helpers).
- `windows_audio_encoder_transcoder.h/.cpp`
  - AAC transcoding pipeline (`decode -> resample -> fifo -> encode -> mux`) and AAC healthcheck.
- `windows_audio_metadata.h/.cpp`
  - Audio metadata probing and metadata healthcheck.
- `../speech_utils_windows_audio_encoder.cpp`
  - Thin exported bridge that keeps stable C ABI symbols used by Dart FFI bindings.

## Why this shape

- Keeps FFI exports stable while allowing internal refactors.
- Avoids one large translation unit.
- Makes FFmpeg upgrades safer because metadata and transcoding logic are isolated.
