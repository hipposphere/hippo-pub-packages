import 'dart:async';
import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:cross_file/cross_file.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/widgets.dart';
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
import '../generated/recorder/linux_audio_recorder_bindings.dart' as linux_bindings;
import '../generated/recorder/macos_audio_recorder_bindings.dart' as macos_bindings;
import '../generated/recorder/windows_audio_recorder_bindings.dart' as windows_bindings;
import 'voice_segment.dart';

part 'native_audio_recorder_platform_builders.dart';
part 'native_audio_recorder_platform_implementations.dart';
part 'errors/native_audio_recorder_exceptions.dart';
part 'implementations/native_audio_recorder_platform_implementation_macos.dart';
part 'implementations/native_audio_recorder_platform_implementation_windows.dart';
part 'implementations/native_audio_recorder_platform_implementation_linux.dart';
part 'implementations/native_audio_recorder_platform_implementation_ios.dart';
part 'implementations/native_audio_recorder_platform_implementation_android.dart';
part 'implementations/native_audio_recorder_platform_ffi.dart';

enum NativeAudioRecorderPlatform { android, macOS, windows, linux, iOS, unsupported }

enum NativeAudioRecorderContinousRecordingState { disabled, hibernation, error, active }

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
/// - Linux: miniaudio
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

  NativeAudioRecorder._({required this._platformImplementation}) {
    _appLifecycleListener = _createAppLifecycleListenerIfAvailable();
  }

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
  AudioRecorderConfig _continousRecordingConfig = const AudioRecorderConfig();
  bool _continousRecordingEnabled = false;
  bool _continousRecordingNativeEnabled = false;
  Duration? _continousRecordingDuration;
  Timer? _continousRecordingWarmTimer;
  Object? _continousRecordingError;
  AppLifecycleListener? _appLifecycleListener;
  Future<void>? _appDetachCleanupFuture;
  bool _stopping = false;
  bool _nativeAmplitudePollInFlight = false;
  bool _streamDrainInFlight = false;

  static const _defaultReadSampleCapacity = 4096;
  static const _maxReadIterationsPerDrain = 3;
  static const _miniaudioStartRetryDelays = <Duration>[
    Duration(milliseconds: 75),
    Duration(milliseconds: 150),
  ];
  static const _macosContinousStartRetryDelays = <Duration>[
    Duration(milliseconds: 50),
    Duration(milliseconds: 125),
  ];
  static const _miniaudioTransientStartErrorNeedles = <String>[
    'resource unavailable',
    'device or resource busy',
    'already in use',
    'device unavailable',
    'temporarily unavailable',
  ];
  static const _macosTransientContinuousStartErrorNeedles = <String>[
    'no audio capture device is available',
    'no macos audio capture device is available',
    'selected macos input device is not available',
  ];

  NativeAudioRecorderPlatform get platform => _platformImplementation.platform;

  NativeAudioRecorderContinousRecordingState get continousRecordingState {
    if (_continousRecordingError != null) {
      return NativeAudioRecorderContinousRecordingState.error;
    }
    if (!_continousRecordingEnabled) {
      return NativeAudioRecorderContinousRecordingState.disabled;
    }
    if (_mode != _RecorderMode.stopped || _continousRecordingNativeEnabled) {
      return NativeAudioRecorderContinousRecordingState.active;
    }
    return NativeAudioRecorderContinousRecordingState.hibernation;
  }

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
  /// Routing is driven by `AudioRecorderConfig.inputDeviceId` passed to
  /// `startFileRecording(...)`/`startPcmStream(...)`, or by the warm-capture
  /// device remembered through `setContinousRecording(...)`.
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

  /// Enables or disables background capture warm-up between recordings.
  ///
  /// Windows keeps the native capture device running while idle so voice
  /// processing has already settled when a file or stream session starts.
  ///
  /// `config` can be used to preconfigure the warm capture format before the
  /// first recording starts. `inputDeviceId` overrides the remembered warm
  /// capture device without requiring the full config to be rebuilt.
  ///
  /// When `duration` is set, idle warm capture automatically hibernates after
  /// that amount of time. After a later recording finishes, warm capture is
  /// reactivated for the same duration.
  Future<void> setContinousRecording(
    bool enabled, {
    AudioRecorderConfig? config,
    String? inputDeviceId,
    Duration? duration,
  }) async {
    _ensureSupportedPlatform();
    final previousEnabled = _continousRecordingEnabled;
    final previousConfig = _continousRecordingConfig;
    final previousNativeEnabled = _continousRecordingNativeEnabled;
    final previousDuration = _continousRecordingDuration;
    final resolvedConfig = _resolveUpdatedContinousRecordingConfig(
      config: config,
      inputDeviceId: inputDeviceId,
    );
    final resolvedDuration = _normalizeContinousRecordingDuration(duration);
    resolvedConfig.validate();
    _cancelContinousRecordingWarmTimer();
    _continousRecordingEnabled = enabled;
    _continousRecordingConfig = resolvedConfig;
    _continousRecordingDuration = enabled ? resolvedDuration : null;
    _continousRecordingError = null;
    try {
      await _setPlatformContinousRecording(enabled: enabled, config: resolvedConfig);
      _continousRecordingNativeEnabled = enabled && _supportsNativeContinousRecordingWarmCapture;
      _scheduleContinousRecordingWarmTimerIfNeeded();
    } on Object catch (error) {
      _continousRecordingEnabled = previousEnabled;
      _continousRecordingConfig = previousConfig;
      _continousRecordingNativeEnabled = previousNativeEnabled;
      _continousRecordingDuration = previousDuration;
      _continousRecordingError = error;
      _scheduleContinousRecordingWarmTimerIfNeeded();
      rethrow;
    }
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
    final effectiveConfig = _resolveConfiguredStartConfig(config);
    effectiveConfig.validate();
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
    _validateAacEncoderAvailabilityForCurrentPlatform(
      encoding: effectiveConfig.encoding,
      parameterName: 'config.encoding.audioEncoder',
      context: 'AAC file recording',
    );

    _resetAmplitudeState();
    _activeOutputPath = outputPath;
    _activeRecordingConfig = effectiveConfig;
    String nativeOutputPath = outputPath;
    final useNativeDirectAacStart = _shouldUseNativeDirectAacStart(
      outputPath: outputPath,
      config: effectiveConfig,
    );

    if (!effectiveConfig.encoding.encoder.supportsNativeStartFile && !useNativeDirectAacStart) {
      final tempDirectory = await Directory.systemTemp.createTemp('speech_utils_recorder_');
      _activeTempDirectory = tempDirectory;
      nativeOutputPath = path.join(tempDirectory.path, 'capture.wav');
      _activeTempWavPath = nativeOutputPath;
    }

    try {
      await _runPlatformStartWithRetry(
        () => _platformImplementation.startFile(
          outputPath: nativeOutputPath,
          config: effectiveConfig,
        ),
      );
      _continousRecordingConfig = effectiveConfig;
      _mode = _RecorderMode.file;
      _cancelContinousRecordingWarmTimer();
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
    final effectiveConfig = _resolveConfiguredStartConfig(config);
    effectiveConfig.validate();

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

    await _runPlatformStartWithRetry(
      () => _platformImplementation.startStream(config: effectiveConfig),
    );

    _continousRecordingConfig = effectiveConfig;
    _mode = _RecorderMode.stream;
    _streamReadSampleCapacity = readSampleCapacity;
    _streamDrainInFlight = false;
    _cancelContinousRecordingWarmTimer();

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

    if (stopError == null) {
      await _resumeContinousRecordingWarmCaptureIfNeeded();
    }

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
    await _resumeContinousRecordingWarmCaptureIfNeeded(forceStart: true);
  }

  /// Disables warm capture and releases native recorder resources for app exit.
  ///
  /// This is intended for desktop updater flows where the app process must
  /// fully release microphone/WASAPI resources before the updater waits for
  /// process shutdown. Active recordings are stopped normally before the final
  /// native reset.
  Future<void> prepareForAppExit() async {
    _ensureSupportedPlatform();

    Object? firstError;
    StackTrace? firstStackTrace;

    void rememberError(Object error, StackTrace stackTrace) {
      firstError ??= error;
      firstStackTrace ??= stackTrace;
    }

    final releaseConfig = _resolveContinousRecordingConfig();
    final shouldDisableNativeContinousCapture =
        _continousRecordingEnabled ||
        _continousRecordingNativeEnabled ||
        _mode != _RecorderMode.stopped;
    _cancelContinousRecordingWarmTimer();
    _continousRecordingEnabled = false;
    _continousRecordingNativeEnabled = false;
    _continousRecordingDuration = null;
    _continousRecordingError = null;

    if (shouldDisableNativeContinousCapture) {
      try {
        await _platformImplementation.setContinousRecording(false, config: releaseConfig);
      } on Object catch (error, stackTrace) {
        rememberError(error, stackTrace);
      }
    }

    if (_mode != _RecorderMode.stopped) {
      try {
        await stop();
      } on Object catch (error, stackTrace) {
        rememberError(error, stackTrace);
      }
    }

    try {
      await _cleanupForAppDetach();
    } on Object catch (error, stackTrace) {
      rememberError(error, stackTrace);
    }

    if (firstError != null) {
      Error.throwWithStackTrace(firstError!, firstStackTrace ?? StackTrace.current);
    }
  }

  Future<void> dispose() async {
    _appLifecycleListener?.dispose();
    _appLifecycleListener = null;
    _cancelContinousRecordingWarmTimer();
    _continousRecordingEnabled = false;
    _continousRecordingNativeEnabled = false;
    _continousRecordingDuration = null;
    _continousRecordingError = null;
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

  Future<void> _runPlatformStartWithRetry(FutureOr<void> Function() startOperation) async {
    if (platform != NativeAudioRecorderPlatform.windows &&
        platform != NativeAudioRecorderPlatform.linux) {
      await startOperation();
      return;
    }

    for (var attempt = 0; ; attempt++) {
      try {
        await startOperation();
        return;
      } on AudioRecorderException catch (error, stackTrace) {
        if (!_isRetryableMiniaudioStartError(error) ||
            attempt >= _miniaudioStartRetryDelays.length) {
          Error.throwWithStackTrace(error, stackTrace);
        }
      }

      try {
        await _platformImplementation.reset();
      } on Object {
        // Preserve the original startup failure when cleanup itself is noisy.
      }
      await Future<void>.delayed(_miniaudioStartRetryDelays[attempt]);
    }
  }

  Future<void> _setPlatformContinousRecording({
    required bool enabled,
    required AudioRecorderConfig config,
  }) async {
    if (enabled && platform == NativeAudioRecorderPlatform.macOS) {
      await _setMacosPlatformContinousRecordingWithRetry(config: config);
      return;
    }

    if (enabled &&
        (platform == NativeAudioRecorderPlatform.windows ||
            platform == NativeAudioRecorderPlatform.linux)) {
      await _setMiniaudioPlatformContinousRecordingWithRetry(config: config);
      return;
    }

    await _platformImplementation.setContinousRecording(enabled, config: config);
  }

  Future<void> _setMacosPlatformContinousRecordingWithRetry({
    required AudioRecorderConfig config,
  }) async {
    var configToTry = await _resolveMacosDefaultContinousInputConfig(config);
    var retriesRemaining = _macosContinousStartRetryDelays.length;

    while (true) {
      try {
        await _platformImplementation.setContinousRecording(true, config: configToTry);
        _continousRecordingConfig = configToTry;
        return;
      } on AudioRecorderException catch (error) {
        if (!_isRetryableMacosContinousStartError(error)) {
          rethrow;
        }

        final fallbackConfig = await _resolveMacosDefaultContinousInputConfig(configToTry);
        if (fallbackConfig.inputDeviceId != configToTry.inputDeviceId) {
          configToTry = fallbackConfig;
          continue;
        }

        if (retriesRemaining == 0) {
          rethrow;
        }

        await Future<void>.delayed(
          _macosContinousStartRetryDelays[_macosContinousStartRetryDelays.length -
              retriesRemaining],
        );
        retriesRemaining--;
        configToTry = await _resolveMacosDefaultContinousInputConfig(configToTry);
      }
    }
  }

  Future<void> _setMiniaudioPlatformContinousRecordingWithRetry({
    required AudioRecorderConfig config,
  }) async {
    var configToTry = await _resolvePlatformDefaultContinousInputConfig(config);

    for (var attempt = 0; ; attempt++) {
      try {
        await _platformImplementation.setContinousRecording(true, config: configToTry);
        _continousRecordingConfig = configToTry;
        return;
      } on AudioRecorderException catch (error, stackTrace) {
        final fallbackConfig = await _resolvePlatformDefaultContinousInputConfig(configToTry);
        if (fallbackConfig.inputDeviceId != configToTry.inputDeviceId) {
          configToTry = fallbackConfig;
          continue;
        }

        if (!_isRetryableMiniaudioStartError(error) ||
            attempt >= _miniaudioStartRetryDelays.length) {
          Error.throwWithStackTrace(error, stackTrace);
        }
      }

      try {
        await _platformImplementation.reset();
      } on Object {
        // Preserve the original startup failure when cleanup itself is noisy.
      }
      await Future<void>.delayed(_miniaudioStartRetryDelays[attempt]);
      configToTry = await _resolvePlatformDefaultContinousInputConfig(configToTry);
    }
  }

  bool _isRetryableMiniaudioStartError(AudioRecorderException error) {
    final details = error.details?.toLowerCase();
    if (details == null || !details.contains('miniaudio capture device')) {
      return false;
    }

    for (final needle in _miniaudioTransientStartErrorNeedles) {
      if (details.contains(needle)) {
        return true;
      }
    }
    return false;
  }

  bool _isRetryableMacosContinousStartError(AudioRecorderException error) {
    final details = error.details?.toLowerCase();
    if (details == null) {
      return false;
    }

    for (final needle in _macosTransientContinuousStartErrorNeedles) {
      if (details.contains(needle)) {
        return true;
      }
    }
    return false;
  }

  AudioRecorderConfig _resolveContinousRecordingConfig() {
    return _activeRecordingConfig ?? _continousRecordingConfig;
  }

  AudioRecorderConfig _resolveConfiguredStartConfig(AudioRecorderConfig config) {
    if (!_continousRecordingEnabled || config.inputDeviceId != null) {
      return config;
    }

    final warmInputDeviceId = _continousRecordingConfig.inputDeviceId;
    if (warmInputDeviceId == null) {
      return config;
    }

    return _copyAudioRecorderConfig(config, inputDeviceId: warmInputDeviceId);
  }

  AudioRecorderConfig _resolveUpdatedContinousRecordingConfig({
    AudioRecorderConfig? config,
    String? inputDeviceId,
  }) {
    final baseConfig = config ?? _resolveContinousRecordingConfig();
    final resolvedInputDeviceId = inputDeviceId == null
        ? baseConfig.inputDeviceId
        : _normalizeInputDeviceId(inputDeviceId, parameterName: 'inputDeviceId');
    return _copyAudioRecorderConfig(baseConfig, inputDeviceId: resolvedInputDeviceId);
  }

  Future<AudioRecorderConfig> _resolveMacosDefaultContinousInputConfig(
    AudioRecorderConfig config,
  ) async {
    return _resolvePlatformDefaultContinousInputConfig(
      config,
      supportedPlatforms: const <NativeAudioRecorderPlatform>{NativeAudioRecorderPlatform.macOS},
    );
  }

  Future<AudioRecorderConfig> _resolvePlatformDefaultContinousInputConfig(
    AudioRecorderConfig config, {
    Set<NativeAudioRecorderPlatform> supportedPlatforms = const <NativeAudioRecorderPlatform>{
      NativeAudioRecorderPlatform.macOS,
      NativeAudioRecorderPlatform.windows,
      NativeAudioRecorderPlatform.linux,
    },
  }) async {
    if (!supportedPlatforms.contains(platform) || config.inputDeviceId != null) {
      return config;
    }

    List<InputDevice> devices;
    try {
      devices = await listInputDevices();
    } on Object {
      return config;
    }
    if (devices.isEmpty) {
      return config;
    }

    InputDevice? defaultDevice;
    for (final device in devices) {
      if (device.isDefault) {
        defaultDevice = device;
        break;
      }
    }

    final resolvedDevice = defaultDevice ?? devices.first;
    return _copyAudioRecorderConfig(config, inputDeviceId: resolvedDevice.id);
  }

  Duration? _normalizeContinousRecordingDuration(Duration? duration) {
    if (duration == null) {
      return null;
    }
    if (duration <= Duration.zero) {
      throw ArgumentError.value(duration, 'duration', 'Must be > Duration.zero');
    }
    return duration;
  }

  AudioRecorderConfig _copyAudioRecorderConfig(
    AudioRecorderConfig config, {
    String? inputDeviceId,
  }) {
    return AudioRecorderConfig(
      sampleRateHz: config.sampleRateHz,
      channelCount: config.channelCount,
      framesPerChunk: config.framesPerChunk,
      inputDeviceId: inputDeviceId,
      processing: config.processing,
      iosConfig: config.iosConfig,
      macosConfig: config.macosConfig,
      windowsConfig: config.windowsConfig,
      encoding: config.encoding,
    );
  }

  String? _normalizeInputDeviceId(String? inputDeviceId, {required String parameterName}) {
    final trimmed = inputDeviceId?.trim();
    if (trimmed != null && trimmed.isEmpty) {
      throw ArgumentError.value(inputDeviceId, parameterName, 'Must not be blank');
    }
    return trimmed;
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
    _validateAacEncoderAvailabilityForCurrentPlatform(
      encoding: segmentEncoding,
      parameterName: 'segmentEncoding.audioEncoder',
      context: 'AAC VAD segment output',
    );
    _validateAacEncoderAvailabilityForCurrentPlatform(
      encoding: fullRecordingEncoding,
      parameterName: 'fullRecordingEncoding.audioEncoder',
      context: 'AAC VAD full-recording output',
    );
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

  void _validateAacEncoderAvailabilityForCurrentPlatform({
    required AudioEncodingConfig encoding,
    required String parameterName,
    required String context,
  }) {
    if (!encoding.encoder.isAac || encoding.audioEncoder != null) {
      return;
    }
    if (platform == NativeAudioRecorderPlatform.macOS ||
        platform == NativeAudioRecorderPlatform.windows ||
        platform == NativeAudioRecorderPlatform.linux ||
        platform == NativeAudioRecorderPlatform.iOS ||
        platform == NativeAudioRecorderPlatform.android) {
      return;
    }
    throw ArgumentError.value(
      encoding.audioEncoder,
      parameterName,
      '$context requires AudioEncodingConfig.audioEncoder on this platform because '
      'NativeAudioEncoder does not currently provide a native AAC backend.',
    );
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

  bool get _supportsNativeContinousRecordingWarmCapture {
    return platform == NativeAudioRecorderPlatform.macOS ||
        platform == NativeAudioRecorderPlatform.windows ||
        platform == NativeAudioRecorderPlatform.linux;
  }

  AppLifecycleListener? _createAppLifecycleListenerIfAvailable() {
    if (platform != NativeAudioRecorderPlatform.windows &&
        platform != NativeAudioRecorderPlatform.linux) {
      return null;
    }
    try {
      return AppLifecycleListener(
        onDetach: _handleAppDetached,
        onExitRequested: _handleAppExitRequested,
      );
    } on Object {
      return null;
    }
  }

  void _handleAppDetached() {
    unawaited(_ensureAppDetachCleanup());
  }

  Future<AppExitResponse> _handleAppExitRequested() async {
    await _ensureAppDetachCleanup();
    return AppExitResponse.exit;
  }

  Future<void> _ensureAppDetachCleanup() {
    final existingCleanup = _appDetachCleanupFuture;
    if (existingCleanup != null) {
      return existingCleanup;
    }

    final cleanupFuture = _cleanupForAppDetach();
    _appDetachCleanupFuture = cleanupFuture;
    return cleanupFuture.whenComplete(() {
      if (identical(_appDetachCleanupFuture, cleanupFuture)) {
        _appDetachCleanupFuture = null;
      }
    });
  }

  Future<void> _cleanupForAppDetach() async {
    _cancelContinousRecordingWarmTimer();
    _continousRecordingNativeEnabled = false;
    _nativeAmplitudeTimer?.cancel();
    _nativeAmplitudeTimer = null;
    _streamTimer?.cancel();
    _streamTimer = null;

    try {
      await _platformImplementation.reset();
    } on Object {
      // Best effort shutdown only.
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
  }

  void _cancelContinousRecordingWarmTimer() {
    _continousRecordingWarmTimer?.cancel();
    _continousRecordingWarmTimer = null;
  }

  void _scheduleContinousRecordingWarmTimerIfNeeded() {
    _cancelContinousRecordingWarmTimer();

    final duration = _continousRecordingDuration;
    if (!_continousRecordingEnabled ||
        !_continousRecordingNativeEnabled ||
        !_supportsNativeContinousRecordingWarmCapture ||
        _mode != _RecorderMode.stopped ||
        duration == null) {
      return;
    }

    _continousRecordingWarmTimer = Timer(duration, () {
      unawaited(_hibernateContinousRecordingWarmCaptureIfNeeded());
    });
  }

  Future<void> _hibernateContinousRecordingWarmCaptureIfNeeded() async {
    _cancelContinousRecordingWarmTimer();
    if (!_continousRecordingEnabled ||
        !_continousRecordingNativeEnabled ||
        !_supportsNativeContinousRecordingWarmCapture ||
        _mode != _RecorderMode.stopped) {
      return;
    }

    try {
      await _setPlatformContinousRecording(
        enabled: false,
        config: _resolveContinousRecordingConfig(),
      );
      _continousRecordingNativeEnabled = false;
      _continousRecordingError = null;
    } on Object catch (error) {
      _continousRecordingError = error;
    }
  }

  Future<void> _resumeContinousRecordingWarmCaptureIfNeeded({bool forceStart = false}) async {
    _cancelContinousRecordingWarmTimer();
    if (!_continousRecordingEnabled ||
        !_supportsNativeContinousRecordingWarmCapture ||
        _mode != _RecorderMode.stopped) {
      return;
    }

    if (_continousRecordingNativeEnabled && !forceStart) {
      _continousRecordingError = null;
      _scheduleContinousRecordingWarmTimerIfNeeded();
      return;
    }

    try {
      await _setPlatformContinousRecording(
        enabled: true,
        config: _resolveContinousRecordingConfig(),
      );
      _continousRecordingNativeEnabled = true;
      _continousRecordingError = null;
      _scheduleContinousRecordingWarmTimerIfNeeded();
    } on Object catch (error) {
      _continousRecordingError = error;
    }
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
    required this._stopFn,
    required this._cancelFn,
  });

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
