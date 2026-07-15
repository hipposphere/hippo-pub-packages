# speech_utils_windows

Windows implementation for the federated `speech_utils` family. It preserves
the existing miniaudio capture engine, WebRTC audio processing, and bundled
FFmpeg/libavcodec AAC and metadata implementation. It does not use Media
Foundation or any `record`-family package.

The miniaudio device callback only copies PCM16 samples into a preallocated,
bounded single-producer/single-consumer queue. A dedicated native thread owns
WebRTC/software processing, amplitude calculation, stream buffering, and WAV
file writes. Stop and reset operations pause callback admission and drain the
queue before changing devices or closing files; capture queue overflow is
reported as a recorder error instead of silently truncating audio.
