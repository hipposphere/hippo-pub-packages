import 'dart:async';
import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:cross_file/cross_file.dart';
import 'package:ffi/ffi.dart';
import 'package:jni/jni.dart';
import 'package:jni_flutter/jni_flutter.dart';
import 'package:path/path.dart' as path;

import '../encoding/aac_encoder.dart';
import '../encoding/native_audio_encoder.dart';
import '../models/audio_metadata.dart';
import '../models/audio_segment_metrics.dart';
import '../models/vad_capture.dart';
import '../models/pause_split_options.dart';
import '../models/pcm16_snippet.dart';
import '../models/voice_activity_metadata.dart';
import '../models/input_device.dart';
import '../splitting/pcm16_stream_pause_splitter.dart';
import '../utils/pcm16_audio_utils.dart';
import '../vad/speech_vad_config.dart';
import 'audio_recorder_config.dart';
import '../generated/recorder/android_jni_bindings.dart' as android_jni;
import '../generated/recorder/ios_audio_recorder_bindings.dart' as ios_bindings;
import '../generated/recorder/macos_audio_recorder_bindings.dart' as macos_bindings;
import '../generated/recorder/windows_audio_recorder_bindings.dart' as windows_bindings;
import 'voice_segment.dart';

part 'native_audio_recorder_platform_builders.dart';
part 'native_audio_recorder_platform_implementations.dart';
part 'errors/native_audio_recorder_exceptions.dart';
part 'implementations/native_audio_recorder_platform_implementation_macos.dart';
part 'implementations/native_audio_recorder_platform_implementation_windows.dart';
part 'implementations/native_audio_recorder_platform_implementation_ios.dart';
part 'implementations/native_audio_recorder_platform_implementation_android.dart';
part 'implementations/native_audio_recorder_platform_ffi.dart';

enum NativeAudioRecorderPlatform { android, macOS, windows, iOS, unsupported }

/// Recorder enhancement capabilities currently implemented by this package.
///
/// These flags represent library/backend support, not theoretical OS support.
final class NativeAudioRecorderCapabilities {
  const NativeAudioRecorderCapabilities({
    required this.supportsNoiseCancellation,
    required this.supportsEchoCancellation,
    required this.supportsVoiceIsolation,
  });

  final bool supportsNoiseCancellation;
  final bool supportsEchoCancellation;
  final bool supportsVoiceIsolation;
}

final class _NativeRecorderRuntimeConfig {
  const _NativeRecorderRuntimeConfig({
    required this.processingFlags,
    required this.iosSessionModeCode,
    required this.iosCategoryOptionsFlags,
    required this.preferredLatencySeconds,
    required this.iosPreferredIoBufferDurationSeconds,
    required this.iosPreferredInputGain,
    required this.fileBitrateBps,
    required this.fileEncoderCode,
    required this.macosProcessingQueueDurationSeconds,
    required this.windowsPreferredPeriodFrames,
    required this.windowsFlags,
    required this.windowsCaptureCategoryCode,
    required this.windowsUseCommunicationsDevice,
    required this.windowsVoiceProcessingModeCode,
  });

  final int processingFlags;
  final int iosSessionModeCode;
  final int iosCategoryOptionsFlags;
  final double preferredLatencySeconds;
  final double iosPreferredIoBufferDurationSeconds;
  final double iosPreferredInputGain;
  final int fileBitrateBps;
  final int fileEncoderCode;
  final double macosProcessingQueueDurationSeconds;
  final int windowsPreferredPeriodFrames;
  final int windowsFlags;
  final int windowsCaptureCategoryCode;
  final int windowsUseCommunicationsDevice;
  final int windowsVoiceProcessingModeCode;
}

enum _RecorderMode { stopped, file, stream }

/// FFI-based microphone recorder backed by platform-native implementations.
///
/// Current native backends:
/// - Android: AudioRecord (JNI)
/// - macOS/iOS: AVFoundation
/// - Windows: miniaudio
final class NativeAudioRecorder {
  /// Uses platform detection to select the default backend.
  NativeAudioRecorder()
    : this._(
        platformImplementation: _resolveNativeAudioRecorderPlatformImplementation(
          platform: _detectNativeAudioRecorderPlatform(),
          platformImplementation: null,
        ),
      );

  /// Uses a custom platform backend.
  NativeAudioRecorder.custom({
    required NativeAudioRecorderPlatformImplementation platformImplementation,
  }) : this._(platformImplementation: platformImplementation);

  NativeAudioRecorder._({required NativeAudioRecorderPlatformImplementation platformImplementation})
    : _platformImplementation = platformImplementation;

  final NativeAudioRecorderPlatformImplementation _platformImplementation;

  _RecorderMode _mode = _RecorderMode.stopped;
  Timer? _streamTimer;
  Timer? _nativeAmplitudeTimer;
  StreamController<Uint8List>? _streamController;
  StreamController<Amplitude>? _amplitudeController;
  int _streamReadSampleCapacity = _defaultReadSampleCapacity;
  Duration? _amplitudeInterval;
  DateTime? _lastAmplitudeEmissionAt;
  double _currentAmplitudeDbfs = -90.0;
  double _maxAmplitudeDbfs = -90.0;
  bool? _currentAmplitudeSpeechSegment;
  String? _activeOutputPath;
  AudioRecorderConfig? _activeRecordingConfig;
  String? _activeTempWavPath;
  Directory? _activeTempDirectory;
  bool _stopping = false;
  bool _nativeAmplitudePollInFlight = false;
  bool _streamDrainInFlight = false;

  static const _defaultReadSampleCapacity = 4096;
  static const _maxReadIterationsPerDrain = 3;

  NativeAudioRecorderPlatform get platform => _platformImplementation.platform;

  bool get isRecording {
    if (_mode == _RecorderMode.stopped) {
      return false;
    }
    try {
      return _platformImplementation.isRecording();
    } on Object {
      return true;
    }
  }

  Future<bool> isAvailable() async {
    return _platformImplementation.isAvailable();
  }

  Future<bool> hasPermission() async {
    _ensureSupportedPlatform();
    return _platformImplementation.hasPermission();
  }

  Future<bool> requestPermission() async {
    _ensureSupportedPlatform();
    return await _platformImplementation.requestPermission();
  }

  /// Returns recorder enhancement capabilities for the current platform.
  ///
  /// These values reflect what this library currently implements.
  Future<NativeAudioRecorderCapabilities> getCapabilities() async {
    return _platformImplementation.capabilities;
  }

  /// Whether this platform can route capture to a specific input-device ID.
  ///
  /// Routing is driven only by `AudioRecorderConfig.inputDeviceId` passed to
  /// `startFileRecording(...)`/`startPcmStream(...)`; no input selection is
  /// stored internally.
  ///
  /// On Apple platforms this is implemented by the native AVCaptureSession
  /// recorder backend using per-start configuration.
  bool get supportsInputSelection {
    return _platformImplementation.supportsInputSelection;
  }

  Future<List<InputDevice>> listInputDevices() async {
    _ensureSupportedPlatform();
    return _platformImplementation.listInputDevices();
  }

  /// Returns the most recent recorder amplitude estimate in dBFS.
  ///
  /// `current` reports the latest value and `max` reports the peak value since
  /// the active capture session started.
  ///
  /// `isSpeechSegment` is populated while VAD capture is active.
  Future<Amplitude> getAmplitude() async {
    if (_mode == _RecorderMode.file) {
      try {
        final amplitude = _platformImplementation.getAmplitude();
        _currentAmplitudeDbfs = amplitude.current;
        if (amplitude.max > _maxAmplitudeDbfs) {
          _maxAmplitudeDbfs = amplitude.max;
        }
        _currentAmplitudeSpeechSegment = amplitude.isSpeechSegment;
      } on Object {
        // Fall back to the latest local estimate if the native read fails.
      }
    }
    return Amplitude(
      current: _currentAmplitudeDbfs,
      max: _maxAmplitudeDbfs,
      isSpeechSegment: _currentAmplitudeSpeechSegment,
    );
  }

  /// Emits recorder amplitude updates while PCM chunks are being drained.
  ///
  /// This follows the old `record` package pattern and emits dBFS values in
  /// `Amplitude.current`, peak dBFS in `Amplitude.max`, and VAD state in
  /// `Amplitude.isSpeechSegment` when VAD capture is active.
  Stream<Amplitude> onAmplitudeChanged(Duration interval) {
    if (interval <= Duration.zero) {
      throw ArgumentError.value(interval, 'interval', 'Must be > Duration.zero');
    }
    _amplitudeInterval = interval;
    _amplitudeController ??= StreamController<Amplitude>.broadcast(
      onListen: _restartNativeAmplitudePollingIfNeeded,
      onCancel: () {
        final controller = _amplitudeController;
        if (controller == null || controller.hasListener) {
          return;
        }
        _nativeAmplitudeTimer?.cancel();
        _nativeAmplitudeTimer = null;
      },
    );
    _restartNativeAmplitudePollingIfNeeded();
    return _amplitudeController!.stream;
  }

  /// Starts file-based recording with native platform recorder backends.
  ///
  /// Output format is controlled by [config.encoding].
  Future<void> startFileRecording({
    required String outputPath,
    AudioRecorderConfig config = const AudioRecorderConfig(),
  }) async {
    _ensureSupportedPlatform();
    _ensureIdle();
    if (outputPath.trim().isEmpty) {
      throw ArgumentError.value(outputPath, 'outputPath', 'Must not be empty');
    }
    config.validate();
    if (!config.encoding.encoder.supportsNativeStartOutput) {
      throw ArgumentError.value(
        config.encoding.encoder,
        'config.encoding.encoder',
        'startFileRecording() supports AudioEncoder.wav, AudioEncoder.pcm16bits, '
            'AudioEncoder.aacLc, AudioEncoder.aacHe, and AudioEncoder.aacEld.',
      );
    }
    if (platform == NativeAudioRecorderPlatform.android && !config.encoding.encoder.isAac) {
      throw ArgumentError.value(
        config.encoding.encoder,
        'config.encoding.encoder',
        'Android file recording supports only AudioEncoder.aacLc, '
            'AudioEncoder.aacHe, and AudioEncoder.aacEld.',
      );
    }

    _resetAmplitudeState();
    _activeOutputPath = outputPath;
    _activeRecordingConfig = config;
    String nativeOutputPath = outputPath;
    final useNativeDirectAacStart = _shouldUseNativeDirectAacStart(
      outputPath: outputPath,
      config: config,
    );

    if (!config.encoding.encoder.supportsNativeStartFile && !useNativeDirectAacStart) {
      final tempDirectory = await Directory.systemTemp.createTemp('speech_utils_recorder_');
      _activeTempDirectory = tempDirectory;
      nativeOutputPath = path.join(tempDirectory.path, 'capture.wav');
      _activeTempWavPath = nativeOutputPath;
    }

    try {
      await _platformImplementation.startFile(outputPath: nativeOutputPath, config: config);
      _mode = _RecorderMode.file;
      _restartNativeAmplitudePollingIfNeeded();
    } on Object {
      await _cleanupTempRecordingDirectory(_activeTempDirectory);
      _clearActiveRecordingOutputTracking();
      rethrow;
    }
  }

  /// Starts live PCM16 streaming capture.
  ///
  /// The returned stream emits little-endian PCM16 chunks until [stop] or
  /// [reset] is called.
  Future<Stream<Uint8List>> startPcmStream({
    AudioRecorderConfig config = const AudioRecorderConfig(),
    Duration pollInterval = const Duration(milliseconds: 20),
    int readSampleCapacity = _defaultReadSampleCapacity,
  }) async {
    _ensureSupportedPlatform();
    _ensureIdle();
    config.validate();

    if (pollInterval <= Duration.zero) {
      throw ArgumentError.value(pollInterval, 'pollInterval', 'Must be > Duration.zero');
    }
    if (readSampleCapacity <= 0) {
      throw ArgumentError.value(readSampleCapacity, 'readSampleCapacity', 'Must be > 0');
    }

    _resetAmplitudeState();
    _activeOutputPath = null;
    _activeRecordingConfig = null;
    _activeTempWavPath = null;
    _activeTempDirectory = null;
    _nativeAmplitudeTimer?.cancel();
    _nativeAmplitudeTimer = null;

    await _platformImplementation.startStream(config: config);

    _mode = _RecorderMode.stream;
    _streamReadSampleCapacity = readSampleCapacity;
    _streamDrainInFlight = false;

    final controller = StreamController<Uint8List>(
      onCancel: () async {
        await stop();
      },
    );
    _streamController = controller;

    _streamTimer = Timer.periodic(pollInterval, (_) {
      _drainNativeStream();
    });
    // Avoid waiting for the first timer tick before attempting to surface data.
    _drainNativeStream();

    return controller.stream;
  }

  /// Starts live VAD capture and returns a session with dedicated streams.
  Future<VadCaptureSession> startVadCapture(VadCaptureRequest request) async {
    _ensureSupportedPlatform();
    _ensureIdle();
    request.validate();

    final splitOptions = request.split;
    final output = request.output;
    final telemetry = request.telemetry;
    final effectiveFullRecordingEncoding = output.fullRecordingEncoding ?? output.segmentEncoding;

    _validateVadCaptureConfig(
      config: request.audio,
      splitOptions: splitOptions,
      segmentEncoding: output.segmentEncoding,
      fullRecordingEncoding: effectiveFullRecordingEncoding,
    );
    await output.outputDirectory.create(recursive: true);

    final resolvedBackend = resolveSpeechVadBackend(options: splitOptions, config: request.vad);

    late final Stream<Uint8List> pcmStream;
    try {
      pcmStream = await startPcmStream(
        config: request.audio,
        pollInterval: request.pollInterval,
        readSampleCapacity: request.readSampleCapacity,
      );
      _currentAmplitudeSpeechSegment = null;
    } on Object {
      resolvedBackend.backend.dispose();
      rethrow;
    }

    final resolvedSegmentAudioEncoder = output.segmentEncoding.encoder.isAac
        ? (output.segmentEncoding.audioEncoder ?? NativeAudioEncoder())
        : null;
    final resolvedFullRecordingAudioEncoder = effectiveFullRecordingEncoding.encoder.isAac
        ? (effectiveFullRecordingEncoding.audioEncoder ?? NativeAudioEncoder())
        : null;
    final segmentBitrateBps = _resolveEncodingBitrateBps(output.segmentEncoding);
    final fullRecordingBitrateBps = _resolveEncodingBitrateBps(effectiveFullRecordingEncoding);

    final segmentsController = StreamController<VoiceSegment>.broadcast();
    final speechStatesController = StreamController<VadSpeechStateSample>.broadcast();
    final levelsController = StreamController<VadLevelSample>.broadcast();
    final frameDecisionsController = StreamController<VadFrameDecision>.broadcast();
    final doneCompleter = Completer<VadCaptureStopResult>();

    unawaited(() async {
      var segmentIndex = 0;
      var analyzedFrameCount = 0;
      var speechFrameCount = 0;
      var speechDetected = false;
      DateTime? lastSpeechFrameAt;
      var currentChunkHasSpeech = false;
      final fullRecordingBytes = output.emitFullRecordingOnStop ? BytesBuilder(copy: false) : null;

      final splitter = Pcm16StreamPauseSplitter(
        options: splitOptions,
        vadBackend: resolvedBackend.backend,
        onFrameClassified: (isSpeech) {
          analyzedFrameCount++;
          if (isSpeech) {
            speechFrameCount++;
            currentChunkHasSpeech = true;
            lastSpeechFrameAt = DateTime.now();
          }
          if (!telemetry.emitFrameDecisions) {
            return;
          }
          frameDecisionsController.add(
            VadFrameDecision(
              at: DateTime.now(),
              isSpeechFrame: isSpeech,
              analyzedFrameCount: analyzedFrameCount,
              speechFrameCount: speechFrameCount,
            ),
          );
        },
      );

      Future<void> emitSnippets(List<Pcm16Snippet> snippets) async {
        for (final snippet in snippets) {
          segmentIndex++;
          try {
            final segment = await _materializeVoiceSegment(
              index: segmentIndex,
              snippet: snippet,
              outputDirectory: output.outputDirectory,
              splitOptions: splitOptions,
              encoding: output.segmentEncoding,
              bitrateBps: segmentBitrateBps,
              audioEncoder: resolvedSegmentAudioEncoder,
              segmentPathBuilder: output.segmentPathBuilder,
            );
            segmentsController.add(segment);
          } on Object catch (error, stackTrace) {
            segmentsController.addError(error, stackTrace);
          }
        }
      }

      try {
        await for (final chunk in pcmStream) {
          fullRecordingBytes?.add(chunk);
          currentChunkHasSpeech = false;
          final snippets = splitter.addChunk(chunk);
          await emitSnippets(snippets);

          final now = DateTime.now();
          if (currentChunkHasSpeech) {
            lastSpeechFrameAt = now;
          }

          final nextSpeechDetected =
              lastSpeechFrameAt != null &&
              now.difference(lastSpeechFrameAt!) <= telemetry.speechHoldDuration;
          _currentAmplitudeSpeechSegment = nextSpeechDetected;
          if (nextSpeechDetected != speechDetected) {
            speechDetected = nextSpeechDetected;
            if (telemetry.emitSpeechState) {
              speechStatesController.add(
                VadSpeechStateSample(at: now, speechDetected: speechDetected),
              );
            }
          }

          if (telemetry.emitLevels) {
            levelsController.add(
              VadLevelSample(
                at: now,
                rms: Pcm16AudioUtils.rms(chunk),
                dbfs: Pcm16AudioUtils.dbfs(chunk),
                hasSpeechFrame: currentChunkHasSpeech,
              ),
            );
          }
        }

        if (request.flushOnStop) {
          await emitSnippets(splitter.flush());
        }

        VadRecordingArtifact? fullRecording;
        if (fullRecordingBytes != null) {
          final fullRecordingPcmBytes = fullRecordingBytes.toBytes();
          if (fullRecordingPcmBytes.isNotEmpty) {
            fullRecording = await _materializeFullRecordingArtifact(
              outputDirectory: output.outputDirectory,
              pcm16leBytes: fullRecordingPcmBytes,
              splitOptions: splitOptions,
              encoding: effectiveFullRecordingEncoding,
              bitrateBps: fullRecordingBitrateBps,
              audioEncoder: resolvedFullRecordingAudioEncoder,
              fileStem: output.fullRecordingFileStem,
            );
          }
        }

        if (speechDetected) {
          _currentAmplitudeSpeechSegment = false;
          if (telemetry.emitSpeechState) {
            speechStatesController.add(
              VadSpeechStateSample(at: DateTime.now(), speechDetected: false),
            );
          }
        }

        if (!doneCompleter.isCompleted) {
          doneCompleter.complete(
            VadCaptureStopResult(
              segmentCount: segmentIndex,
              analyzedFrameCount: analyzedFrameCount,
              speechFrameCount: speechFrameCount,
              fullRecording: fullRecording,
            ),
          );
        }
      } on Object catch (error, stackTrace) {
        segmentsController.addError(error, stackTrace);
        speechStatesController.addError(error, stackTrace);
        levelsController.addError(error, stackTrace);
        frameDecisionsController.addError(error, stackTrace);
        if (!doneCompleter.isCompleted) {
          doneCompleter.completeError(error, stackTrace);
        }
      } finally {
        resolvedBackend.backend.dispose();
        await segmentsController.close();
        await speechStatesController.close();
        await levelsController.close();
        await frameDecisionsController.close();
        _currentAmplitudeSpeechSegment = null;
      }
    }());

    return _VadCaptureSessionImpl(
      backendKind: resolvedBackend.kind,
      backendLabel: resolvedBackend.label,
      segments: segmentsController.stream,
      speechStates: speechStatesController.stream,
      levels: levelsController.stream,
      frameDecisions: frameDecisionsController.stream,
      stopFn: () async {
        if (!doneCompleter.isCompleted) {
          await stop();
        }
        return doneCompleter.future;
      },
      cancelFn: () async {
        if (!doneCompleter.isCompleted) {
          await cancel();
        }
        try {
          await doneCompleter.future;
        } on Object {
          // Ignore completion errors on explicit cancel.
        }
      },
    );
  }

  Future<void> stop() async {
    if (_mode == _RecorderMode.stopped) {
      return;
    }
    if (_stopping) {
      return;
    }
    _stopping = true;

    _streamTimer?.cancel();
    _streamTimer = null;
    _nativeAmplitudeTimer?.cancel();
    _nativeAmplitudeTimer = null;
    final activeOutputPath = _activeOutputPath;
    final activeTempDirectory = _activeTempDirectory;

    Object? stopError;
    StackTrace? stopStackTrace;
    try {
      await _platformImplementation.stop();
    } on Object catch (error, stackTrace) {
      stopError = error;
      stopStackTrace = stackTrace;
    }

    Object? finalizeError;
    StackTrace? finalizeStackTrace;
    if (stopError == null) {
      try {
        await _finalizeEncodedFileOutputIfNeeded();
      } on Object catch (error, stackTrace) {
        finalizeError = error;
        finalizeStackTrace = stackTrace;
      }
    }

    _mode = _RecorderMode.stopped;
    _streamReadSampleCapacity = _defaultReadSampleCapacity;
    _lastAmplitudeEmissionAt = null;
    _currentAmplitudeSpeechSegment = null;
    _streamDrainInFlight = false;

    final controller = _streamController;
    _streamController = null;
    if (controller != null && !controller.isClosed) {
      final hasListener = controller.hasListener;
      if (stopError != null && hasListener) {
        controller.addError(stopError, stopStackTrace ?? StackTrace.current);
      }
      final closeFuture = controller.close();
      if (hasListener) {
        await closeFuture;
      } else {
        unawaited(closeFuture);
      }
    }

    if (stopError != null || finalizeError != null) {
      await _deleteOutputFileIfExists(activeOutputPath);
      await _cleanupTempRecordingDirectory(activeTempDirectory);
    }

    _clearActiveRecordingOutputTracking();
    _stopping = false;

    if (stopError != null) {
      Error.throwWithStackTrace(stopError, stopStackTrace ?? StackTrace.current);
    }
    if (finalizeError != null) {
      Error.throwWithStackTrace(finalizeError, finalizeStackTrace ?? StackTrace.current);
    }
  }

  /// Cancels active recording and discards pending file finalization work.
  ///
  /// This is intended as a robust recovery path if normal stop/finalization is
  /// not desired or has failed.
  Future<void> cancel() async {
    await reset();
  }

  /// Force-resets recorder state on Dart and native sides.
  ///
  /// Unlike [stop], this does not finalize encoded outputs.
  Future<void> reset() async {
    _streamTimer?.cancel();
    _streamTimer = null;
    _nativeAmplitudeTimer?.cancel();
    _nativeAmplitudeTimer = null;

    Object? resetError;
    StackTrace? resetStackTrace;
    try {
      await _platformImplementation.reset();
    } on Object catch (error, stackTrace) {
      resetError = error;
      resetStackTrace = stackTrace;
    }

    _mode = _RecorderMode.stopped;
    _stopping = false;
    _streamReadSampleCapacity = _defaultReadSampleCapacity;
    _lastAmplitudeEmissionAt = null;
    _streamDrainInFlight = false;

    final controller = _streamController;
    _streamController = null;
    if (controller != null && !controller.isClosed) {
      final closeFuture = controller.close();
      if (controller.hasListener) {
        await closeFuture;
      } else {
        unawaited(closeFuture);
      }
    }

    await _cleanupTempRecordingDirectory(_activeTempDirectory);
    _clearActiveRecordingOutputTracking();
    _resetAmplitudeState();

    if (resetError != null) {
      Error.throwWithStackTrace(resetError, resetStackTrace ?? StackTrace.current);
    }
  }

  Future<void> dispose() async {
    await reset();
    _nativeAmplitudeTimer?.cancel();
    _nativeAmplitudeTimer = null;
    final amplitudeController = _amplitudeController;
    _amplitudeController = null;
    if (amplitudeController != null && !amplitudeController.isClosed) {
      await amplitudeController.close();
    }
  }

  void _drainNativeStream() {
    if (_streamDrainInFlight) {
      return;
    }
    if (_mode != _RecorderMode.stream) {
      return;
    }
    final controller = _streamController;
    if (controller == null || controller.isClosed) {
      return;
    }

    _streamDrainInFlight = true;
    try {
      for (var i = 0; i < _maxReadIterationsPerDrain; i++) {
        final chunk = _readPcmStreamChunk(maxSamples: _streamReadSampleCapacity);
        if (chunk.isEmpty) {
          break;
        }
        _updateAmplitudeStateFromPcmChunk(chunk);
        controller.add(chunk);
      }
    } on Object catch (error, stackTrace) {
      controller.addError(error, stackTrace);
      unawaited(stop());
    } finally {
      _streamDrainInFlight = false;
    }
  }

  Uint8List _readPcmStreamChunk({required int maxSamples}) {
    return _platformImplementation.readStream(maxSamples: maxSamples);
  }

  void _ensureSupportedPlatform() {
    _platformImplementation.ensureSupported();
  }

  void _ensureIdle() {
    if (_mode != _RecorderMode.stopped) {
      throw NativeAudioRecorderBusyException('Recorder is already running. Call stop() first.');
    }
  }

  bool _shouldUseNativeDirectAacStart({
    required String outputPath,
    required AudioRecorderConfig config,
  }) {
    final supportsDirectNativeAac =
        config.encoding.encoder.isAac &&
        (platform == NativeAudioRecorderPlatform.macOS ||
            platform == NativeAudioRecorderPlatform.iOS ||
            platform == NativeAudioRecorderPlatform.android);
    if (!supportsDirectNativeAac) {
      return false;
    }

    final extension = path.extension(outputPath).toLowerCase();
    if (extension != '.m4a') {
      throw ArgumentError.value(
        outputPath,
        'outputPath',
        'Native AAC recording requires an .m4a output path.',
      );
    }
    return true;
  }

  void _validateVadCaptureConfig({
    required AudioRecorderConfig config,
    required PauseSplitOptions splitOptions,
    required AudioEncodingConfig segmentEncoding,
    required AudioEncodingConfig fullRecordingEncoding,
  }) {
    if (!segmentEncoding.encoder.supportsVadSegmentationOutput) {
      throw ArgumentError.value(
        segmentEncoding.encoder,
        'segmentEncoding.encoder',
        'startVadCapture() supports AudioEncoder.wav, '
            'AudioEncoder.aacLc, AudioEncoder.aacHe, and AudioEncoder.aacEld.',
      );
    }
    if (!fullRecordingEncoding.encoder.supportsVadSegmentationOutput) {
      throw ArgumentError.value(
        fullRecordingEncoding.encoder,
        'fullRecordingEncoding.encoder',
        'startVadCapture() full-recording output supports AudioEncoder.wav, '
            'AudioEncoder.aacLc, AudioEncoder.aacHe, and AudioEncoder.aacEld.',
      );
    }
    if (config.sampleRateHz != splitOptions.sampleRateHz) {
      throw ArgumentError(
        'config.sampleRateHz (${config.sampleRateHz}) must match '
        'splitOptions.sampleRateHz (${splitOptions.sampleRateHz}).',
      );
    }
    if (config.channelCount != splitOptions.channelCount) {
      throw ArgumentError(
        'config.channelCount (${config.channelCount}) must match '
        'splitOptions.channelCount (${splitOptions.channelCount}).',
      );
    }
  }

  Future<VoiceSegment> _materializeVoiceSegment({
    required int index,
    required Pcm16Snippet snippet,
    required Directory outputDirectory,
    required PauseSplitOptions splitOptions,
    required AudioEncodingConfig encoding,
    required int bitrateBps,
    required AacEncoder? audioEncoder,
    required NativeVoiceSegmentPathBuilder? segmentPathBuilder,
  }) async {
    final encoder = encoding.encoder;
    final extension = encoder.defaultFileExtension;
    final relativePath =
        segmentPathBuilder?.call(index, extension) ??
        'segment_${index.toString().padLeft(3, '0')}.$extension';
    final normalizedRelativePath = _normalizeRelativeSegmentPath(relativePath);
    final outputPath = path.join(outputDirectory.path, normalizedRelativePath);

    final outputFile = File(outputPath);
    final parent = outputFile.parent;
    await parent.create(recursive: true);

    switch (encoder) {
      case AudioEncoder.wav:
        await snippet.writeWav(outputPath);
      case AudioEncoder.aacLc:
      case AudioEncoder.aacHe:
      case AudioEncoder.aacEld:
        if (audioEncoder == null) {
          throw NativeAudioRecorderInvalidStateException(
            'AAC encoder is required for AAC segment output.',
          );
        }
        await audioEncoder.encodePcm16BytesToAac(
          pcm16leBytes: snippet.asBytesView(),
          sampleRateHz: splitOptions.sampleRateHz,
          channelCount: splitOptions.channelCount,
          outputPath: outputPath,
          bitrateKbps: _bitrateKbpsFromBps(bitrateBps),
        );
      case AudioEncoder.flac:
      case AudioEncoder.opus:
      case AudioEncoder.pcm16bits:
        throw ArgumentError.value(
          encoder,
          'encoding.encoder',
          'Unsupported encoder for VAD segmentation output.',
        );
    }

    final outputByteCount = await outputFile.length();
    return VoiceSegment(
      index: index,
      file: XFile(outputPath, mimeType: encoder.defaultMimeType),
      fileExtension: extension,
      mimeType: encoder.defaultMimeType,
      metadata: AudioMetadata(
        duration: snippet.duration,
        sampleRateHz: splitOptions.sampleRateHz,
        channelCount: splitOptions.channelCount,
        bitrateBps: _resolvedSegmentBitrateBps(
          encoder: encoder,
          configuredBitrateBps: encoding.bitrateBps,
          sampleRateHz: splitOptions.sampleRateHz,
          channelCount: splitOptions.channelCount,
        ),
        containerFormat: switch (encoder) {
          AudioEncoder.wav => 'wav',
          AudioEncoder.aacLc || AudioEncoder.aacHe || AudioEncoder.aacEld => 'mp4',
          AudioEncoder.flac || AudioEncoder.opus || AudioEncoder.pcm16bits => null,
        },
        codec: switch (encoder) {
          AudioEncoder.wav => 'pcm_s16le',
          AudioEncoder.aacLc || AudioEncoder.aacHe || AudioEncoder.aacEld => 'aac',
          AudioEncoder.flac || AudioEncoder.opus || AudioEncoder.pcm16bits => null,
        },
        codecProfile: switch (encoder) {
          AudioEncoder.aacLc => 'lc',
          AudioEncoder.aacHe => 'he',
          AudioEncoder.aacEld => 'eld',
          AudioEncoder.wav ||
          AudioEncoder.flac ||
          AudioEncoder.opus ||
          AudioEncoder.pcm16bits => null,
        },
      ),
      voiceActivity: VoiceActivityMetadata(
        speechFrameCount: snippet.speechFrameCount,
        analyzedFrameCount: snippet.analyzedFrameCount,
        speechProbability: snippet.speechProbability,
      ),
      metrics: AudioSegmentMetrics(
        inputPcmByteCount: snippet.byteLength,
        outputByteCount: outputByteCount,
      ),
    );
  }

  Future<VadRecordingArtifact> _materializeFullRecordingArtifact({
    required Directory outputDirectory,
    required Uint8List pcm16leBytes,
    required PauseSplitOptions splitOptions,
    required AudioEncodingConfig encoding,
    required int bitrateBps,
    required AacEncoder? audioEncoder,
    required String fileStem,
  }) async {
    final encoder = encoding.encoder;
    final extension = encoder.defaultFileExtension;
    final outputPath = path.join(outputDirectory.path, '$fileStem.$extension');
    final outputFile = File(outputPath);
    await outputFile.parent.create(recursive: true);

    final snippet = Pcm16Snippet(
      sourceBuffer: pcm16leBytes.buffer,
      sourceByteOffset: pcm16leBytes.offsetInBytes,
      startSampleOffset: 0,
      endSampleOffsetExclusive: pcm16leBytes.lengthInBytes ~/ 2,
      sampleRateHz: splitOptions.sampleRateHz,
      channelCount: splitOptions.channelCount,
    );

    switch (encoder) {
      case AudioEncoder.wav:
        await snippet.writeWav(outputPath);
      case AudioEncoder.aacLc:
      case AudioEncoder.aacHe:
      case AudioEncoder.aacEld:
        if (audioEncoder == null) {
          throw NativeAudioRecorderInvalidStateException(
            'AAC encoder is required for AAC full-recording output.',
          );
        }
        await audioEncoder.encodePcm16BytesToAac(
          pcm16leBytes: pcm16leBytes,
          sampleRateHz: splitOptions.sampleRateHz,
          channelCount: splitOptions.channelCount,
          outputPath: outputPath,
          bitrateKbps: _bitrateKbpsFromBps(bitrateBps),
        );
      case AudioEncoder.flac:
      case AudioEncoder.opus:
      case AudioEncoder.pcm16bits:
        throw ArgumentError.value(
          encoder,
          'encoding.encoder',
          'Unsupported encoder for full-recording output.',
        );
    }

    final outputByteCount = await outputFile.length();
    return VadRecordingArtifact(
      file: XFile(outputPath, mimeType: encoder.defaultMimeType),
      fileExtension: extension,
      mimeType: encoder.defaultMimeType,
      metadata: AudioMetadata(
        duration: snippet.duration,
        sampleRateHz: splitOptions.sampleRateHz,
        channelCount: splitOptions.channelCount,
        bitrateBps: _resolvedSegmentBitrateBps(
          encoder: encoder,
          configuredBitrateBps: encoding.bitrateBps,
          sampleRateHz: splitOptions.sampleRateHz,
          channelCount: splitOptions.channelCount,
        ),
        containerFormat: switch (encoder) {
          AudioEncoder.wav => 'wav',
          AudioEncoder.aacLc || AudioEncoder.aacHe || AudioEncoder.aacEld => 'mp4',
          AudioEncoder.flac || AudioEncoder.opus || AudioEncoder.pcm16bits => null,
        },
        codec: switch (encoder) {
          AudioEncoder.wav => 'pcm_s16le',
          AudioEncoder.aacLc || AudioEncoder.aacHe || AudioEncoder.aacEld => 'aac',
          AudioEncoder.flac || AudioEncoder.opus || AudioEncoder.pcm16bits => null,
        },
        codecProfile: switch (encoder) {
          AudioEncoder.aacLc => 'lc',
          AudioEncoder.aacHe => 'he',
          AudioEncoder.aacEld => 'eld',
          AudioEncoder.wav ||
          AudioEncoder.flac ||
          AudioEncoder.opus ||
          AudioEncoder.pcm16bits => null,
        },
      ),
      metrics: AudioSegmentMetrics(
        inputPcmByteCount: pcm16leBytes.lengthInBytes,
        outputByteCount: outputByteCount,
      ),
    );
  }

  String _normalizeRelativeSegmentPath(String inputPath) {
    final trimmed = inputPath.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(inputPath, 'segmentPathBuilder', 'Segment path cannot be empty.');
    }
    if (path.isAbsolute(trimmed)) {
      throw ArgumentError.value(
        inputPath,
        'segmentPathBuilder',
        'Segment path must be relative to outputDirectory.',
      );
    }
    final normalized = path.normalize(trimmed);
    if (normalized == '..' || normalized.startsWith('../') || normalized.startsWith('..\\')) {
      throw ArgumentError.value(
        inputPath,
        'segmentPathBuilder',
        'Segment path cannot escape outputDirectory.',
      );
    }
    return normalized;
  }

  Future<void> _finalizeEncodedFileOutputIfNeeded() async {
    final outputPath = _activeOutputPath;
    final config = _activeRecordingConfig;
    final tempWavPath = _activeTempWavPath;
    final tempDirectory = _activeTempDirectory;

    if (outputPath == null || config == null) {
      await _cleanupTempRecordingDirectory(tempDirectory);
      return;
    }

    try {
      final useNativeDirectAacStart = _shouldUseNativeDirectAacStart(
        outputPath: outputPath,
        config: config,
      );
      if (!config.encoding.encoder.supportsNativeStartFile && !useNativeDirectAacStart) {
        if (tempWavPath == null) {
          throw NativeAudioRecorderInvalidStateException(
            'Missing temporary WAV recording for encoded output.',
          );
        }
        final audioEncoder = config.encoding.audioEncoder ?? NativeAudioEncoder();
        await audioEncoder.encodeAudioFileToAac(
          inputPath: tempWavPath,
          outputPath: outputPath,
          bitrateKbps: _bitrateKbpsFromBps(_resolveEncodingBitrateBps(config.encoding)),
        );
      }
    } finally {
      await _cleanupTempRecordingDirectory(tempDirectory);
    }
  }

  Future<void> _cleanupTempRecordingDirectory(Directory? directory) async {
    if (directory == null) {
      return;
    }
    try {
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    } on Object {
      // Best effort cleanup only.
    }
  }

  Future<void> _deleteOutputFileIfExists(String? outputPath) async {
    if (outputPath == null) {
      return;
    }
    try {
      final outputFile = File(outputPath);
      if (await outputFile.exists()) {
        await outputFile.delete();
      }
    } on Object {
      // Best effort cleanup only.
    }
  }

  void _clearActiveRecordingOutputTracking() {
    _activeOutputPath = null;
    _activeRecordingConfig = null;
    _activeTempWavPath = null;
    _activeTempDirectory = null;
  }

  void _resetAmplitudeState() {
    _currentAmplitudeDbfs = -90.0;
    _maxAmplitudeDbfs = -90.0;
    _currentAmplitudeSpeechSegment = null;
    _lastAmplitudeEmissionAt = null;
    _nativeAmplitudePollInFlight = false;
  }

  void _restartNativeAmplitudePollingIfNeeded() {
    _nativeAmplitudeTimer?.cancel();
    _nativeAmplitudeTimer = null;

    if (_mode == _RecorderMode.stopped) {
      return;
    }

    final interval = _amplitudeInterval;
    final amplitudeController = _amplitudeController;
    if (interval == null ||
        amplitudeController == null ||
        amplitudeController.isClosed ||
        !amplitudeController.hasListener) {
      return;
    }

    _nativeAmplitudeTimer = Timer.periodic(interval, (_) {
      unawaited(_pollNativeAmplitudeAndEmit());
    });
  }

  Future<void> _pollNativeAmplitudeAndEmit() async {
    if (_mode == _RecorderMode.stopped || _nativeAmplitudePollInFlight) {
      return;
    }

    final amplitudeController = _amplitudeController;
    if (amplitudeController == null ||
        amplitudeController.isClosed ||
        !amplitudeController.hasListener) {
      return;
    }

    _nativeAmplitudePollInFlight = true;
    try {
      amplitudeController.add(await getAmplitude());
    } on Object catch (error, stackTrace) {
      amplitudeController.addError(error, stackTrace);
    } finally {
      _nativeAmplitudePollInFlight = false;
    }
  }

  void _updateAmplitudeStateFromPcmChunk(Uint8List pcm16leBytes) {
    if (pcm16leBytes.lengthInBytes < 2) {
      return;
    }

    final dbfs = Pcm16AudioUtils.dbfs(pcm16leBytes, silenceDbfs: Pcm16AudioUtils.minDbfs);
    _currentAmplitudeDbfs = dbfs;
    if (dbfs > _maxAmplitudeDbfs) {
      _maxAmplitudeDbfs = dbfs;
    }

    final interval = _amplitudeInterval;
    final amplitudeController = _amplitudeController;
    if (interval == null ||
        amplitudeController == null ||
        amplitudeController.isClosed ||
        !amplitudeController.hasListener ||
        _mode == _RecorderMode.stopped) {
      return;
    }

    if (_mode == _RecorderMode.stream &&
        _nativeAmplitudeTimer != null &&
        _amplitudeInterval != null) {
      // Stream-based recordings now emit via native polling so we avoid
      // duplicate updates when the timer is already driving emissions.
      return;
    }

    final now = DateTime.now();
    final lastEmission = _lastAmplitudeEmissionAt;
    if (lastEmission != null && now.difference(lastEmission) < interval) {
      return;
    }

    _lastAmplitudeEmissionAt = now;
    amplitudeController.add(
      Amplitude(
        current: _currentAmplitudeDbfs,
        max: _maxAmplitudeDbfs,
        isSpeechSegment: _currentAmplitudeSpeechSegment,
      ),
    );
  }
}

int _resolveEncodingBitrateBps(AudioEncodingConfig encoding) {
  if (encoding.bitrateBps != null && encoding.bitrateBps! > 0) {
    return encoding.bitrateBps!;
  }
  return 64000;
}

int _bitrateKbpsFromBps(int bitrateBps) {
  final kbps = (bitrateBps / 1000).round();
  return kbps < 8 ? 8 : kbps;
}

int? _resolvedSegmentBitrateBps({
  required AudioEncoder encoder,
  required int? configuredBitrateBps,
  required int sampleRateHz,
  required int channelCount,
}) {
  return switch (encoder) {
    AudioEncoder.wav => sampleRateHz * channelCount * 16,
    AudioEncoder.aacLc ||
    AudioEncoder.aacHe ||
    AudioEncoder.aacEld => configuredBitrateBps ?? 64000,
    AudioEncoder.flac || AudioEncoder.opus || AudioEncoder.pcm16bits => null,
  };
}

final class _VadCaptureSessionImpl implements VadCaptureSession {
  _VadCaptureSessionImpl({
    required this.backendKind,
    required this.backendLabel,
    required this.segments,
    required this.speechStates,
    required this.levels,
    required this.frameDecisions,
    required Future<VadCaptureStopResult> Function() stopFn,
    required Future<void> Function() cancelFn,
  }) : _stopFn = stopFn,
       _cancelFn = cancelFn;

  final Future<VadCaptureStopResult> Function() _stopFn;
  final Future<void> Function() _cancelFn;
  Future<VadCaptureStopResult>? _stopFuture;
  Future<void>? _cancelFuture;

  @override
  final ResolvedVadKind backendKind;

  @override
  final String backendLabel;

  @override
  final Stream<VoiceSegment> segments;

  @override
  final Stream<VadSpeechStateSample> speechStates;

  @override
  final Stream<VadLevelSample> levels;

  @override
  final Stream<VadFrameDecision> frameDecisions;

  @override
  Future<VadCaptureStopResult> stop() {
    return _stopFuture ??= _stopFn();
  }

  @override
  Future<void> cancel() {
    return _cancelFuture ??= _cancelFn();
  }
}
