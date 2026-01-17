part of 'controller.dart';

enum SpeechRecorderSessionState { idle, recording, paused, stopped, canceled }

class SpeechRecorderSession {
  final SpeechRecorderOptions options;

  SpeechRecorderSession({required this.options});

  factory SpeechRecorderSession.create({
    required record.AudioRecorder recorder,
    required SpeechRecorderOptions options,
  }) {
    return SpeechRecorderSession(options: options);
  }

  final stateSubject = DataSubject<SpeechRecorderSessionState>.seeded(
    SpeechRecorderSessionState.idle,
  );

  final stopwatch = Stopwatch();

  final amplitudeSubject = DataSubject<List<Amplitude>>.seeded([]);

  StreamSubscription? _amplitudeSubscription;

  void _setState(SpeechRecorderSessionState state) {
    stateSubject.add(state);
  }

  void _setPathAfterStopping(String? path) {
    _pathAfterStopping = path;
  }

  String? _pathAfterStopping;

  XFile getRecordingFile() {
    final path = _pathAfterStopping ?? options.path;
    return XFile(path, mimeType: options.mimeType);
  }

  Future<SpeechRecorderData> getRecordingData() async {
    final file = getRecordingFile();
    // Stopwatch is not the accurate duration, we need to get the actual duration
    // from the file metadata or similar.
    final duration = await MediaDataReader.getMediaDurationFromXFile(file);
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
}
