## 0.2.15

- Raise the minimum `speech_utils` dependency to `0.2.5` so Android builds
  always resolve a plugin-enabled/native-asset-enabled `speech_utils`
  release.
- Update `cross_file` to `^0.3.5+3`.
- Raise the minimum `hippo_utils`, `hippo_components`, and `speech_utils`
  dependency constraints for publishing.
- Breaking: replace `RecordConfig` with `AudioRecorderConfig`.
- Move encoding options to `AudioRecorderConfig.encoding`
  (`AudioEncodingConfig`).
- Remove streaming-level encoder overrides from
  `SpeechRecorderStreamingOptions`; streaming now uses
  `SpeechRecorderOptions.recordConfig.encoding` as single source of truth.
- Breaking: streaming sessions now use
  `NativeAudioRecorder.startSegmentedCapture(SegmentedAudioCaptureRequest)`.
- Add manual streaming splits through `AudioSegmentSplitMode.manual` and
  `SpeechRecorderSession.splitSegment()`.
- Breaking: remove streaming fallback/full-recording options from
  `SpeechRecorderStreamingOptions`
  (`encodeFullRecordingOnStop`, `emitStopFallbackSegmentIfEmpty`,
  `segmentPathBuilder`).

## 0.1.0:
- First release
