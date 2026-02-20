## Unreleased

- Breaking: replace `RecordConfig` with `AudioRecorderConfig`.
- Move encoding options to `AudioRecorderConfig.encoding`
  (`AudioEncodingConfig`).
- Remove streaming-level encoder overrides from
  `SpeechRecorderStreamingOptions`; streaming now uses
  `SpeechRecorderOptions.recordConfig.encoding` as single source of truth.
- Breaking: streaming sessions now always use
  `NativeAudioRecorder.startWithVadSegmentation(...)` (no legacy/manual
  fallback segmentation path in `speech_recorder`).
- Breaking: remove streaming fallback/full-recording options from
  `SpeechRecorderStreamingOptions`
  (`encodeFullRecordingOnStop`, `emitStopFallbackSegmentIfEmpty`,
  `segmentPathBuilder`).

## 0.1.0:
- First release
