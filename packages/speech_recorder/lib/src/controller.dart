import 'dart:async';

import 'package:hippo_utils/hippo_utils.dart';
import 'package:speech_recorder/speech_recorder.dart';
import 'package:record/record.dart' as record;

class SpeechRecorderController {
  final record.AudioRecorder _recorder = record.AudioRecorder();

  final sessionSubject = DataSubject<SpeechRecorderSession?>.seeded(null);

  Future<SpeechRecorderSession> start(SpeechRecorderOptions options) async {
    await _recorder.start(options.recordConfig, path: options.path);
    final session = SpeechRecorderSession.create(
      options: options,
      recorder: _recorder,
    );
    session._setState(SpeechRecorderSessionState.recording);
    _startAmplitudeListening(session, options.amplitudeInterval);
    session.stopwatch.start();
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
    session._setPath(path);
    _stopAmplitudeListening(session);
    session._setState(SpeechRecorderSessionState.stopped);
    session.stopwatch.stop();
  }

  Future<void> cancel(SpeechRecorderSession session) async {
    await _recorder.cancel();
    _stopAmplitudeListening(session);
    session._setState(SpeechRecorderSessionState.canceled);
    session.stopwatch.stop();
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

  void _setPath(String? path) {
    // Not implemented in this simplified example.
  }
}
