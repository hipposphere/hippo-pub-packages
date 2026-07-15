## 0.3.0

- Add the endorsed Windows miniaudio capture implementation with WebRTC audio
  processing and warm-capture behavior.
- Move bundled FFmpeg/libavcodec AAC and metadata, native bindings, runtime
  DLLs, build hooks, and verification tooling out of `speech_utils`.
- Do not introduce Media Foundation capture or a record-family dependency.
