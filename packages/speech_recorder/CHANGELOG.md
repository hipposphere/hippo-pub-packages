## Unreleased

- Raise the minimum `speech_utils` dependency to `0.2.5` so Android builds
  always resolve a plugin-enabled/native-asset-enabled `speech_utils`
  release.
- Breaking: replace `RecordConfig` with `AudioRecorderConfig`.
- Move encoding options to `AudioRecorderConfig.encoding`
  (`AudioEncodingConfig`).
- Remove streaming-level encoder overrides from
  `SpeechRecorderStreamingOptions`; streaming now uses
  `SpeechRecorderOptions.recordConfig.encoding` as single source of truth.
- Breaking: streaming sessions now always use
  `NativeAudioRecorder.startVadCapture(VadCaptureRequest)` (no legacy/manual
  fallback segmentation path in `speech_recorder`).
- Breaking: remove streaming fallback/full-recording options from
  `SpeechRecorderStreamingOptions`
  (`encodeFullRecordingOnStop`, `emitStopFallbackSegmentIfEmpty`,
  `segmentPathBuilder`).

## 0.1.0:
- First release
