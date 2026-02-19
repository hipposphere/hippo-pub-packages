import 'dart:async';
import 'dart:io';
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
    await _ensureOutputParentDirectoryExists(outputPath);
    await encoder.encodePcm16BytesToAac(
      pcm16leBytes: pcm16leBytes,
      sampleRateHz: splitOptions.sampleRateHz,
      channelCount: splitOptions.channelCount,
      outputPath: outputPath,
      bitrateKbps: streamingOptions.bitrateKbps,
    );
    encodingStopwatch.stop();
    splitDetectedStopwatch.stop();
    final metadata = await _tryReadSegmentMetadata(
      session: session,
      inputPath: outputPath,
    );

    final segment = SpeechRecorderSegmentData(
      index: segmentIndex,
      file: XFile(outputPath, mimeType: streamingOptions.mimeType),
      duration: metadata?.duration ?? snippet.duration,
      fileExtension: streamingOptions.fileExtension,
      mimeType: streamingOptions.mimeType,
      sampleRateHz: metadata?.sampleRateHz ?? splitOptions.sampleRateHz,
      channelCount: metadata?.channelCount ?? splitOptions.channelCount,
      bitrateBps: metadata?.bitrateBps,
      containerFormat: metadata?.containerFormat,
      codec: metadata?.codec,
      codecProfile: metadata?.codecProfile,
      metrics: SpeechRecorderSegmentMetrics(
        encodingDuration: encodingStopwatch.elapsed,
        splitToCallbackLatency: splitDetectedStopwatch.elapsed,
        pcmByteCount: pcm16leBytes.lengthInBytes,
        speechProbability: _resolveSegmentSpeechProbability(
          includeSpeechProbability: streamingOptions.includeSpeechProbability,
          speechFrameCount: snippet.speechFrameCount,
          analyzedFrameCount: snippet.analyzedFrameCount,
        ),
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
      await _ensureOutputParentDirectoryExists(outputPath);
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
    final metadata = await _tryReadSegmentMetadata(
      session: session,
      inputPath: outputPath,
    );

    final segment = SpeechRecorderSegmentData(
      index: segmentIndex,
      file: XFile(outputPath, mimeType: streamingOptions.mimeType),
      duration:
          metadata?.duration ??
          _pcm16Duration(
            pcm16ByteCount: pcm16leBytes.lengthInBytes,
            sampleRateHz: streamingOptions.pauseSplitOptions.sampleRateHz,
            channelCount: streamingOptions.pauseSplitOptions.channelCount,
          ),
      fileExtension: streamingOptions.fileExtension,
      mimeType: streamingOptions.mimeType,
      sampleRateHz:
          metadata?.sampleRateHz ??
          streamingOptions.pauseSplitOptions.sampleRateHz,
      channelCount:
          metadata?.channelCount ??
          streamingOptions.pauseSplitOptions.channelCount,
      bitrateBps: metadata?.bitrateBps,
      containerFormat: metadata?.containerFormat,
      codec: metadata?.codec,
      codecProfile: metadata?.codecProfile,
      metrics: SpeechRecorderSegmentMetrics(
        encodingDuration: encodingStopwatch.elapsed,
        splitToCallbackLatency: Duration.zero,
        pcmByteCount: pcm16leBytes.lengthInBytes,
        speechProbability: _resolveSegmentSpeechProbability(
          includeSpeechProbability: streamingOptions.includeSpeechProbability,
          speechFrameCount: null,
          analyzedFrameCount: null,
        ),
      ),
    );
    for (final callback in session._onSegmentFinishedCallbacks) {
      await callback(segment);
    }
  }

  Future<NativeAudioMetadata?> _tryReadSegmentMetadata({
    required SpeechRecorderSession session,
    required String inputPath,
  }) async {
    try {
      return await session._audioMetadataReader.readAudioMetadata(
        inputPath: inputPath,
      );
    } on Object catch (error) {
      debugPrint(
        'Speech recorder segment metadata read failed for $inputPath: $error',
      );
      return null;
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
      await _ensureOutputParentDirectoryExists(outputPath);
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

  double? _resolveSegmentSpeechProbability({
    required bool includeSpeechProbability,
    required int? speechFrameCount,
    required int? analyzedFrameCount,
  }) {
    if (!includeSpeechProbability) {
      return null;
    }
    if (speechFrameCount == null ||
        analyzedFrameCount == null ||
        analyzedFrameCount <= 0) {
      return null;
    }
    return speechFrameCount / analyzedFrameCount;
  }

  String _defaultFullRecordingPath({
    required String sessionPath,
    required String fileExtension,
  }) {
    final normalizedExtension = fileExtension.startsWith('.')
        ? fileExtension.substring(1)
        : fileExtension;
    final directory = _pathDirectory(sessionPath);
    final baseName = _pathBaseNameWithoutExtension(sessionPath);
    final fileName = '$baseName.$normalizedExtension';
    if (directory.isEmpty) {
      return fileName;
    }
    return _joinPath(directory, fileName);
  }

  String _defaultSegmentPath({
    required String sessionPath,
    required int segmentIndex,
    required String fileExtension,
  }) {
    final normalizedExtension = fileExtension.startsWith('.')
        ? fileExtension.substring(1)
        : fileExtension;
    final directory = _pathDirectory(sessionPath);
    final baseName = _pathBaseNameWithoutExtension(sessionPath);
    final segmentsDirectory = directory.isEmpty
        ? 'segments'
        : _joinPath(directory, 'segments');
    final suffix = segmentIndex.toString().padLeft(3, '0');
    return _joinPath(
      segmentsDirectory,
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
