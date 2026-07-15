## 0.3.1

- Resolve shared speech packages from the Hippo internal registry.

## 0.3.0

- Add the endorsed Windows miniaudio capture implementation with WebRTC audio
  processing and warm-capture behavior.
- Move bundled FFmpeg/libavcodec AAC and metadata, native bindings, runtime
  DLLs, build hooks, and verification tooling out of `speech_utils`.
- Do not introduce Media Foundation capture or a record-family dependency.
- Move DSP, amplitude analysis, stream buffering, and WAV writes off the
  miniaudio callback onto a dedicated processing thread with a bounded queue.
- Drain callback and processing work before stop/reset, report queue overflow
  and file-write failures, and preserve initialized WebRTC processing state.
