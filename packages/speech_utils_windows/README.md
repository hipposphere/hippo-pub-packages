# speech_utils_windows

Windows implementation for the federated `speech_utils` family. It preserves
the existing miniaudio capture engine, WebRTC audio processing, and bundled
FFmpeg/libavcodec AAC and metadata implementation. It does not use Media
Foundation or any `record`-family package.
