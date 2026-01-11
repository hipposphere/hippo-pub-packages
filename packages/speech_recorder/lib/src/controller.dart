import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hippo_utils/hippo_utils.dart';
import 'package:speech_recorder/speech_recorder.dart';
import 'package:record/record.dart' as record;
import 'package:cross_file/cross_file.dart';
import 'utils/media_data_reader.dart';

part 'session.dart';

typedef SpeechRecorderCallback = void Function(SpeechRecorderSession session);

class SpeechRecorderController {
  final Future<SpeechRecorderOptions> Function() optionsBuilder;
  final SpeechRecorderCallback? _onSessionStarted;
  final SpeechRecorderCallback? _onSessionFinished;

  SpeechRecorderController({
    required this.optionsBuilder,
    SpeechRecorderCallback? onSessionStarted,
    SpeechRecorderCallback? onSessionFinished,
  }) : _onSessionStarted = onSessionStarted,
       _onSessionFinished = onSessionFinished;

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
    _onSessionStarted?.call(session);
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
    for (final callback in session._onFinishedCallbacks) {
      callback();
    }
    _onSessionFinished?.call(session);
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

  Future<bool> hasPermission() async {
    return _recorder.hasPermission();
  }

  Future<void> requestPermission() async {
    throw UnimplementedError();
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
