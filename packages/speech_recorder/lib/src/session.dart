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

  void _setPathAfterStopping(String? path) {
    _pathAfterStopping = path;
  }

  String? _pathAfterStopping;

  XFile getRecordingFile() {
    if (isStreaming) {
      throw StateError(
        'No full recording file is available for streaming sessions. '
        'Use onSegmentFinished callbacks instead.',
      );
    }
    final path = _pathAfterStopping ?? options.path;
    return XFile(path, mimeType: options.mimeType);
  }

  Future<SpeechRecorderData> getRecordingData() async {
    if (isStreaming) {
      throw StateError(
        'No full recording data is available for streaming sessions. '
        'Use onSegmentFinished callbacks instead.',
      );
    }
    final file = getRecordingFile();
    // Stopwatch is not the accurate duration, we need to get the actual duration
    // from the file metadata or similar.
    final duration = await _audioMetadataReader.readAudioDuration(
      inputPath: file.path,
    );
    final mimeType = file.mimeType!;
    return SpeechRecorderData(
      file: file,
      duration: duration,
      fileExtension: options.fileExtension,
      mimeType: mimeType,
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
