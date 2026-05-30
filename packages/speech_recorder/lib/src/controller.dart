import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hippo_core/hippo_core.dart';
import 'package:speech_utils/speech_utils.dart';

import 'models/options.dart';
import 'models/recorder_data.dart';
import 'models/segment_data.dart';
import 'models/streaming_options.dart';
import 'utils/options_validator.dart';

part 'session.dart';

typedef SpeechRecorderCallback = void Function(SpeechRecorderSession session);

class SpeechRecorderController {
  // VAD stop may include synchronous segment encoding work before stream close.
  static const _streamingSegmentDrainTimeout = Duration(seconds: 15);

  final Future<SpeechRecorderOptions> Function() optionsBuilder;
  final SpeechRecorderCallback? _onSessionStarted;
  final SpeechRecorderCallback? _onSessionFinished;
  final NativeAudioRecorder _recorder;

  SpeechRecorderController({
    required this.optionsBuilder,
    this._onSessionStarted,
    this._onSessionFinished,
    NativeAudioRecorder? audioRecorder,
  }) : _recorder = audioRecorder ?? NativeAudioRecorder();

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
    return _start();
  }

  Future<SpeechRecorderSession> startStreaming(
    SpeechRecorderStreamingOptions streamingOptions,
  ) async {
    return _start(streamingOptions: streamingOptions);
  }

  Future<SpeechRecorderSession> _start({
    SpeechRecorderStreamingOptions? streamingOptions,
  }) async {
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
      if (streamingOptions != null) {
        validateSpeechRecorderStreamingOptions(options, streamingOptions);
      }

      final session = SpeechRecorderSession.create(
        options: options,
        streamingOptions: streamingOptions,
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

    if (session.isStreaming) {
      await session._segmentedCaptureSession?.pause();
    } else {
      await _stopNativeRecorderIfRunning();
      await _drainStreamingSegmentation(session);
    }
    await _stopAmplitudeListening(session);

    session._setState(SpeechRecorderSessionState.paused);
    session.stopwatch.stop();
  }

  Future<void> resume(SpeechRecorderSession session) async {
    if (session.stateSubject.value != SpeechRecorderSessionState.paused) {
      return;
    }

    if (session.isStreaming) {
      await session._segmentedCaptureSession?.resume();
      await _startAmplitudeListening(
        session: session,
        interval: session.options.amplitudeInterval,
      );
    } else {
      await _startSessionCapture(session);
    }

    session._setState(SpeechRecorderSessionState.recording);
    session.stopwatch.start();
  }

  Future<void> splitSegment(SpeechRecorderSession session) async {
    if (!session.isStreaming) {
      throw StateError(
        'Manual segment splitting is only available for streaming sessions.',
      );
    }
    if (session.stateSubject.value == SpeechRecorderSessionState.stopped ||
        session.stateSubject.value == SpeechRecorderSessionState.canceled) {
      throw StateError('Cannot split a stopped streaming session.');
    }
    final segmentedCaptureSession = session._segmentedCaptureSession;
    if (segmentedCaptureSession == null) {
      throw StateError('Streaming capture is not active.');
    }
    await segmentedCaptureSession.split();
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

  /// Stops the active session, disables warm capture, and releases native
  /// recorder resources for app shutdown or desktop updater handoff.
  Future<void> prepareForAppExit() async {
    Object? firstError;
    StackTrace? firstStackTrace;

    void rememberError(Object error, StackTrace stackTrace) {
      firstError ??= error;
      firstStackTrace ??= stackTrace;
    }

    try {
      await _recorder.setContinousRecording(false);
    } on Object {
      // The final recorder exit cleanup below is the authoritative release path.
    }

    final session = sessionSubject.value;
    if (session != null) {
      try {
        await stop(session);
      } on Object catch (error, stackTrace) {
        rememberError(error, stackTrace);
      }
    }

    try {
      await _recorder.prepareForAppExit();
    } on Object catch (error, stackTrace) {
      rememberError(error, stackTrace);
    }

    if (firstError != null) {
      Error.throwWithStackTrace(
        firstError!,
        firstStackTrace ?? StackTrace.current,
      );
    }
  }

  Future<void> _startSessionCapture(SpeechRecorderSession session) async {
    final streamingOptions = session.streamingOptions;
    if (streamingOptions == null) {
      final encoder = session.options.recordConfig.encoding.encoder;
      if (_recorder.platform == NativeAudioRecorderPlatform.android &&
          !encoder.isAac) {
        throw ArgumentError.value(
          encoder,
          'recordConfig.encoding.encoder',
          'Android file recording supports only AudioEncoder.aacLc, '
              'AudioEncoder.aacHe, and AudioEncoder.aacEld.',
        );
      }
      await _ensureOutputParentDirectoryExists(session.options.path);
      await _recorder.startFileRecording(
        outputPath: session.options.path,
        config: session.options.recordConfig,
      );
      await _startAmplitudeListening(
        session: session,
        interval: session.options.amplitudeInterval,
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
    await _startAmplitudeListening(
      session: session,
      interval: session.options.amplitudeInterval,
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
    final recordConfig = session.options.recordConfig;
    final splitOptions = streamingOptions.resolvePauseSplitOptions(
      recordConfig,
    );
    final vadConfig = streamingOptions.vadConfig ?? const SpeechVadConfig();

    final outputDirectory = Directory(
      _defaultSegmentsOutputDirectory(session.options.path),
    );
    final segmentedCapture = await _recorder.startSegmentedCapture(
      SegmentedAudioCaptureRequest(
        split: splitOptions,
        audio: recordConfig,
        vad: vadConfig,
        splitMode: streamingOptions.splitMode,
        flushOnStop: true,
        output: SegmentedAudioCaptureOutputConfig(
          outputDirectory: outputDirectory,
          segmentEncoding: recordConfig.encoding,
          segmentPathBuilder: (segmentIndex, fileExtension) {
            return _defaultSegmentRelativePath(
              sessionPath: session.options.path,
              segmentIndex: segmentIndex,
              fileExtension: fileExtension,
            );
          },
        ),
      ),
    );
    session._segmentedCaptureSession = segmentedCapture;

    session._streamingSegmentSubscription = segmentedCapture.segments
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
    final splitOptions = streamingOptions.resolvePauseSplitOptions(
      session.options.recordConfig,
    );
    final segmentData = SpeechRecorderSegmentData(
      index: segment.index,
      file: segment.file,
      duration: segment.metadata.duration,
      fileExtension: segment.fileExtension,
      mimeType: segment.mimeType,
      sampleRateHz: segment.metadata.sampleRateHz ?? splitOptions.sampleRateHz,
      channelCount: segment.metadata.channelCount ?? splitOptions.channelCount,
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

    session.segmentsSubject.add([
      ...session.segmentsSubject.value,
      segmentData,
    ]);

    for (final callback in session._onSegmentFinishedCallbacks) {
      await callback(segmentData);
    }
  }

  Future<void> _drainStreamingSegmentation(
    SpeechRecorderSession session,
  ) async {
    final segmentedCaptureSession = session._segmentedCaptureSession;
    final subscription = session._streamingSegmentSubscription;
    if (segmentedCaptureSession == null && subscription == null) {
      return;
    }

    try {
      if (segmentedCaptureSession != null) {
        await segmentedCaptureSession.stop().timeout(
          _streamingSegmentDrainTimeout,
        );
      }
      if (subscription != null) {
        await subscription.asFuture<void>().timeout(
          _streamingSegmentDrainTimeout,
        );
      }
    } on Object catch (error) {
      debugPrint('Speech recorder streaming drain failed: $error');
    } finally {
      if (subscription != null) {
        await subscription.cancel();
        if (identical(session._streamingSegmentSubscription, subscription)) {
          session._streamingSegmentSubscription = null;
        }
      }
      if (identical(
        session._segmentedCaptureSession,
        segmentedCaptureSession,
      )) {
        session._segmentedCaptureSession = null;
      }
    }
  }

  Future<void> _cancelStreamingSegmentation(
    SpeechRecorderSession session,
  ) async {
    final segmentedCaptureSession = session._segmentedCaptureSession;
    session._segmentedCaptureSession = null;
    final subscription = session._streamingSegmentSubscription;
    session._streamingSegmentSubscription = null;
    await subscription?.cancel();
    await segmentedCaptureSession?.cancel();
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
