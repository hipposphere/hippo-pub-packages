part of 'controller.dart';

enum SpeechRecorderSessionState { idle, recording, paused, stopped, canceled }

class SpeechRecorderSession {
  final SpeechRecorderOptions options;
  final SpeechRecorderStreamingOptions? streamingOptions;
  final NativeAudioMetadataReader _audioMetadataReader =
      NativeAudioMetadataReader();

  SpeechRecorderSession({required this.options, this.streamingOptions});

  factory SpeechRecorderSession.create({
    required SpeechRecorderOptions options,
    SpeechRecorderStreamingOptions? streamingOptions,
  }) {
    return SpeechRecorderSession(
      options: options,
      streamingOptions: streamingOptions,
    );
  }

  bool get isStreaming => streamingOptions != null;

  final stateSubject = DataSubject<SpeechRecorderSessionState>.seeded(
    SpeechRecorderSessionState.idle,
  );

  final stopwatch = Stopwatch();

  final amplitudeSubject = DataSubject<List<Amplitude>>.seeded([]);

  final segmentsSubject = DataSubject<List<SpeechRecorderSegmentData>>.seeded(
    [],
  );

  StreamSubscription<Amplitude>? _amplitudeSubscription;
  StreamSubscription<void>? _streamingSegmentSubscription;
  VadCaptureSession? _vadCaptureSession;

  void _setState(SpeechRecorderSessionState state) {
    stateSubject.add(state);
  }

  _SpeechRecorderRecordingOutput? _resolveRecordingOutput() {
    if (!isStreaming) {
      return _SpeechRecorderRecordingOutput(
        path: options.path,
        mimeType: options.mimeType,
        fileExtension: options.fileExtension,
      );
    }
    return null;
  }

  XFile getRecordingFile() {
    final output = _resolveRecordingOutput();
    if (output == null) {
      throw StateError(
        'No full recording file is available for this session. '
        'Streaming sessions emit segments only.',
      );
    }
    return XFile(output.path, mimeType: output.mimeType);
  }

  Future<SpeechRecorderData> getRecordingData() async {
    final output = _resolveRecordingOutput();
    if (output == null) {
      throw StateError(
        'No full recording data is available for this session. '
        'Streaming sessions emit segments only.',
      );
    }
    final file = getRecordingFile();
    final metadata = await _audioMetadataReader.readAudioMetadata(
      inputPath: file.path,
    );
    final mimeType = file.mimeType!;
    return SpeechRecorderData(
      file: file,
      duration: metadata.duration,
      fileExtension: output.fileExtension,
      mimeType: mimeType,
      sampleRateHz: metadata.sampleRateHz,
      channelCount: metadata.channelCount,
      bitrateBps: metadata.bitrateBps,
      containerFormat: metadata.containerFormat,
      codec: metadata.codec,
      codecProfile: metadata.codecProfile,
    );
  }

  final List<VoidCallback> _onFinishedCallbacks = [];

  void onSessionFinished(VoidCallback callback) {
    _onFinishedCallbacks.add(callback);
  }

  final List<SpeechRecorderSegmentCallback> _onSegmentFinishedCallbacks = [];

  void onSegmentFinished(SpeechRecorderSegmentCallback callback) {
    if (_onSegmentFinishedCallbacks.contains(callback)) {
      return;
    }
    _onSegmentFinishedCallbacks.add(callback);
  }
}

class _SpeechRecorderRecordingOutput {
  final String path;
  final String mimeType;
  final String fileExtension;

  const _SpeechRecorderRecordingOutput({
    required this.path,
    required this.mimeType,
    required this.fileExtension,
  });
}
