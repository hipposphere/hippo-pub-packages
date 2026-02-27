import 'dart:async';
import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:ffi/ffi.dart';
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
import '../vad/speech_vad_config.dart';
import 'audio_recorder_config.dart';
import '../generated/recorder/ios_audio_recorder_bindings.dart' as ios_bindings;
import '../generated/recorder/macos_audio_recorder_bindings.dart' as macos_bindings;
import '../generated/recorder/windows_audio_recorder_bindings.dart' as windows_bindings;
import 'voice_segment.dart';

enum NativeAudioRecorderPlatform { macOS, windows, iOS, unsupported }

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
    required this.appleSessionModeCode,
    required this.appleCategoryOptionsFlags,
    required this.preferredLatencySeconds,
    required this.applePreferredIoBufferDurationSeconds,
    required this.applePreferredInputGain,
    required this.appleFileBitrateBps,
    required this.appleFileEncoderCode,
    required this.windowsPreferredPeriodFrames,
    required this.windowsFlags,
    required this.windowsCaptureCategoryCode,
    required this.windowsUseCommunicationsDevice,
    required this.windowsVoiceProcessingModeCode,
  });

  final int processingFlags;
  final int appleSessionModeCode;
  final int appleCategoryOptionsFlags;
  final double preferredLatencySeconds;
  final double applePreferredIoBufferDurationSeconds;
  final double applePreferredInputGain;
  final int appleFileBitrateBps;
  final int appleFileEncoderCode;
  final int windowsPreferredPeriodFrames;
  final int windowsFlags;
  final int windowsCaptureCategoryCode;
  final int windowsUseCommunicationsDevice;
  final int windowsVoiceProcessingModeCode;
}

typedef NativeAudioRecorderAvailabilityFn = bool Function();
typedef NativeAudioRecorderPermissionFn = bool Function();
typedef NativeAudioRecorderRequestPermissionFn = bool Function();
typedef NativeAudioRecorderListInputDevicesFn = List<InputDevice> Function();
typedef NativeAudioRecorderStartFileFn =
    void Function({
      required String outputPath,
      required int sampleRateHz,
      required int channelCount,
      required String? inputDeviceId,
    });
typedef NativeAudioRecorderStartPcmStreamFn =
    void Function({
      required int sampleRateHz,
      required int channelCount,
      required int framesPerChunk,
      required String? inputDeviceId,
    });
typedef NativeAudioRecorderReadPcmStreamFn = Uint8List Function({required int maxSamples});
typedef NativeAudioRecorderStopFn = void Function();
typedef NativeAudioRecorderResetFn = void Function();
typedef NativeAudioRecorderIsRecordingFn = bool Function();
typedef NativeAudioRecorderGetAmplitudeFn = Amplitude Function();

enum _RecorderMode { stopped, file, stream }

/// FFI-based microphone recorder backed by platform-native implementations.
///
/// Current native backends:
/// - macOS/iOS: AVFoundation
/// - Windows: miniaudio
final class NativeAudioRecorder {
  NativeAudioRecorder({
    NativeAudioRecorderPlatform? platform,
    NativeAudioRecorderAvailabilityFn? availabilityFn,
    NativeAudioRecorderPermissionFn? hasPermissionFn,
    NativeAudioRecorderRequestPermissionFn? requestPermissionFn,
    NativeAudioRecorderListInputDevicesFn? listInputDevicesFn,
    NativeAudioRecorderStartFileFn? startFileFn,
    NativeAudioRecorderStartPcmStreamFn? startPcmStreamFn,
    NativeAudioRecorderReadPcmStreamFn? readPcmStreamFn,
    NativeAudioRecorderStopFn? stopFn,
    NativeAudioRecorderResetFn? resetFn,
    NativeAudioRecorderIsRecordingFn? isRecordingFn,
    NativeAudioRecorderGetAmplitudeFn? getAmplitudeFn,
  }) : this._(
         platform: platform ?? _detectNativeAudioRecorderPlatform(),
         availabilityFn: availabilityFn,
         hasPermissionFn: hasPermissionFn,
         requestPermissionFn: requestPermissionFn,
         listInputDevicesFn: listInputDevicesFn,
         startFileFn: startFileFn,
         startPcmStreamFn: startPcmStreamFn,
         readPcmStreamFn: readPcmStreamFn,
         stopFn: stopFn,
         resetFn: resetFn,
         isRecordingFn: isRecordingFn,
         getAmplitudeFn: getAmplitudeFn,
       );

  NativeAudioRecorder._({
    required NativeAudioRecorderPlatform platform,
    NativeAudioRecorderAvailabilityFn? availabilityFn,
    NativeAudioRecorderPermissionFn? hasPermissionFn,
    NativeAudioRecorderRequestPermissionFn? requestPermissionFn,
    NativeAudioRecorderListInputDevicesFn? listInputDevicesFn,
    NativeAudioRecorderStartFileFn? startFileFn,
    NativeAudioRecorderStartPcmStreamFn? startPcmStreamFn,
    NativeAudioRecorderReadPcmStreamFn? readPcmStreamFn,
    NativeAudioRecorderStopFn? stopFn,
    NativeAudioRecorderResetFn? resetFn,
    NativeAudioRecorderIsRecordingFn? isRecordingFn,
    NativeAudioRecorderGetAmplitudeFn? getAmplitudeFn,
  }) : _platform = platform,
       _availabilityFn = availabilityFn ?? _resolveAvailabilityFn(platform),
       _hasPermissionFn = hasPermissionFn ?? _resolveHasPermissionFn(platform),
       _requestPermissionFn = requestPermissionFn ?? _resolveRequestPermissionFn(platform),
       _listInputDevicesFn = listInputDevicesFn ?? _resolveListInputDevicesFn(platform),
       _startFileFn = startFileFn,
       _startPcmStreamFn = startPcmStreamFn,
       _readPcmStreamFn = readPcmStreamFn ?? _resolveReadPcmStreamFn(platform),
       _stopFn = stopFn ?? _resolveStopFn(platform),
       _resetFn = resetFn ?? _resolveResetFn(platform),
       _isRecordingFn = isRecordingFn ?? _resolveIsRecordingFn(platform),
       _getAmplitudeFn = getAmplitudeFn ?? _resolveGetAmplitudeFn(platform);

  final NativeAudioRecorderPlatform _platform;
  final NativeAudioRecorderAvailabilityFn _availabilityFn;
  final NativeAudioRecorderPermissionFn _hasPermissionFn;
  final NativeAudioRecorderRequestPermissionFn _requestPermissionFn;
  final NativeAudioRecorderListInputDevicesFn _listInputDevicesFn;
  final NativeAudioRecorderStartFileFn? _startFileFn;
  final NativeAudioRecorderStartPcmStreamFn? _startPcmStreamFn;
  final NativeAudioRecorderReadPcmStreamFn _readPcmStreamFn;
  final NativeAudioRecorderStopFn _stopFn;
  final NativeAudioRecorderResetFn _resetFn;
  final NativeAudioRecorderIsRecordingFn _isRecordingFn;
  final NativeAudioRecorderGetAmplitudeFn _getAmplitudeFn;

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
  String? _activeOutputPath;
  AudioRecorderConfig? _activeRecordingConfig;
  String? _activeTempWavPath;
  Directory? _activeTempDirectory;
  bool _stopping = false;
  bool _nativeAmplitudePollInFlight = false;

  static const _defaultReadSampleCapacity = 4096;

  NativeAudioRecorderPlatform get platform => _platform;

  bool get isRecording {
    if (_mode == _RecorderMode.stopped) {
      return false;
    }
    try {
      return _isRecordingFn();
    } on Object {
      return true;
    }
  }

  Future<bool> isAvailable() async {
    if (_platform == NativeAudioRecorderPlatform.unsupported) {
      return false;
    }
    return _availabilityFn();
  }

  Future<bool> hasPermission() async {
    _ensureSupportedPlatform();
    return _hasPermissionFn();
  }

  Future<bool> requestPermission() async {
    _ensureSupportedPlatform();
    return _requestPermissionFn();
  }

  /// Returns recorder enhancement capabilities for the current platform.
  ///
  /// These values reflect what this library currently implements.
  Future<NativeAudioRecorderCapabilities> getCapabilities() async {
    return switch (_platform) {
      NativeAudioRecorderPlatform.macOS ||
      NativeAudioRecorderPlatform.iOS => const NativeAudioRecorderCapabilities(
        supportsNoiseCancellation: true,
        supportsEchoCancellation: true,
        supportsVoiceIsolation: true,
      ),
      NativeAudioRecorderPlatform.windows => const NativeAudioRecorderCapabilities(
        supportsNoiseCancellation: true,
        supportsEchoCancellation: false,
        supportsVoiceIsolation: true,
      ),
      NativeAudioRecorderPlatform.unsupported => const NativeAudioRecorderCapabilities(
        supportsNoiseCancellation: false,
        supportsEchoCancellation: false,
        supportsVoiceIsolation: false,
      ),
    };
  }

  /// Whether this platform can route capture to a specific input-device ID.
  ///
  /// Routing is driven only by `AudioRecorderConfig.inputDeviceId` passed to
  /// `startFileRecording(...)`/`startPcmStream(...)`; no input selection is
  /// stored internally.
  ///
  /// On Apple platforms this is implemented by the native AVAudioEngine
  /// recorder backend using per-start configuration.
  bool get supportsInputSelection {
    return _platform == NativeAudioRecorderPlatform.macOS ||
        _platform == NativeAudioRecorderPlatform.windows ||
        _platform == NativeAudioRecorderPlatform.iOS;
  }

  Future<List<InputDevice>> listInputDevices() async {
    _ensureSupportedPlatform();
    return _listInputDevicesFn();
  }

  /// Returns the most recent recorder amplitude estimate in dBFS.
  ///
  /// `current` reports the latest value and `max` reports the peak value since
  /// the active capture session started.
  Future<Amplitude> getAmplitude() async {
    if (_mode == _RecorderMode.file) {
      try {
        final amplitude = _getAmplitudeFn();
        _currentAmplitudeDbfs = amplitude.current;
        if (amplitude.max > _maxAmplitudeDbfs) {
          _maxAmplitudeDbfs = amplitude.max;
        }
      } on Object {
        // Fall back to the latest local estimate if the native read fails.
      }
    }
    return Amplitude(current: _currentAmplitudeDbfs, max: _maxAmplitudeDbfs);
  }

  /// Emits recorder amplitude updates while PCM chunks are being drained.
  ///
  /// This follows the old `record` package pattern and emits dBFS values in
  /// `Amplitude.current` and peak dBFS in `Amplitude.max`.
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

    _resetAmplitudeState();
    _activeOutputPath = outputPath;
    _activeRecordingConfig = config;
    String nativeOutputPath = outputPath;
    final useAppleDirectAacStart = _shouldUseNativeAppleDirectAacStart(
      outputPath: outputPath,
      config: config,
    );

    if (!config.encoding.encoder.supportsNativeStartFile && !useAppleDirectAacStart) {
      final tempDirectory = await Directory.systemTemp.createTemp('speech_utils_recorder_');
      _activeTempDirectory = tempDirectory;
      nativeOutputPath = path.join(tempDirectory.path, 'capture.wav');
      _activeTempWavPath = nativeOutputPath;
    }

    try {
      final startFileFn = _startFileFn;
      if (startFileFn != null) {
        startFileFn(
          outputPath: nativeOutputPath,
          sampleRateHz: config.sampleRateHz,
          channelCount: config.channelCount,
          inputDeviceId: config.inputDeviceId,
        );
      } else {
        _startNativeFile(
          outputPath: nativeOutputPath,
          config: config,
          runtimeConfig: _buildNativeRecorderRuntimeConfig(config: config, platform: _platform),
        );
      }
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

    final startPcmStreamFn = _startPcmStreamFn;
    if (startPcmStreamFn != null) {
      startPcmStreamFn(
        sampleRateHz: config.sampleRateHz,
        channelCount: config.channelCount,
        framesPerChunk: config.framesPerChunk,
        inputDeviceId: config.inputDeviceId,
      );
    } else {
      _startNativeStream(
        config: config,
        runtimeConfig: _buildNativeRecorderRuntimeConfig(config: config, platform: _platform),
      );
    }

    _mode = _RecorderMode.stream;
    _streamReadSampleCapacity = readSampleCapacity;

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

          if (telemetry.emitSpeechState) {
            final nextSpeechDetected =
                lastSpeechFrameAt != null &&
                now.difference(lastSpeechFrameAt!) <= telemetry.speechHoldDuration;
            if (nextSpeechDetected != speechDetected) {
              speechDetected = nextSpeechDetected;
              speechStatesController.add(
                VadSpeechStateSample(at: now, speechDetected: speechDetected),
              );
            }
          }

          if (telemetry.emitLevels) {
            levelsController.add(
              VadLevelSample(
                at: now,
                rms: _pcm16Rms(chunk),
                dbfs: _pcm16Dbfs(chunk),
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

        if (speechDetected && telemetry.emitSpeechState) {
          speechStatesController.add(
            VadSpeechStateSample(at: DateTime.now(), speechDetected: false),
          );
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

    Object? stopError;
    StackTrace? stopStackTrace;
    try {
      _stopFn();
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
      _resetFn();
    } on Object catch (error, stackTrace) {
      resetError = error;
      resetStackTrace = stackTrace;
    }

    _mode = _RecorderMode.stopped;
    _stopping = false;
    _streamReadSampleCapacity = _defaultReadSampleCapacity;
    _lastAmplitudeEmissionAt = null;

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
    if (_mode != _RecorderMode.stream) {
      return;
    }
    final controller = _streamController;
    if (controller == null || controller.isClosed) {
      return;
    }

    try {
      for (var i = 0; i < 8; i++) {
        final chunk = _readPcmStreamFn(maxSamples: _streamReadSampleCapacity);
        if (chunk.isEmpty) {
          break;
        }
        _updateAmplitudeStateFromPcmChunk(chunk);
        controller.add(chunk);
      }
    } on Object catch (error, stackTrace) {
      controller.addError(error, stackTrace);
      unawaited(stop());
    }
  }

  void _ensureSupportedPlatform() {
    if (_platform == NativeAudioRecorderPlatform.unsupported) {
      throw UnsupportedError(
        'NativeAudioRecorder is currently supported on macOS, Windows, and iOS.',
      );
    }
  }

  void _ensureIdle() {
    if (_mode != _RecorderMode.stopped) {
      throw StateError('Recorder is already running. Call stop() first.');
    }
  }

  void _startNativeFile({
    required String outputPath,
    required AudioRecorderConfig config,
    required _NativeRecorderRuntimeConfig runtimeConfig,
  }) {
    switch (_platform) {
      case NativeAudioRecorderPlatform.macOS:
        _startMacosAudioRecorderFileViaFfi(
          outputPath: outputPath,
          sampleRateHz: config.sampleRateHz,
          channelCount: config.channelCount,
          inputDeviceId: config.inputDeviceId,
          runtimeConfig: runtimeConfig,
        );
      case NativeAudioRecorderPlatform.windows:
        _startWindowsAudioRecorderFileViaFfi(
          outputPath: outputPath,
          sampleRateHz: config.sampleRateHz,
          channelCount: config.channelCount,
          inputDeviceId: config.inputDeviceId,
          runtimeConfig: runtimeConfig,
        );
      case NativeAudioRecorderPlatform.iOS:
        _startIosAudioRecorderFileViaFfi(
          outputPath: outputPath,
          sampleRateHz: config.sampleRateHz,
          channelCount: config.channelCount,
          inputDeviceId: config.inputDeviceId,
          runtimeConfig: runtimeConfig,
        );
      case NativeAudioRecorderPlatform.unsupported:
        throw UnsupportedError(
          'NativeAudioRecorder is currently supported on macOS, Windows, and iOS.',
        );
    }
  }

  void _startNativeStream({
    required AudioRecorderConfig config,
    required _NativeRecorderRuntimeConfig runtimeConfig,
  }) {
    switch (_platform) {
      case NativeAudioRecorderPlatform.macOS:
        _startMacosAudioRecorderStreamViaFfi(
          sampleRateHz: config.sampleRateHz,
          channelCount: config.channelCount,
          framesPerChunk: config.framesPerChunk,
          inputDeviceId: config.inputDeviceId,
          runtimeConfig: runtimeConfig,
        );
      case NativeAudioRecorderPlatform.windows:
        _startWindowsAudioRecorderStreamViaFfi(
          sampleRateHz: config.sampleRateHz,
          channelCount: config.channelCount,
          framesPerChunk: config.framesPerChunk,
          inputDeviceId: config.inputDeviceId,
          runtimeConfig: runtimeConfig,
        );
      case NativeAudioRecorderPlatform.iOS:
        _startIosAudioRecorderStreamViaFfi(
          sampleRateHz: config.sampleRateHz,
          channelCount: config.channelCount,
          framesPerChunk: config.framesPerChunk,
          inputDeviceId: config.inputDeviceId,
          runtimeConfig: runtimeConfig,
        );
      case NativeAudioRecorderPlatform.unsupported:
        throw UnsupportedError(
          'NativeAudioRecorder is currently supported on macOS, Windows, and iOS.',
        );
    }
  }

  bool _shouldUseNativeAppleDirectAacStart({
    required String outputPath,
    required AudioRecorderConfig config,
  }) {
    final isAppleAac =
        (_platform == NativeAudioRecorderPlatform.macOS ||
            _platform == NativeAudioRecorderPlatform.iOS) &&
        config.encoding.encoder.isAac;
    if (!isAppleAac) {
      return false;
    }

    final extension = path.extension(outputPath).toLowerCase();
    if (extension != '.m4a') {
      throw ArgumentError.value(
        outputPath,
        'outputPath',
        'AAC recording on Apple platforms requires an .m4a output path.',
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
          throw StateError('AAC encoder is required for AAC segment output.');
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
          throw StateError('AAC encoder is required for AAC full-recording output.');
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
      final useAppleDirectAacStart = _shouldUseNativeAppleDirectAacStart(
        outputPath: outputPath,
        config: config,
      );
      if (!config.encoding.encoder.supportsNativeStartFile && !useAppleDirectAacStart) {
        if (tempWavPath == null) {
          throw StateError('Missing temporary WAV recording for encoded output.');
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

  void _clearActiveRecordingOutputTracking() {
    _activeOutputPath = null;
    _activeRecordingConfig = null;
    _activeTempWavPath = null;
    _activeTempDirectory = null;
  }

  void _resetAmplitudeState() {
    _currentAmplitudeDbfs = -90.0;
    _maxAmplitudeDbfs = -90.0;
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

    final dbfs = _pcm16Dbfs(pcm16leBytes);
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
    amplitudeController.add(Amplitude(current: _currentAmplitudeDbfs, max: _maxAmplitudeDbfs));
  }

  double _pcm16Dbfs(Uint8List pcm16leBytes) {
    final sampleCount = pcm16leBytes.lengthInBytes ~/ 2;
    if (sampleCount <= 0) {
      return -90.0;
    }

    final samples = Int16List.view(pcm16leBytes.buffer, pcm16leBytes.offsetInBytes, sampleCount);
    var sumSquares = 0.0;
    for (final sample in samples) {
      final normalized = sample / 32768.0;
      sumSquares += normalized * normalized;
    }
    if (sumSquares <= 0) {
      return -90.0;
    }

    final rms = math.sqrt(sumSquares / sampleCount);
    if (rms <= 0) {
      return -90.0;
    }

    final dbfs = 20.0 * math.log(rms) / math.ln10;
    if (dbfs.isNaN || dbfs.isInfinite) {
      return -90.0;
    }

    return (dbfs.clamp(-90.0, 0.0) as num).toDouble();
  }

  double _pcm16Rms(Uint8List pcm16leBytes) {
    final sampleCount = pcm16leBytes.lengthInBytes ~/ 2;
    if (sampleCount <= 0) {
      return 0.0;
    }

    final samples = Int16List.view(pcm16leBytes.buffer, pcm16leBytes.offsetInBytes, sampleCount);
    var sumSquares = 0.0;
    for (final sample in samples) {
      final normalized = sample / 32768.0;
      sumSquares += normalized * normalized;
    }
    if (sumSquares <= 0) {
      return 0.0;
    }
    return math.sqrt(sumSquares / sampleCount);
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

final class AudioRecorderException implements Exception {
  AudioRecorderException(this.message, {this.errorCode, this.details});

  final String message;
  final int? errorCode;
  final String? details;

  @override
  String toString() {
    final detailsText = <String>[
      message,
      if (errorCode != null) 'errorCode=$errorCode',
      if (details != null && details!.isNotEmpty) 'details=$details',
    ];
    return 'AudioRecorderException: ${detailsText.join(' | ')}';
  }
}

NativeAudioRecorderPlatform _detectNativeAudioRecorderPlatform() {
  if (Platform.isMacOS) {
    return NativeAudioRecorderPlatform.macOS;
  }
  if (Platform.isWindows) {
    return NativeAudioRecorderPlatform.windows;
  }
  if (Platform.isIOS) {
    return NativeAudioRecorderPlatform.iOS;
  }
  return NativeAudioRecorderPlatform.unsupported;
}

NativeAudioRecorderAvailabilityFn _resolveAvailabilityFn(NativeAudioRecorderPlatform platform) {
  return switch (platform) {
    NativeAudioRecorderPlatform.macOS => () => true,
    NativeAudioRecorderPlatform.windows => _isWindowsAudioRecorderAvailableViaFfi,
    NativeAudioRecorderPlatform.iOS => () => true,
    NativeAudioRecorderPlatform.unsupported => () => false,
  };
}

NativeAudioRecorderPermissionFn _resolveHasPermissionFn(NativeAudioRecorderPlatform platform) {
  return switch (platform) {
    NativeAudioRecorderPlatform.macOS => _hasMacosMicrophonePermissionViaFfi,
    NativeAudioRecorderPlatform.windows => _hasWindowsMicrophonePermissionViaFfi,
    NativeAudioRecorderPlatform.iOS => _hasIosMicrophonePermissionViaFfi,
    NativeAudioRecorderPlatform.unsupported => () => false,
  };
}

NativeAudioRecorderRequestPermissionFn _resolveRequestPermissionFn(
  NativeAudioRecorderPlatform platform,
) {
  return switch (platform) {
    NativeAudioRecorderPlatform.macOS => _requestMacosMicrophonePermissionViaFfi,
    NativeAudioRecorderPlatform.windows => _requestWindowsMicrophonePermissionViaFfi,
    NativeAudioRecorderPlatform.iOS => _requestIosMicrophonePermissionViaFfi,
    NativeAudioRecorderPlatform.unsupported => () => false,
  };
}

NativeAudioRecorderListInputDevicesFn _resolveListInputDevicesFn(
  NativeAudioRecorderPlatform platform,
) {
  return switch (platform) {
    NativeAudioRecorderPlatform.macOS => _listMacosAudioRecorderInputDevicesViaFfi,
    NativeAudioRecorderPlatform.windows => _listWindowsAudioRecorderInputDevicesViaFfi,
    NativeAudioRecorderPlatform.iOS => _listIosAudioRecorderInputDevicesViaFfi,
    NativeAudioRecorderPlatform.unsupported => () => const <InputDevice>[],
  };
}

NativeAudioRecorderReadPcmStreamFn _resolveReadPcmStreamFn(NativeAudioRecorderPlatform platform) {
  return switch (platform) {
    NativeAudioRecorderPlatform.macOS => _readMacosAudioRecorderStreamViaFfi,
    NativeAudioRecorderPlatform.windows => _readWindowsAudioRecorderStreamViaFfi,
    NativeAudioRecorderPlatform.iOS => _readIosAudioRecorderStreamViaFfi,
    NativeAudioRecorderPlatform.unsupported => ({required maxSamples}) => throw UnsupportedError(
      'NativeAudioRecorder is currently supported on macOS, Windows, and iOS.',
    ),
  };
}

NativeAudioRecorderStopFn _resolveStopFn(NativeAudioRecorderPlatform platform) {
  return switch (platform) {
    NativeAudioRecorderPlatform.macOS => _stopMacosAudioRecorderViaFfi,
    NativeAudioRecorderPlatform.windows => _stopWindowsAudioRecorderViaFfi,
    NativeAudioRecorderPlatform.iOS => _stopIosAudioRecorderViaFfi,
    NativeAudioRecorderPlatform.unsupported => () => throw UnsupportedError(
      'NativeAudioRecorder is currently supported on macOS, Windows, and iOS.',
    ),
  };
}

NativeAudioRecorderResetFn _resolveResetFn(NativeAudioRecorderPlatform platform) {
  return switch (platform) {
    NativeAudioRecorderPlatform.macOS => _resetMacosAudioRecorderViaFfi,
    NativeAudioRecorderPlatform.windows => _resetWindowsAudioRecorderViaFfi,
    NativeAudioRecorderPlatform.iOS => _resetIosAudioRecorderViaFfi,
    NativeAudioRecorderPlatform.unsupported => () => throw UnsupportedError(
      'NativeAudioRecorder is currently supported on macOS, Windows, and iOS.',
    ),
  };
}

NativeAudioRecorderIsRecordingFn _resolveIsRecordingFn(NativeAudioRecorderPlatform platform) {
  return switch (platform) {
    NativeAudioRecorderPlatform.macOS => _isMacosAudioRecorderRunningViaFfi,
    NativeAudioRecorderPlatform.windows => _isWindowsAudioRecorderRunningViaFfi,
    NativeAudioRecorderPlatform.iOS => _isIosAudioRecorderRunningViaFfi,
    NativeAudioRecorderPlatform.unsupported => () => false,
  };
}

NativeAudioRecorderGetAmplitudeFn _resolveGetAmplitudeFn(NativeAudioRecorderPlatform platform) {
  return switch (platform) {
    NativeAudioRecorderPlatform.macOS => _getMacosAudioRecorderAmplitudeViaFfi,
    NativeAudioRecorderPlatform.windows => _getWindowsAudioRecorderAmplitudeViaFfi,
    NativeAudioRecorderPlatform.iOS => _getIosAudioRecorderAmplitudeViaFfi,
    NativeAudioRecorderPlatform.unsupported => () => const Amplitude(current: -90.0, max: -90.0),
  };
}

typedef _NativeBoolOutFn = int Function(ffi.Pointer<ffi.Int32>, ffi.Pointer<ffi.Char>, int);
typedef _NativeStartFileFn = int Function(ffi.Pointer<ffi.Void>, ffi.Pointer<ffi.Char>, int);
typedef _NativeStartStreamFn = int Function(ffi.Pointer<ffi.Void>, ffi.Pointer<ffi.Char>, int);
typedef _NativeReadStreamFn =
    int Function(ffi.Pointer<ffi.Int16>, int, ffi.Pointer<ffi.Uint32>, ffi.Pointer<ffi.Char>, int);
typedef _NativeStopFn = int Function(ffi.Pointer<ffi.Char>, int);
typedef _NativeListInputDevicesFn =
    int Function(ffi.Pointer<ffi.Char>, int, ffi.Pointer<ffi.Char>, int);
typedef _NativeGetAmplitudeFn =
    int Function(ffi.Pointer<ffi.Double>, ffi.Pointer<ffi.Double>, ffi.Pointer<ffi.Char>, int);

const _recorderErrorBufferBytes = 4096;

final class _NativeRecorderRuntimeConfigFfi extends ffi.Struct {
  @ffi.Int32()
  external int processingFlags;

  @ffi.Int32()
  external int appleSessionModeCode;

  @ffi.Uint32()
  external int appleCategoryOptionsFlags;

  @ffi.Double()
  external double preferredLatencySeconds;

  @ffi.Double()
  external double applePreferredIoBufferDurationSeconds;

  @ffi.Double()
  external double applePreferredInputGain;

  @ffi.Uint32()
  external int appleFileBitrateBps;

  @ffi.Int32()
  external int appleFileEncoderCode;

  @ffi.Uint32()
  external int windowsPreferredPeriodFrames;

  @ffi.Uint32()
  external int windowsFlags;

  @ffi.Int32()
  external int windowsCaptureCategoryCode;

  @ffi.Int32()
  external int windowsUseCommunicationsDevice;

  @ffi.Int32()
  external int windowsVoiceProcessingModeCode;
}

final class _NativeRecorderStartConfigFfi extends ffi.Struct {
  @ffi.Uint32()
  external int sampleRateHz;

  @ffi.Uint32()
  external int channelCount;

  @ffi.Uint32()
  external int framesPerChunk;

  external ffi.Pointer<ffi.Char> outputPathUtf8;

  external ffi.Pointer<ffi.Char> inputDeviceIdUtf8;

  external _NativeRecorderRuntimeConfigFfi runtime;
}

bool _runRecorderBoolCall(_NativeBoolOutFn fn, {required String operation}) {
  final outBoolPtr = calloc<ffi.Int32>();
  final errorPtr = calloc<ffi.Char>(_recorderErrorBufferBytes);
  try {
    final code = fn(outBoolPtr, errorPtr, _recorderErrorBufferBytes);
    _throwRecorderExceptionIfNeeded(code: code, errorPtr: errorPtr, operation: operation);
    return outBoolPtr.value != 0;
  } finally {
    calloc.free(outBoolPtr);
    calloc.free(errorPtr);
  }
}

void _runRecorderStartFile(
  _NativeStartFileFn fn, {
  required String outputPath,
  required int sampleRateHz,
  required int channelCount,
  required String? inputDeviceId,
  required _NativeRecorderRuntimeConfig runtimeConfig,
  required String operation,
}) {
  final outputPathPtr = outputPath.toNativeUtf8(allocator: calloc).cast<ffi.Char>();
  final inputDeviceIdPtr = (inputDeviceId == null || inputDeviceId.trim().isEmpty)
      ? ffi.nullptr
      : inputDeviceId.toNativeUtf8(allocator: calloc).cast<ffi.Char>();
  final startConfigPtr = calloc<_NativeRecorderStartConfigFfi>();
  final errorPtr = calloc<ffi.Char>(_recorderErrorBufferBytes);
  try {
    final startConfig = startConfigPtr.ref;
    startConfig.sampleRateHz = sampleRateHz;
    startConfig.channelCount = channelCount;
    startConfig.framesPerChunk = 0;
    startConfig.outputPathUtf8 = outputPathPtr;
    startConfig.inputDeviceIdUtf8 = inputDeviceIdPtr;
    startConfig.runtime.processingFlags = runtimeConfig.processingFlags;
    startConfig.runtime.appleSessionModeCode = runtimeConfig.appleSessionModeCode;
    startConfig.runtime.appleCategoryOptionsFlags = runtimeConfig.appleCategoryOptionsFlags;
    startConfig.runtime.preferredLatencySeconds = runtimeConfig.preferredLatencySeconds;
    startConfig.runtime.applePreferredIoBufferDurationSeconds =
        runtimeConfig.applePreferredIoBufferDurationSeconds;
    startConfig.runtime.applePreferredInputGain = runtimeConfig.applePreferredInputGain;
    startConfig.runtime.appleFileBitrateBps = runtimeConfig.appleFileBitrateBps;
    startConfig.runtime.appleFileEncoderCode = runtimeConfig.appleFileEncoderCode;
    startConfig.runtime.windowsPreferredPeriodFrames = runtimeConfig.windowsPreferredPeriodFrames;
    startConfig.runtime.windowsFlags = runtimeConfig.windowsFlags;
    startConfig.runtime.windowsCaptureCategoryCode = runtimeConfig.windowsCaptureCategoryCode;
    startConfig.runtime.windowsUseCommunicationsDevice =
        runtimeConfig.windowsUseCommunicationsDevice;
    startConfig.runtime.windowsVoiceProcessingModeCode =
        runtimeConfig.windowsVoiceProcessingModeCode;

    final code = fn(startConfigPtr.cast<ffi.Void>(), errorPtr, _recorderErrorBufferBytes);
    _throwRecorderExceptionIfNeeded(code: code, errorPtr: errorPtr, operation: operation);
  } finally {
    calloc.free(startConfigPtr);
    calloc.free(outputPathPtr);
    if (inputDeviceIdPtr != ffi.nullptr) {
      calloc.free(inputDeviceIdPtr);
    }
    calloc.free(errorPtr);
  }
}

void _runRecorderStartStream(
  _NativeStartStreamFn fn, {
  required int sampleRateHz,
  required int channelCount,
  required int framesPerChunk,
  required String? inputDeviceId,
  required _NativeRecorderRuntimeConfig runtimeConfig,
  required String operation,
}) {
  final inputDeviceIdPtr = (inputDeviceId == null || inputDeviceId.trim().isEmpty)
      ? ffi.nullptr
      : inputDeviceId.toNativeUtf8(allocator: calloc).cast<ffi.Char>();
  final startConfigPtr = calloc<_NativeRecorderStartConfigFfi>();
  final errorPtr = calloc<ffi.Char>(_recorderErrorBufferBytes);
  try {
    final startConfig = startConfigPtr.ref;
    startConfig.sampleRateHz = sampleRateHz;
    startConfig.channelCount = channelCount;
    startConfig.framesPerChunk = framesPerChunk;
    startConfig.outputPathUtf8 = ffi.nullptr;
    startConfig.inputDeviceIdUtf8 = inputDeviceIdPtr;
    startConfig.runtime.processingFlags = runtimeConfig.processingFlags;
    startConfig.runtime.appleSessionModeCode = runtimeConfig.appleSessionModeCode;
    startConfig.runtime.appleCategoryOptionsFlags = runtimeConfig.appleCategoryOptionsFlags;
    startConfig.runtime.preferredLatencySeconds = runtimeConfig.preferredLatencySeconds;
    startConfig.runtime.applePreferredIoBufferDurationSeconds =
        runtimeConfig.applePreferredIoBufferDurationSeconds;
    startConfig.runtime.applePreferredInputGain = runtimeConfig.applePreferredInputGain;
    startConfig.runtime.appleFileBitrateBps = runtimeConfig.appleFileBitrateBps;
    startConfig.runtime.appleFileEncoderCode = runtimeConfig.appleFileEncoderCode;
    startConfig.runtime.windowsPreferredPeriodFrames = runtimeConfig.windowsPreferredPeriodFrames;
    startConfig.runtime.windowsFlags = runtimeConfig.windowsFlags;
    startConfig.runtime.windowsCaptureCategoryCode = runtimeConfig.windowsCaptureCategoryCode;
    startConfig.runtime.windowsUseCommunicationsDevice =
        runtimeConfig.windowsUseCommunicationsDevice;
    startConfig.runtime.windowsVoiceProcessingModeCode =
        runtimeConfig.windowsVoiceProcessingModeCode;

    final code = fn(startConfigPtr.cast<ffi.Void>(), errorPtr, _recorderErrorBufferBytes);
    _throwRecorderExceptionIfNeeded(code: code, errorPtr: errorPtr, operation: operation);
  } finally {
    calloc.free(startConfigPtr);
    if (inputDeviceIdPtr != ffi.nullptr) {
      calloc.free(inputDeviceIdPtr);
    }
    calloc.free(errorPtr);
  }
}

List<InputDevice> _runRecorderListInputDevices(
  _NativeListInputDevicesFn fn, {
  required String operation,
}) {
  const outputCapacity = 64 * 1024;
  final outputPtr = calloc<ffi.Char>(outputCapacity);
  final errorPtr = calloc<ffi.Char>(_recorderErrorBufferBytes);
  try {
    final code = fn(outputPtr, outputCapacity, errorPtr, _recorderErrorBufferBytes);
    _throwRecorderExceptionIfNeeded(code: code, errorPtr: errorPtr, operation: operation);

    final jsonText = outputPtr.cast<Utf8>().toDartString();
    if (jsonText.trim().isEmpty) {
      return const <InputDevice>[];
    }

    final decoded = jsonDecode(jsonText);
    if (decoded is! List) {
      throw const FormatException('Native input-device payload is not a JSON list.');
    }

    final devices = <InputDevice>[];
    for (final item in decoded) {
      if (item is! Map<String, Object?>) {
        continue;
      }
      final device = InputDevice.fromJson(item);
      if (device.id.trim().isEmpty) {
        continue;
      }
      devices.add(device);
    }
    return devices;
  } finally {
    calloc.free(outputPtr);
    calloc.free(errorPtr);
  }
}

Uint8List _runRecorderReadStream(
  _NativeReadStreamFn fn, {
  required int maxSamples,
  required String operation,
}) {
  final outSamplesPtr = calloc<ffi.Int16>(maxSamples);
  final outSamplesWrittenPtr = calloc<ffi.Uint32>();
  final errorPtr = calloc<ffi.Char>(_recorderErrorBufferBytes);

  try {
    final code = fn(
      outSamplesPtr,
      maxSamples,
      outSamplesWrittenPtr,
      errorPtr,
      _recorderErrorBufferBytes,
    );
    _throwRecorderExceptionIfNeeded(code: code, errorPtr: errorPtr, operation: operation);

    final sampleCount = outSamplesWrittenPtr.value;
    if (sampleCount <= 0) {
      return Uint8List(0);
    }

    final bytes = Uint8List(sampleCount * 2);
    final dst = bytes.buffer.asInt16List();
    final src = outSamplesPtr.asTypedList(sampleCount);
    dst.setRange(0, sampleCount, src);
    return bytes;
  } finally {
    calloc.free(outSamplesPtr);
    calloc.free(outSamplesWrittenPtr);
    calloc.free(errorPtr);
  }
}

void _runRecorderStop(_NativeStopFn fn, {required String operation}) {
  final errorPtr = calloc<ffi.Char>(_recorderErrorBufferBytes);
  try {
    final code = fn(errorPtr, _recorderErrorBufferBytes);
    _throwRecorderExceptionIfNeeded(code: code, errorPtr: errorPtr, operation: operation);
  } finally {
    calloc.free(errorPtr);
  }
}

void _runRecorderReset(_NativeStopFn fn, {required String operation}) {
  final errorPtr = calloc<ffi.Char>(_recorderErrorBufferBytes);
  try {
    final code = fn(errorPtr, _recorderErrorBufferBytes);
    _throwRecorderExceptionIfNeeded(code: code, errorPtr: errorPtr, operation: operation);
  } finally {
    calloc.free(errorPtr);
  }
}

Amplitude _runRecorderGetAmplitude(_NativeGetAmplitudeFn fn, {required String operation}) {
  final outCurrentPtr = calloc<ffi.Double>();
  final outMaxPtr = calloc<ffi.Double>();
  final errorPtr = calloc<ffi.Char>(_recorderErrorBufferBytes);
  try {
    final code = fn(outCurrentPtr, outMaxPtr, errorPtr, _recorderErrorBufferBytes);
    _throwRecorderExceptionIfNeeded(code: code, errorPtr: errorPtr, operation: operation);
    return Amplitude(
      current: _sanitizeDbfs(outCurrentPtr.value),
      max: _sanitizeDbfs(outMaxPtr.value),
    );
  } finally {
    calloc.free(outCurrentPtr);
    calloc.free(outMaxPtr);
    calloc.free(errorPtr);
  }
}

double _sanitizeDbfs(double value) {
  if (value.isNaN || value.isInfinite) {
    return -90.0;
  }
  return (value.clamp(-90.0, 0.0) as num).toDouble();
}

const int _processingFlagNoiseSuppression = 1 << 0;
const int _processingFlagEchoCancellation = 1 << 1;
const int _processingFlagAutomaticGainControl = 1 << 2;
const int _processingFlagHighPassFilter = 1 << 3;
const int _processingFlagPresetVoice = 1 << 4;
const int _processingFlagPresetVoiceIsolation = 1 << 5;
const int _processingFlagPresetRaw = 1 << 6;
const int _processingFlagPresetMusic = 1 << 7;

const int _appleCategoryOptionAllowBluetooth = 1 << 0;
const int _appleCategoryOptionAllowBluetoothA2dp = 1 << 1;
const int _appleCategoryOptionDefaultToSpeaker = 1 << 2;
const int _appleCategoryOptionMixWithOthers = 1 << 3;
const int _appleCategoryOptionDuckOthers = 1 << 4;

const int _appleFileEncoderAacLc = 0;
const int _appleFileEncoderAacHe = 1;
const int _appleFileEncoderAacEld = 2;

const int _windowsFlagExclusiveMode = 1 << 0;
const int _windowsFlagRawCapture = 1 << 1;
const int _windowsVoiceProcessingModeAuto = 0;
const int _windowsVoiceProcessingModeSystem = 1;
const int _windowsVoiceProcessingModeSoftware = 2;
const int _windowsVoiceProcessingModeOff = 3;

_NativeRecorderRuntimeConfig _buildNativeRecorderRuntimeConfig({
  required AudioRecorderConfig config,
  required NativeAudioRecorderPlatform platform,
}) {
  final processing = config.processing;
  final isApplePlatform =
      platform == NativeAudioRecorderPlatform.macOS || platform == NativeAudioRecorderPlatform.iOS;
  final processingPlatform = isApplePlatform
      ? AudioProcessingPlatform.apple
      : AudioProcessingPlatform.windows;
  var processingFlags = _processingPresetFlags(processing.preset);

  if (processing.resolveNoiseSuppressionForPlatform(processingPlatform)) {
    processingFlags |= _processingFlagNoiseSuppression;
  }
  if (processing.resolveEchoCancellationForPlatform(processingPlatform)) {
    processingFlags |= _processingFlagEchoCancellation;
  }
  if (processing.resolveAutomaticGainControlForPlatform(processingPlatform)) {
    processingFlags |= _processingFlagAutomaticGainControl;
  }
  if (processing.resolveHighPassFilterForPlatform(processingPlatform)) {
    processingFlags |= _processingFlagHighPassFilter;
  }

  final apple = config.appleConfig;
  var appleCategoryOptionsFlags = 0;
  if (apple?.allowBluetoothInput ?? false) {
    appleCategoryOptionsFlags |= _appleCategoryOptionAllowBluetooth;
  }
  if (apple?.allowBluetoothA2dp ?? false) {
    appleCategoryOptionsFlags |= _appleCategoryOptionAllowBluetoothA2dp;
  }
  if (apple?.defaultToSpeaker ?? false) {
    appleCategoryOptionsFlags |= _appleCategoryOptionDefaultToSpeaker;
  }
  if (apple?.mixWithOthers ?? false) {
    appleCategoryOptionsFlags |= _appleCategoryOptionMixWithOthers;
  }
  if (apple?.duckOthers ?? false) {
    appleCategoryOptionsFlags |= _appleCategoryOptionDuckOthers;
  }

  final windows = config.windowsConfig;
  var windowsFlags = 0;
  if (windows?.useExclusiveMode ?? false) {
    windowsFlags |= _windowsFlagExclusiveMode;
  }
  if (windows?.useRawCapture ?? false) {
    windowsFlags |= _windowsFlagRawCapture;
  }

  final preferredLatency = processing.preferredLatency;
  final windowsTargetDuration = windows?.targetBufferDuration ?? preferredLatency;
  final windowsPreferredPeriodFrames = windowsTargetDuration == null
      ? 0
      : (((windowsTargetDuration.inMicroseconds * config.sampleRateHz) ~/
                Duration.microsecondsPerSecond)
            .clamp(0, 0x7fffffff));

  final applePreferredIoDuration = apple?.preferredIoBufferDuration ?? preferredLatency;
  final applePreferredInputGain = apple?.preferredInputGain ?? -1.0;
  final appleFileBitrateBps = isApplePlatform && config.encoding.encoder.isAac
      ? _resolveEncodingBitrateBps(config.encoding)
      : 0;
  final appleFileEncoderCode = isApplePlatform
      ? _encodeAppleFileEncoder(config.encoding.encoder)
      : _appleFileEncoderAacLc;

  return _NativeRecorderRuntimeConfig(
    processingFlags: processingFlags,
    appleSessionModeCode: _encodeAppleSessionMode(apple?.sessionMode),
    appleCategoryOptionsFlags: appleCategoryOptionsFlags,
    preferredLatencySeconds: preferredLatency == null
        ? 0.0
        : preferredLatency.inMicroseconds / Duration.microsecondsPerSecond,
    applePreferredIoBufferDurationSeconds: applePreferredIoDuration == null
        ? 0.0
        : applePreferredIoDuration.inMicroseconds / Duration.microsecondsPerSecond,
    applePreferredInputGain: applePreferredInputGain,
    appleFileBitrateBps: appleFileBitrateBps,
    appleFileEncoderCode: appleFileEncoderCode,
    windowsPreferredPeriodFrames: windowsPreferredPeriodFrames,
    windowsFlags: windowsFlags,
    windowsCaptureCategoryCode: _encodeWindowsCaptureCategory(windows?.captureCategory),
    windowsUseCommunicationsDevice: windows?.useCommunicationsDevice == true ? 1 : 0,
    windowsVoiceProcessingModeCode: _encodeWindowsVoiceProcessingMode(windows?.voiceProcessingMode),
  );
}

int _encodeAppleFileEncoder(AudioEncoder encoder) {
  return switch (encoder) {
    AudioEncoder.aacHe => _appleFileEncoderAacHe,
    AudioEncoder.aacEld => _appleFileEncoderAacEld,
    AudioEncoder.aacLc ||
    AudioEncoder.wav ||
    AudioEncoder.flac ||
    AudioEncoder.opus ||
    AudioEncoder.pcm16bits => _appleFileEncoderAacLc,
  };
}

int _processingPresetFlags(AudioCapturePreset preset) {
  return switch (preset) {
    AudioCapturePreset.voice => _processingFlagPresetVoice,
    AudioCapturePreset.voiceIsolation => _processingFlagPresetVoiceIsolation,
    AudioCapturePreset.raw => _processingFlagPresetRaw,
    AudioCapturePreset.music => _processingFlagPresetMusic,
  };
}

int _encodeAppleSessionMode(AppleAudioSessionMode? mode) {
  return switch (mode) {
    null => 0,
    AppleAudioSessionMode.defaultMode => 0,
    AppleAudioSessionMode.voiceChat => 1,
    AppleAudioSessionMode.videoChat => 2,
    AppleAudioSessionMode.measurement => 3,
    AppleAudioSessionMode.gameChat => 4,
    AppleAudioSessionMode.spokenAudio => 5,
  };
}

int _encodeWindowsCaptureCategory(WindowsCaptureCategory? category) {
  return switch (category) {
    null => 2,
    WindowsCaptureCategory.media => 0,
    WindowsCaptureCategory.communications => 1,
    WindowsCaptureCategory.speech => 2,
  };
}

int _encodeWindowsVoiceProcessingMode(WindowsVoiceProcessingMode? mode) {
  return switch (mode) {
    null => _windowsVoiceProcessingModeAuto,
    WindowsVoiceProcessingMode.auto => _windowsVoiceProcessingModeAuto,
    WindowsVoiceProcessingMode.system => _windowsVoiceProcessingModeSystem,
    WindowsVoiceProcessingMode.software => _windowsVoiceProcessingModeSoftware,
    WindowsVoiceProcessingMode.off => _windowsVoiceProcessingModeOff,
  };
}

void _throwRecorderExceptionIfNeeded({
  required int code,
  required ffi.Pointer<ffi.Char> errorPtr,
  required String operation,
}) {
  if (code == 0) {
    return;
  }
  final details = errorPtr.cast<Utf8>().toDartString();
  throw AudioRecorderException(
    '$operation failed',
    errorCode: code,
    details: details.isEmpty ? null : details,
  );
}

bool _hasMacosMicrophonePermissionViaFfi() {
  return _runRecorderBoolCall(
    macos_bindings.speech_utils_macos_audio_recorder_has_permission,
    operation: 'macOS microphone permission check',
  );
}

bool _requestMacosMicrophonePermissionViaFfi() {
  return _runRecorderBoolCall(
    macos_bindings.speech_utils_macos_audio_recorder_request_permission,
    operation: 'macOS microphone permission request',
  );
}

void _startMacosAudioRecorderFileViaFfi({
  required String outputPath,
  required int sampleRateHz,
  required int channelCount,
  required String? inputDeviceId,
  required _NativeRecorderRuntimeConfig runtimeConfig,
}) {
  _runRecorderStartFile(
    macos_bindings.speech_utils_macos_audio_recorder_start_file,
    outputPath: outputPath,
    sampleRateHz: sampleRateHz,
    channelCount: channelCount,
    inputDeviceId: inputDeviceId,
    runtimeConfig: runtimeConfig,
    operation: 'macOS file recording start',
  );
}

void _startMacosAudioRecorderStreamViaFfi({
  required int sampleRateHz,
  required int channelCount,
  required int framesPerChunk,
  required String? inputDeviceId,
  required _NativeRecorderRuntimeConfig runtimeConfig,
}) {
  _runRecorderStartStream(
    macos_bindings.speech_utils_macos_audio_recorder_start_stream,
    sampleRateHz: sampleRateHz,
    channelCount: channelCount,
    framesPerChunk: framesPerChunk,
    inputDeviceId: inputDeviceId,
    runtimeConfig: runtimeConfig,
    operation: 'macOS stream recording start',
  );
}

List<InputDevice> _listMacosAudioRecorderInputDevicesViaFfi() {
  return _runRecorderListInputDevices(
    macos_bindings.speech_utils_macos_audio_recorder_list_input_devices_json,
    operation: 'macOS input device listing',
  );
}

Uint8List _readMacosAudioRecorderStreamViaFfi({required int maxSamples}) {
  return _runRecorderReadStream(
    macos_bindings.speech_utils_macos_audio_recorder_read_stream_pcm16,
    maxSamples: maxSamples,
    operation: 'macOS stream read',
  );
}

void _stopMacosAudioRecorderViaFfi() {
  _runRecorderStop(
    macos_bindings.speech_utils_macos_audio_recorder_stop,
    operation: 'macOS recording stop',
  );
}

void _resetMacosAudioRecorderViaFfi() {
  _runRecorderReset(
    macos_bindings.speech_utils_macos_audio_recorder_reset,
    operation: 'macOS recorder reset',
  );
}

bool _isMacosAudioRecorderRunningViaFfi() {
  return _runRecorderBoolCall(
    macos_bindings.speech_utils_macos_audio_recorder_is_recording,
    operation: 'macOS recorder state read',
  );
}

Amplitude _getMacosAudioRecorderAmplitudeViaFfi() {
  return _runRecorderGetAmplitude(
    macos_bindings.speech_utils_macos_audio_recorder_get_amplitude,
    operation: 'macOS recorder amplitude read',
  );
}

bool _isWindowsAudioRecorderAvailableViaFfi() {
  return true;
}

bool _hasWindowsMicrophonePermissionViaFfi() {
  return _runRecorderBoolCall(
    windows_bindings.speech_utils_windows_audio_recorder_has_permission,
    operation: 'Windows microphone permission check',
  );
}

bool _requestWindowsMicrophonePermissionViaFfi() {
  return _runRecorderBoolCall(
    windows_bindings.speech_utils_windows_audio_recorder_request_permission,
    operation: 'Windows microphone permission request',
  );
}

void _startWindowsAudioRecorderFileViaFfi({
  required String outputPath,
  required int sampleRateHz,
  required int channelCount,
  required String? inputDeviceId,
  required _NativeRecorderRuntimeConfig runtimeConfig,
}) {
  _runRecorderStartFile(
    windows_bindings.speech_utils_windows_audio_recorder_start_file,
    outputPath: outputPath,
    sampleRateHz: sampleRateHz,
    channelCount: channelCount,
    inputDeviceId: inputDeviceId,
    runtimeConfig: runtimeConfig,
    operation: 'Windows file recording start',
  );
}

void _startWindowsAudioRecorderStreamViaFfi({
  required int sampleRateHz,
  required int channelCount,
  required int framesPerChunk,
  required String? inputDeviceId,
  required _NativeRecorderRuntimeConfig runtimeConfig,
}) {
  _runRecorderStartStream(
    windows_bindings.speech_utils_windows_audio_recorder_start_stream,
    sampleRateHz: sampleRateHz,
    channelCount: channelCount,
    framesPerChunk: framesPerChunk,
    inputDeviceId: inputDeviceId,
    runtimeConfig: runtimeConfig,
    operation: 'Windows stream recording start',
  );
}

List<InputDevice> _listWindowsAudioRecorderInputDevicesViaFfi() {
  return _runRecorderListInputDevices(
    windows_bindings.speech_utils_windows_audio_recorder_list_input_devices_json,
    operation: 'Windows input device listing',
  );
}

Uint8List _readWindowsAudioRecorderStreamViaFfi({required int maxSamples}) {
  return _runRecorderReadStream(
    windows_bindings.speech_utils_windows_audio_recorder_read_stream_pcm16,
    maxSamples: maxSamples,
    operation: 'Windows stream read',
  );
}

void _stopWindowsAudioRecorderViaFfi() {
  _runRecorderStop(
    windows_bindings.speech_utils_windows_audio_recorder_stop,
    operation: 'Windows recording stop',
  );
}

void _resetWindowsAudioRecorderViaFfi() {
  _runRecorderReset(
    windows_bindings.speech_utils_windows_audio_recorder_reset,
    operation: 'Windows recorder reset',
  );
}

bool _isWindowsAudioRecorderRunningViaFfi() {
  return _runRecorderBoolCall(
    windows_bindings.speech_utils_windows_audio_recorder_is_recording,
    operation: 'Windows recorder state read',
  );
}

Amplitude _getWindowsAudioRecorderAmplitudeViaFfi() {
  return _runRecorderGetAmplitude(
    windows_bindings.speech_utils_windows_audio_recorder_get_amplitude,
    operation: 'Windows recorder amplitude read',
  );
}

bool _hasIosMicrophonePermissionViaFfi() {
  return _runRecorderBoolCall(
    ios_bindings.speech_utils_ios_audio_recorder_has_permission,
    operation: 'iOS microphone permission check',
  );
}

bool _requestIosMicrophonePermissionViaFfi() {
  return _runRecorderBoolCall(
    ios_bindings.speech_utils_ios_audio_recorder_request_permission,
    operation: 'iOS microphone permission request',
  );
}

void _startIosAudioRecorderFileViaFfi({
  required String outputPath,
  required int sampleRateHz,
  required int channelCount,
  required String? inputDeviceId,
  required _NativeRecorderRuntimeConfig runtimeConfig,
}) {
  _runRecorderStartFile(
    ios_bindings.speech_utils_ios_audio_recorder_start_file,
    outputPath: outputPath,
    sampleRateHz: sampleRateHz,
    channelCount: channelCount,
    inputDeviceId: inputDeviceId,
    runtimeConfig: runtimeConfig,
    operation: 'iOS file recording start',
  );
}

void _startIosAudioRecorderStreamViaFfi({
  required int sampleRateHz,
  required int channelCount,
  required int framesPerChunk,
  required String? inputDeviceId,
  required _NativeRecorderRuntimeConfig runtimeConfig,
}) {
  _runRecorderStartStream(
    ios_bindings.speech_utils_ios_audio_recorder_start_stream,
    sampleRateHz: sampleRateHz,
    channelCount: channelCount,
    framesPerChunk: framesPerChunk,
    inputDeviceId: inputDeviceId,
    runtimeConfig: runtimeConfig,
    operation: 'iOS stream recording start',
  );
}

List<InputDevice> _listIosAudioRecorderInputDevicesViaFfi() {
  return _runRecorderListInputDevices(
    ios_bindings.speech_utils_ios_audio_recorder_list_input_devices_json,
    operation: 'iOS input device listing',
  );
}

Uint8List _readIosAudioRecorderStreamViaFfi({required int maxSamples}) {
  return _runRecorderReadStream(
    ios_bindings.speech_utils_ios_audio_recorder_read_stream_pcm16,
    maxSamples: maxSamples,
    operation: 'iOS stream read',
  );
}

void _stopIosAudioRecorderViaFfi() {
  _runRecorderStop(
    ios_bindings.speech_utils_ios_audio_recorder_stop,
    operation: 'iOS recording stop',
  );
}

void _resetIosAudioRecorderViaFfi() {
  _runRecorderReset(
    ios_bindings.speech_utils_ios_audio_recorder_reset,
    operation: 'iOS recorder reset',
  );
}

bool _isIosAudioRecorderRunningViaFfi() {
  return _runRecorderBoolCall(
    ios_bindings.speech_utils_ios_audio_recorder_is_recording,
    operation: 'iOS recorder state read',
  );
}

Amplitude _getIosAudioRecorderAmplitudeViaFfi() {
  return _runRecorderGetAmplitude(
    ios_bindings.speech_utils_ios_audio_recorder_get_amplitude,
    operation: 'iOS recorder amplitude read',
  );
}
