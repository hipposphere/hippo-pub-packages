part of 'controller.dart';

enum SpeechRecorderSessionState { idle, recording, paused, stopped, canceled }

class SpeechRecorderSession {
  final SpeechRecorderOptions options;
  final bool isStreaming;
  final NativeAudioMetadataReader _audioMetadataReader;

  SpeechRecorderSession({
    required this.options,
    required this.isStreaming,
    NativeAudioMetadataReader? audioMetadataReader,
  }) : _audioMetadataReader =
           audioMetadataReader ?? NativeAudioMetadataReader();

  factory SpeechRecorderSession.create({
    required record.AudioRecorder recorder,
    required SpeechRecorderOptions options,
    required bool isStreaming,
  }) {
    return SpeechRecorderSession(options: options, isStreaming: isStreaming);
  }

  final stateSubject = DataSubject<SpeechRecorderSessionState>.seeded(
    SpeechRecorderSessionState.idle,
  );

  final stopwatch = Stopwatch();

  final amplitudeSubject = DataSubject<List<record.Amplitude>>.seeded([]);

  StreamSubscription? _amplitudeSubscription;
  StreamSubscription<void>? _streamingSegmentSubscription;
  int _segmentCount = 0;

  int _nextSegmentIndex() {
    _segmentCount++;
    return _segmentCount;
  }

  void _setState(SpeechRecorderSessionState state) {
    stateSubject.add(state);
  }

  void _setRecordingOutputAfterStopping({
    required String path,
    required String mimeType,
    required String fileExtension,
  }) {
    _recordingOutputAfterStopping = _SpeechRecorderRecordingOutput(
      path: path,
      mimeType: mimeType,
      fileExtension: fileExtension,
    );
  }

  _SpeechRecorderRecordingOutput? _recordingOutputAfterStopping;
  BytesBuilder? _streamingPcm16Capture;

  void _enableStreamingPcm16Capture() {
    _streamingPcm16Capture = BytesBuilder();
  }

  void _captureStreamingPcm16Chunk(Uint8List bytes) {
    _streamingPcm16Capture?.add(bytes);
  }

  Uint8List _consumeStreamingPcm16Capture() {
    final capture = _streamingPcm16Capture;
    _streamingPcm16Capture = null;
    return capture?.toBytes() ?? Uint8List(0);
  }

  void _discardStreamingPcm16Capture() {
    _streamingPcm16Capture = null;
  }

  _SpeechRecorderRecordingOutput? _resolveRecordingOutput() {
    final output = _recordingOutputAfterStopping;
    if (output != null) {
      return output;
    }
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
        'For streaming sessions, enable '
        'streaming.encodeFullRecordingOnStop to access it.',
      );
    }
    return XFile(output.path, mimeType: output.mimeType);
  }

  Future<SpeechRecorderData> getRecordingData() async {
    final output = _resolveRecordingOutput();
    if (output == null) {
      throw StateError(
        'No full recording data is available for this session. '
        'For streaming sessions, enable '
        'streaming.encodeFullRecordingOnStop to access it.',
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
