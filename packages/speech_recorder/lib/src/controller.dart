import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:hippo_utils/hippo_utils.dart';
import 'package:cross_file/cross_file.dart';
import 'package:record/record.dart' as record;
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

  final record.AudioRecorder _recorder = record.AudioRecorder();

  record.AudioRecorder get audioRecorder => _recorder;

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
    _isInitializing = true;
    try {
      final options = await optionsBuilder();
      validateSpeechRecorderOptions(options);

      final session = SpeechRecorderSession.create(
        options: options,
        recorder: _recorder,
        isStreaming: options.streaming != null,
      );

      final streamingOptions = options.streaming;
      if (streamingOptions == null) {
        await _recorder.start(options.recordConfig, path: options.path);
      } else {
        final pcm16Stream = await _recorder.startStream(options.recordConfig);
        final shouldCapturePcm16 =
            streamingOptions.encodeFullRecordingOnStop ||
            streamingOptions.emitStopFallbackSegmentIfEmpty;
        if (shouldCapturePcm16) {
          session._enableStreamingPcm16Capture();
        }
        if (streamingOptions.onSegmentFinished case final callback?) {
          session.onSegmentFinished(callback);
        }
        _startStreamingSegmentation(
          session: session,
          pcm16Stream: pcm16Stream,
          streamingOptions: streamingOptions,
        );
      }

      session._setState(SpeechRecorderSessionState.recording);
      _startAmplitudeListening(session, options.amplitudeInterval);
      session.stopwatch.start();
      sessionSubject.add(session);
      _onSessionStarted?.call(session);
      return session;
    } finally {
      _isInitializing = false;
    }
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
    final streamingOptions = session.options.streaming;
    if (streamingOptions == null) {
      session._setRecordingOutputAfterStopping(
        path: path ?? session.options.path,
        fileExtension: session.options.fileExtension,
        mimeType: session.options.mimeType,
      );
    } else {
      await _drainStreamingSegmentation(session);
      final capturedPcm16leBytes = _consumeStreamingCaptureIfEnabled(
        session: session,
        streamingOptions: streamingOptions,
      );
      if (streamingOptions.emitStopFallbackSegmentIfEmpty) {
        await _emitStopFallbackSegmentIfEmpty(
          session: session,
          streamingOptions: streamingOptions,
          pcm16leBytes: capturedPcm16leBytes,
        );
      }
      if (streamingOptions.encodeFullRecordingOnStop) {
        await _encodeStreamingFullRecording(
          session: session,
          streamingOptions: streamingOptions,
          pcm16leBytes: capturedPcm16leBytes,
        );
      }
    }
    session._disposeSpeechProbabilityEstimator();
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
    await _cancelStreamingSegmentation(session);
    session._discardStreamingPcm16Capture();
    session._disposeSpeechProbabilityEstimator();
    await _recorder.cancel();
    _stopAmplitudeListening(session);
    session._setState(SpeechRecorderSessionState.canceled);
    session.stopwatch.stop();
    sessionSubject.add(null);
  }

  Future<List<record.InputDevice>> listInputDevices() async {
    return _recorder.listInputDevices();
  }

  Future<bool> hasPermission() async {
    return _recorder.hasPermission();
  }

  Future<bool> requestPermission() async {
    return _recorder.hasPermission();
  }

  Future<void> dispose() async {
    sessionSubject.value?._disposeSpeechProbabilityEstimator();
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

  void _stopAmplitudeListening(SpeechRecorderSession session) async {
    unawaited(session._amplitudeSubscription?.cancel());
    session._amplitudeSubscription = null;
  }

  void _startStreamingSegmentation({
    required SpeechRecorderSession session,
    required Stream<Uint8List> pcm16Stream,
    required SpeechRecorderStreamingOptions streamingOptions,
  }) {
    final splitOptions = streamingOptions.pauseSplitOptions;
    final vadConfig =
        streamingOptions.vadConfig ??
        session.options.vadConfig ??
        const SpeechVadConfig();
    if (streamingOptions.includeSpeechProbability) {
      try {
        session._enableSpeechProbabilityEstimator(
          splitOptions: splitOptions,
          vadConfig: vadConfig,
        );
      } on Object catch (error) {
        debugPrint(
          'Speech recorder speech probability estimator disabled: $error',
        );
      }
    }
    final encoder = streamingOptions.encoder ?? NativeAacEncoder();
    final shouldCapturePcm16 =
        streamingOptions.encodeFullRecordingOnStop ||
        streamingOptions.emitStopFallbackSegmentIfEmpty;
    final splitInputStream = shouldCapturePcm16
        ? pcm16Stream.map((bytes) {
            session._captureStreamingPcm16Chunk(bytes);
            return bytes;
          })
        : pcm16Stream;

    session._streamingSegmentSubscription =
        SpeechUtils.splitPcm16StreamOnSilence(
              pcm16leStream: splitInputStream,
              options: splitOptions,
              vadConfig: vadConfig,
            )
            .asyncMap((snippet) async {
              await _handleStreamingSegment(
                session: session,
                splitOptions: splitOptions,
                streamingOptions: streamingOptions,
                snippet: snippet,
                encoder: encoder,
              );
            })
            .listen(
              (_) {},
              onError: (Object error, StackTrace stackTrace) {
                debugPrint('Speech recorder streaming failed: $error');
              },
            );
  }

  Future<void> _handleStreamingSegment({
    required SpeechRecorderSession session,
    required PauseSplitOptions splitOptions,
    required SpeechRecorderStreamingOptions streamingOptions,
    required Pcm16Snippet snippet,
    required AacEncoder encoder,
  }) async {
    final splitDetectedStopwatch = Stopwatch()..start();
    final segmentIndex = session._nextSegmentIndex();
    final pcm16leBytes = snippet.asBytesView();
    final outputPath =
        streamingOptions.segmentPathBuilder?.call(
          segmentIndex,
          streamingOptions.fileExtension,
        ) ??
        _defaultSegmentPath(
          sessionPath: session.options.path,
          segmentIndex: segmentIndex,
          fileExtension: streamingOptions.fileExtension,
        );

    if (outputPath.trim().isEmpty) {
      throw ArgumentError.value(
        outputPath,
        'outputPath',
        'Segment output path cannot be empty.',
      );
    }

    final encodingStopwatch = Stopwatch()..start();
    await encoder.encodePcm16BytesToAac(
      pcm16leBytes: pcm16leBytes,
      sampleRateHz: splitOptions.sampleRateHz,
      channelCount: splitOptions.channelCount,
      outputPath: outputPath,
      bitrateKbps: streamingOptions.bitrateKbps,
    );
    encodingStopwatch.stop();
    splitDetectedStopwatch.stop();

    final segment = SpeechRecorderSegmentData(
      index: segmentIndex,
      file: XFile(outputPath, mimeType: streamingOptions.mimeType),
      duration: snippet.duration,
      fileExtension: streamingOptions.fileExtension,
      mimeType: streamingOptions.mimeType,
      sampleRateHz: splitOptions.sampleRateHz,
      channelCount: splitOptions.channelCount,
      metrics: SpeechRecorderSegmentMetrics(
        encodingDuration: encodingStopwatch.elapsed,
        splitToCallbackLatency: splitDetectedStopwatch.elapsed,
        pcmByteCount: pcm16leBytes.lengthInBytes,
        speechProbability: streamingOptions.includeSpeechProbability
            ? session._estimateSpeechProbability(
                snippet: snippet,
                splitOptions: splitOptions,
              )
            : null,
      ),
    );

    for (final callback in session._onSegmentFinishedCallbacks) {
      await callback(segment);
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

  Uint8List _consumeStreamingCaptureIfEnabled({
    required SpeechRecorderSession session,
    required SpeechRecorderStreamingOptions streamingOptions,
  }) {
    final shouldCapturePcm16 =
        streamingOptions.encodeFullRecordingOnStop ||
        streamingOptions.emitStopFallbackSegmentIfEmpty;
    if (!shouldCapturePcm16) {
      session._discardStreamingPcm16Capture();
      return Uint8List(0);
    }
    return session._consumeStreamingPcm16Capture();
  }

  Future<void> _emitStopFallbackSegmentIfEmpty({
    required SpeechRecorderSession session,
    required SpeechRecorderStreamingOptions streamingOptions,
    required Uint8List pcm16leBytes,
  }) async {
    if (session._segmentCount > 0 || pcm16leBytes.isEmpty) {
      return;
    }

    final segmentIndex = session._nextSegmentIndex();
    final outputPath =
        streamingOptions.segmentPathBuilder?.call(
          segmentIndex,
          streamingOptions.fileExtension,
        ) ??
        _defaultSegmentPath(
          sessionPath: session.options.path,
          segmentIndex: segmentIndex,
          fileExtension: streamingOptions.fileExtension,
        );
    if (outputPath.trim().isEmpty) {
      throw ArgumentError.value(
        outputPath,
        'outputPath',
        'Segment output path cannot be empty.',
      );
    }

    final encodingStopwatch = Stopwatch()..start();
    final encoder = streamingOptions.encoder ?? NativeAacEncoder();
    try {
      await encoder.encodePcm16BytesToAac(
        pcm16leBytes: pcm16leBytes,
        sampleRateHz: streamingOptions.pauseSplitOptions.sampleRateHz,
        channelCount: streamingOptions.pauseSplitOptions.channelCount,
        outputPath: outputPath,
        bitrateKbps: streamingOptions.bitrateKbps,
      );
      encodingStopwatch.stop();
    } on Object catch (error) {
      debugPrint('Speech recorder fallback stop segment encode failed: $error');
      return;
    }

    final segment = SpeechRecorderSegmentData(
      index: segmentIndex,
      file: XFile(outputPath, mimeType: streamingOptions.mimeType),
      duration: _pcm16Duration(
        pcm16ByteCount: pcm16leBytes.lengthInBytes,
        sampleRateHz: streamingOptions.pauseSplitOptions.sampleRateHz,
        channelCount: streamingOptions.pauseSplitOptions.channelCount,
      ),
      fileExtension: streamingOptions.fileExtension,
      mimeType: streamingOptions.mimeType,
      sampleRateHz: streamingOptions.pauseSplitOptions.sampleRateHz,
      channelCount: streamingOptions.pauseSplitOptions.channelCount,
      metrics: SpeechRecorderSegmentMetrics(
        encodingDuration: encodingStopwatch.elapsed,
        splitToCallbackLatency: Duration.zero,
        pcmByteCount: pcm16leBytes.lengthInBytes,
        speechProbability: _estimateSpeechProbabilityFromPcm16(
          session: session,
          streamingOptions: streamingOptions,
          pcm16leBytes: pcm16leBytes,
        ),
      ),
    );
    for (final callback in session._onSegmentFinishedCallbacks) {
      await callback(segment);
    }
  }

  Future<void> _encodeStreamingFullRecording({
    required SpeechRecorderSession session,
    required SpeechRecorderStreamingOptions streamingOptions,
    required Uint8List pcm16leBytes,
  }) async {
    if (pcm16leBytes.isEmpty) {
      return;
    }

    final outputPath = _defaultFullRecordingPath(
      sessionPath: session.options.path,
      fileExtension: streamingOptions.fileExtension,
    );
    if (outputPath.trim().isEmpty) {
      throw ArgumentError.value(
        outputPath,
        'outputPath',
        'Full recording output path cannot be empty.',
      );
    }

    final encoder = streamingOptions.encoder ?? NativeAacEncoder();
    try {
      await encoder.encodePcm16BytesToAac(
        pcm16leBytes: pcm16leBytes,
        sampleRateHz: streamingOptions.pauseSplitOptions.sampleRateHz,
        channelCount: streamingOptions.pauseSplitOptions.channelCount,
        outputPath: outputPath,
        bitrateKbps: streamingOptions.bitrateKbps,
      );
      session._setRecordingOutputAfterStopping(
        path: outputPath,
        fileExtension: streamingOptions.fileExtension,
        mimeType: streamingOptions.mimeType,
      );
    } on Object catch (error) {
      debugPrint('Speech recorder full recording encode failed: $error');
    }
  }

  Duration _pcm16Duration({
    required int pcm16ByteCount,
    required int sampleRateHz,
    required int channelCount,
  }) {
    if (sampleRateHz <= 0 || channelCount <= 0 || pcm16ByteCount <= 0) {
      return Duration.zero;
    }
    final sampleCount = pcm16ByteCount ~/ 2;
    final frameCount = sampleCount ~/ channelCount;
    final micros = (frameCount * Duration.microsecondsPerSecond / sampleRateHz)
        .round();
    return Duration(microseconds: micros);
  }

  double? _estimateSpeechProbabilityFromPcm16({
    required SpeechRecorderSession session,
    required SpeechRecorderStreamingOptions streamingOptions,
    required Uint8List pcm16leBytes,
  }) {
    if (!streamingOptions.includeSpeechProbability || pcm16leBytes.isEmpty) {
      return null;
    }
    final snippet = Pcm16Snippet(
      sourceBuffer: pcm16leBytes.buffer,
      sourceByteOffset: pcm16leBytes.offsetInBytes,
      startSampleOffset: 0,
      endSampleOffsetExclusive: pcm16leBytes.lengthInBytes ~/ 2,
      sampleRateHz: streamingOptions.pauseSplitOptions.sampleRateHz,
      channelCount: streamingOptions.pauseSplitOptions.channelCount,
    );
    return session._estimateSpeechProbability(
      snippet: snippet,
      splitOptions: streamingOptions.pauseSplitOptions,
    );
  }

  String _defaultFullRecordingPath({
    required String sessionPath,
    required String fileExtension,
  }) {
    final normalizedExtension = fileExtension.startsWith('.')
        ? fileExtension.substring(1)
        : fileExtension;
    final dotIndex = sessionPath.lastIndexOf('.');
    final basePath = dotIndex > 0
        ? sessionPath.substring(0, dotIndex)
        : sessionPath;
    return '$basePath.$normalizedExtension';
  }

  String _defaultSegmentPath({
    required String sessionPath,
    required int segmentIndex,
    required String fileExtension,
  }) {
    final normalizedExtension = fileExtension.startsWith('.')
        ? fileExtension.substring(1)
        : fileExtension;
    final dotIndex = sessionPath.lastIndexOf('.');
    final basePath = dotIndex > 0
        ? sessionPath.substring(0, dotIndex)
        : sessionPath;
    final suffix = segmentIndex.toString().padLeft(3, '0');
    return '${basePath}_segment_$suffix.$normalizedExtension';
  }
}
