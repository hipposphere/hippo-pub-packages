import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hippo_utils/hippo_utils.dart';
import 'package:speech_utils/speech_utils.dart';

import 'models/options.dart';
import 'models/recorder_data.dart';
import 'models/segment_data.dart';
import 'models/streaming_options.dart';
import 'utils/options_validator.dart';

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

  final NativeAudioRecorder _recorder = NativeAudioRecorder();

  NativeAudioRecorder get audioRecorder => _recorder;

  final sessionSubject = DataSubject<SpeechRecorderSession?>.seeded(null);

  /// Whether a session is currently being initialized.
  /// Use this to prevent starting multiple sessions concurrently.
  bool _isInitializing = false;
  bool get isInitializing => _isInitializing;

  /// Whether a new session can be started.
  /// Returns true if no session is currently initializing and no active session exists.
  bool get canStartSession => !_isInitializing && sessionSubject.value == null;

  Future<SpeechRecorderSession> start() async {
    if (_isInitializing) {
      throw StateError(
        'Cannot start a new session while another session is initializing',
      );
    }
    if (sessionSubject.value != null) {
      throw StateError('A recording session is already active.');
    }

    _isInitializing = true;
    try {
      final options = await optionsBuilder();
      validateSpeechRecorderOptions(options);

      final session = SpeechRecorderSession.create(
        options: options,
        isStreaming: options.streaming != null,
      );

      await _startSessionCapture(session);

      session._setState(SpeechRecorderSessionState.recording);
      session.stopwatch.start();
      sessionSubject.add(session);
      _onSessionStarted?.call(session);
      return session;
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> pause(SpeechRecorderSession session) async {
    if (session.stateSubject.value != SpeechRecorderSessionState.recording) {
      return;
    }

    await _stopNativeRecorderIfRunning();
    await _drainStreamingSegmentation(session);
    await _stopAmplitudeListening(session);

    session._setState(SpeechRecorderSessionState.paused);
    session.stopwatch.stop();
  }

  Future<void> resume(SpeechRecorderSession session) async {
    if (session.stateSubject.value != SpeechRecorderSessionState.paused) {
      return;
    }

    await _startSessionCapture(session);

    session._setState(SpeechRecorderSessionState.recording);
    session.stopwatch.start();
  }

  Future<void> stop(SpeechRecorderSession session) async {
    if (session.stateSubject.value == SpeechRecorderSessionState.stopped ||
        session.stateSubject.value == SpeechRecorderSessionState.canceled) {
      return;
    }

    await _stopNativeRecorderIfRunning();
    await _drainStreamingSegmentation(session);
    await _stopAmplitudeListening(session);

    session._setState(SpeechRecorderSessionState.stopped);
    session.stopwatch.stop();
    for (final callback in session._onFinishedCallbacks) {
      callback();
    }
    _onSessionFinished?.call(session);
    sessionSubject.add(null);
  }

  Future<void> cancel(SpeechRecorderSession session) async {
    await _cancelStreamingSegmentation(session);
    await _stopNativeRecorderIfRunning();
    await _stopAmplitudeListening(session);

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

  Future<bool> requestPermission() async {
    return _recorder.requestPermission();
  }

  Future<void> dispose() async {
    await _recorder.dispose();
  }

  Future<void> _startSessionCapture(SpeechRecorderSession session) async {
    await _startAmplitudeListening(
      session: session,
      interval: session.options.amplitudeInterval,
    );

    final streamingOptions = session.options.streaming;
    if (streamingOptions == null) {
      await _ensureOutputParentDirectoryExists(session.options.path);
      await _recorder.start(
        outputPath: session.options.path,
        config: session.options.recordConfig,
      );
      return;
    }

    if (streamingOptions.onSegmentFinished case final callback?) {
      session.onSegmentFinished(callback);
    }

    await _startNativeStreamingSegmentation(
      session: session,
      streamingOptions: streamingOptions,
    );
  }

  Future<void> _startAmplitudeListening({
    required SpeechRecorderSession session,
    required Duration interval,
  }) async {
    await _stopAmplitudeListening(session);
    session._amplitudeSubscription = _recorder
        .onAmplitudeChanged(interval)
        .listen(
          (amplitude) {
            final amplitudeList = List<Amplitude>.of(
              session.amplitudeSubject.value,
            );
            amplitudeList.add(amplitude);
            session.amplitudeSubject.add(amplitudeList);
          },
          onError: (Object error, StackTrace stackTrace) {
            debugPrint('Speech recorder amplitude stream failed: $error');
          },
        );
  }

  Future<void> _stopAmplitudeListening(SpeechRecorderSession session) async {
    await session._amplitudeSubscription?.cancel();
    session._amplitudeSubscription = null;
  }

  Future<void> _stopNativeRecorderIfRunning() async {
    if (!_recorder.isRecording) {
      return;
    }
    await _recorder.stop();
  }

  Future<void> _startNativeStreamingSegmentation({
    required SpeechRecorderSession session,
    required SpeechRecorderStreamingOptions streamingOptions,
  }) async {
    final splitOptions = streamingOptions.pauseSplitOptions;
    final recordConfig = session.options.recordConfig;
    final vadConfig =
        streamingOptions.vadConfig ??
        session.options.vadConfig ??
        const SpeechVadConfig();

    final outputDirectory = Directory(
      _defaultSegmentsOutputDirectory(session.options.path),
    );
    final stream = await _recorder.startWithVadSegmentation(
      outputDirectory: outputDirectory,
      splitOptions: splitOptions,
      config: recordConfig,
      vadConfig: vadConfig,
      flushOnStop: true,
      segmentPathBuilder: (segmentIndex, fileExtension) {
        return _defaultSegmentRelativePath(
          sessionPath: session.options.path,
          segmentIndex: segmentIndex,
          fileExtension: fileExtension,
        );
      },
    );

    session._streamingSegmentSubscription = stream
        .asyncMap((segment) async {
          await _handleNativeStreamingSegment(
            session: session,
            streamingOptions: streamingOptions,
            segment: segment,
          );
        })
        .listen(
          (_) {},
          onError: (Object error, StackTrace stackTrace) {
            debugPrint('Speech recorder native streaming failed: $error');
          },
        );
  }

  Future<void> _handleNativeStreamingSegment({
    required SpeechRecorderSession session,
    required SpeechRecorderStreamingOptions streamingOptions,
    required VoiceSegment segment,
  }) async {
    final segmentData = SpeechRecorderSegmentData(
      index: segment.index,
      file: segment.file,
      duration: segment.metadata.duration,
      fileExtension: segment.fileExtension,
      mimeType: segment.mimeType,
      sampleRateHz:
          segment.metadata.sampleRateHz ??
          streamingOptions.pauseSplitOptions.sampleRateHz,
      channelCount:
          segment.metadata.channelCount ??
          streamingOptions.pauseSplitOptions.channelCount,
      bitrateBps: segment.metadata.bitrateBps,
      containerFormat: segment.metadata.containerFormat,
      codec: segment.metadata.codec,
      codecProfile: segment.metadata.codecProfile,
      metrics: SpeechRecorderSegmentMetrics(
        pcmByteCount: segment.metrics.inputPcmByteCount,
        speechProbability: streamingOptions.includeSpeechProbability
            ? segment.voiceActivity.speechProbability
            : null,
      ),
    );

    for (final callback in session._onSegmentFinishedCallbacks) {
      await callback(segmentData);
    }
  }

  Future<void> _drainStreamingSegmentation(
    SpeechRecorderSession session,
  ) async {
    final subscription = session._streamingSegmentSubscription;
    if (subscription == null) {
      return;
    }

    try {
      await subscription.asFuture<void>();
    } on Object catch (error) {
      debugPrint('Speech recorder streaming drained with error: $error');
    } finally {
      await subscription.cancel();
      if (identical(session._streamingSegmentSubscription, subscription)) {
        session._streamingSegmentSubscription = null;
      }
    }
  }

  Future<void> _cancelStreamingSegmentation(
    SpeechRecorderSession session,
  ) async {
    final subscription = session._streamingSegmentSubscription;
    if (subscription == null) {
      return;
    }
    session._streamingSegmentSubscription = null;
    await subscription.cancel();
  }

  String _defaultSegmentsOutputDirectory(String sessionPath) {
    final directory = _pathDirectory(sessionPath);
    if (directory.isNotEmpty) {
      return directory;
    }
    return Directory.current.path;
  }

  String _defaultSegmentRelativePath({
    required String sessionPath,
    required int segmentIndex,
    required String fileExtension,
  }) {
    final normalizedExtension = fileExtension.startsWith('.')
        ? fileExtension.substring(1)
        : fileExtension;
    final baseName = _pathBaseNameWithoutExtension(sessionPath);
    final suffix = segmentIndex.toString().padLeft(3, '0');
    return _joinPath(
      'segments',
      '${baseName}_segment_$suffix.$normalizedExtension',
    );
  }

  Future<void> _ensureOutputParentDirectoryExists(String outputPath) async {
    final directory = _pathDirectory(outputPath);
    if (directory.isEmpty) {
      return;
    }
    await Directory(directory).create(recursive: true);
  }

  String _pathDirectory(String path) {
    final separatorIndex = _lastPathSeparatorIndex(path);
    if (separatorIndex < 0) {
      return '';
    }
    return path.substring(0, separatorIndex);
  }

  String _pathBaseNameWithoutExtension(String path) {
    final baseName = _pathBaseName(path);
    final dotIndex = baseName.lastIndexOf('.');
    if (dotIndex <= 0) {
      return baseName;
    }
    return baseName.substring(0, dotIndex);
  }

  String _pathBaseName(String path) {
    final separatorIndex = _lastPathSeparatorIndex(path);
    if (separatorIndex < 0) {
      return path;
    }
    return path.substring(separatorIndex + 1);
  }

  int _lastPathSeparatorIndex(String path) {
    final unixSeparator = path.lastIndexOf('/');
    final windowsSeparator = path.lastIndexOf(r'\');
    return unixSeparator > windowsSeparator ? unixSeparator : windowsSeparator;
  }

  String _joinPath(String left, String right) {
    if (left.isEmpty) {
      return right;
    }
    if (left.endsWith('/') || left.endsWith(r'\')) {
      return '$left$right';
    }
    return '$left${Platform.pathSeparator}$right';
  }
}
