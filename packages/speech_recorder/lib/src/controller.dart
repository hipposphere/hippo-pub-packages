import 'dart:async';
import 'package:hippo_utils/cross_file.dart';
import 'package:hippo_utils/hippo_utils.dart';
import 'package:speech_recorder/speech_recorder.dart';
import 'package:record/record.dart' as record;
import 'package:speech_recorder/src/models/recorder_data.dart';
import 'package:speech_recorder/src/utils/media_data_reader.dart';

class SpeechRecorderController {
  final Future<SpeechRecorderOptions> Function() optionsBuilder;
  final Function(SpeechRecorderSession session)? onSessionStarted;
  final Function(SpeechRecorderSession session)? onSessionFinished;

  SpeechRecorderController({
    required this.optionsBuilder,
    this.onSessionStarted,
    this.onSessionFinished,
  });
  final record.AudioRecorder _recorder = record.AudioRecorder();

  final sessionSubject = DataSubject<SpeechRecorderSession?>.seeded(null);

  Future<SpeechRecorderSession> start() async {
    final options = await optionsBuilder();
    await _recorder.start(options.recordConfig, path: options.path);
    final session = SpeechRecorderSession.create(
      options: options,
      recorder: _recorder,
    );
    session._setState(SpeechRecorderSessionState.recording);
    _startAmplitudeListening(session, options.amplitudeInterval);
    session.stopwatch.start();
    sessionSubject.add(session);
    onSessionStarted?.call(session);
    return session;
  }

  Future<void> pause(SpeechRecorderSession session) async {
    await _recorder.pause();

    session._setState(SpeechRecorderSessionState.paused);
    _stopAmplitudeListening(session);
    session.stopwatch.stop();
  }

  Future<void> resume(SpeechRecorderSession session) async {
    await _recorder.resume();
    _startAmplitudeListening(session, session.options.amplitudeInterval);
    session._setState(SpeechRecorderSessionState.recording);
    session.stopwatch.start();
  }

  Future<void> stop(SpeechRecorderSession session) async {
    final path = await _recorder.stop();
    session._setPathAfterStopping(path);
    _stopAmplitudeListening(session);
    session._setState(SpeechRecorderSessionState.stopped);
    session.stopwatch.stop();
    onSessionFinished?.call(session);
    sessionSubject.add(null);
  }

  Future<void> cancel(SpeechRecorderSession session) async {
    await _recorder.cancel();
    _stopAmplitudeListening(session);
    session._setState(SpeechRecorderSessionState.canceled);
    session.stopwatch.stop();
    sessionSubject.add(null);
  }

  Future<List<InputDevice>> listInputDevices() async {
    return _recorder.listInputDevices();
  }

  Future<void> dispose() async {
    await _recorder.dispose();
  }

  void _startAmplitudeListening(
    SpeechRecorderSession session,
    Duration interval,
  ) {
    session._amplitudeSubscription = _recorder
        .onAmplitudeChanged(interval)
        .listen((amplitude) {
          final amplitudeList = session.amplitudeSubject.value;
          amplitudeList.add(amplitude);
          session.amplitudeSubject.add(amplitudeList);
        });
  }

  void _stopAmplitudeListening(SpeechRecorderSession session) {
    session._amplitudeSubscription?.cancel();
    session._amplitudeSubscription = null;
  }
}

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
    return XFile(path);
  }

  Future<SpeechRecorderData> getRecordingData() async {
    final file = getRecordingFile();
    // Stopwatch is not the accurate duration, we need to get the actual duration
    // from the file metadata or similar.
    final duration = await MediaDataReader.getMediaDurationFromXFile(file);
    final fileExtension = file.name.split('.').last;
    final mimeType = file.mimeType!;
    return SpeechRecorderData(
      file: file,

      duration: duration,
      fileExtension: fileExtension,
      mimeType: mimeType,
    );
  }
}
