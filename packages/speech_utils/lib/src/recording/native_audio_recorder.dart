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
import '../encoding/native_aac_encoder.dart';
import '../model/audio_metadata.dart';
import '../model/audio_segment_metrics.dart';
import '../model/pause_split_options.dart';
import '../model/pcm16_snippet.dart';
import '../model/voice_activity_metadata.dart';
import '../models/input_device.dart';
import '../splitting/pcm16_stream_pause_splitter.dart';
import '../vad/speech_vad_config.dart';
import '../vad/vad_backend.dart';
import 'audio_recorder_config.dart';
import 'generated/ios_audio_recorder_bindings.dart' as ios_bindings;
import 'generated/macos_audio_recorder_bindings.dart' as macos_bindings;
import 'generated/windows_audio_recorder_bindings.dart' as windows_bindings;
import 'voice_segment.dart';

enum NativeAudioRecorderPlatform { macOS, windows, iOS, unsupported }

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
typedef NativeAudioRecorderStartStreamFn =
    void Function({
      required int sampleRateHz,
      required int channelCount,
      required int framesPerChunk,
      required String? inputDeviceId,
    });
typedef NativeAudioRecorderReadStreamFn = Uint8List Function({required int maxSamples});
typedef NativeAudioRecorderStopFn = void Function();
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
    NativeAudioRecorderStartStreamFn? startStreamFn,
    NativeAudioRecorderReadStreamFn? readStreamFn,
    NativeAudioRecorderStopFn? stopFn,
    NativeAudioRecorderIsRecordingFn? isRecordingFn,
    NativeAudioRecorderGetAmplitudeFn? getAmplitudeFn,
  }) : this._(
         platform: platform ?? _detectNativeAudioRecorderPlatform(),
         availabilityFn: availabilityFn,
         hasPermissionFn: hasPermissionFn,
         requestPermissionFn: requestPermissionFn,
         listInputDevicesFn: listInputDevicesFn,
         startFileFn: startFileFn,
         startStreamFn: startStreamFn,
         readStreamFn: readStreamFn,
         stopFn: stopFn,
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
    NativeAudioRecorderStartStreamFn? startStreamFn,
    NativeAudioRecorderReadStreamFn? readStreamFn,
    NativeAudioRecorderStopFn? stopFn,
    NativeAudioRecorderIsRecordingFn? isRecordingFn,
    NativeAudioRecorderGetAmplitudeFn? getAmplitudeFn,
  }) : _platform = platform,
       _availabilityFn = availabilityFn ?? _resolveAvailabilityFn(platform),
       _hasPermissionFn = hasPermissionFn ?? _resolveHasPermissionFn(platform),
       _requestPermissionFn = requestPermissionFn ?? _resolveRequestPermissionFn(platform),
       _listInputDevicesFn = listInputDevicesFn ?? _resolveListInputDevicesFn(platform),
       _startFileFn = startFileFn ?? _resolveStartFileFn(platform),
       _startStreamFn = startStreamFn ?? _resolveStartStreamFn(platform),
       _readStreamFn = readStreamFn ?? _resolveReadStreamFn(platform),
       _stopFn = stopFn ?? _resolveStopFn(platform),
       _isRecordingFn = isRecordingFn ?? _resolveIsRecordingFn(platform),
       _getAmplitudeFn = getAmplitudeFn ?? _resolveGetAmplitudeFn(platform);

  final NativeAudioRecorderPlatform _platform;
  final NativeAudioRecorderAvailabilityFn _availabilityFn;
  final NativeAudioRecorderPermissionFn _hasPermissionFn;
  final NativeAudioRecorderRequestPermissionFn _requestPermissionFn;
  final NativeAudioRecorderListInputDevicesFn _listInputDevicesFn;
  final NativeAudioRecorderStartFileFn _startFileFn;
  final NativeAudioRecorderStartStreamFn _startStreamFn;
  final NativeAudioRecorderReadStreamFn _readStreamFn;
  final NativeAudioRecorderStopFn _stopFn;
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

  /// Whether this platform can route capture to a specific input-device ID.
  ///
  /// Routing is driven only by `AudioRecorderConfig.inputDeviceId` passed to
  /// `start(...)`/`startStream(...)`; no input selection is stored internally.
  ///
  /// On Apple platforms this is implemented by the native AVFoundation capture
  /// backend using per-start configuration.
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

  Future<void> start({
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
        'start() supports AudioEncoder.wav, AudioEncoder.pcm16bits, '
            'AudioEncoder.aacLc, AudioEncoder.aacHe, and AudioEncoder.aacEld.',
      );
    }

    _resetAmplitudeState();
    _activeOutputPath = outputPath;
    _activeRecordingConfig = config;
    String nativeOutputPath = outputPath;
    final useMacosDirectAacStart = _shouldUseNativeMacosDirectAacStart(
      outputPath: outputPath,
      config: config,
    );

    if (!config.encoding.encoder.supportsNativeStartFile && !useMacosDirectAacStart) {
      final tempDirectory = await Directory.systemTemp.createTemp('speech_utils_recorder_');
      _activeTempDirectory = tempDirectory;
      nativeOutputPath = path.join(tempDirectory.path, 'capture.wav');
      _activeTempWavPath = nativeOutputPath;
    }

    try {
      _startFileFn(
        outputPath: nativeOutputPath,
        sampleRateHz: config.sampleRateHz,
        channelCount: config.channelCount,
        inputDeviceId: config.inputDeviceId,
      );
      _mode = _RecorderMode.file;
      _restartNativeAmplitudePollingIfNeeded();
    } on Object {
      await _cleanupTempRecordingDirectory(_activeTempDirectory);
      _clearActiveRecordingOutputTracking();
      rethrow;
    }
  }

  Future<Stream<Uint8List>> startStream({
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

    _startStreamFn(
      sampleRateHz: config.sampleRateHz,
      channelCount: config.channelCount,
      framesPerChunk: config.framesPerChunk,
      inputDeviceId: config.inputDeviceId,
    );

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

  Future<Stream<VoiceSegment>> startWithVadSegmentation({
    required Directory outputDirectory,
    required PauseSplitOptions splitOptions,
    AudioRecorderConfig config = const AudioRecorderConfig(),
    SpeechVadConfig vadConfig = const SpeechVadConfig(),
    bool flushOnStop = true,
    NativeVoiceSegmentPathBuilder? segmentPathBuilder,
    Duration pollInterval = const Duration(milliseconds: 20),
    int readSampleCapacity = _defaultReadSampleCapacity,
  }) async {
    _ensureSupportedPlatform();
    _ensureIdle();
    config.validate();
    splitOptions.validate();
    _validateVadSegmentationConfig(config: config, splitOptions: splitOptions);
    await outputDirectory.create(recursive: true);

    final encoding = config.encoding;
    final managedBackend = _ManagedVadBackend.resolve(options: splitOptions, config: vadConfig);

    Stream<Uint8List> pcmStream;
    try {
      pcmStream = await startStream(
        config: config,
        pollInterval: pollInterval,
        readSampleCapacity: readSampleCapacity,
      );
    } on Object {
      managedBackend.disposeIfOwned();
      rethrow;
    }

    final resolvedAacEncoder = encoding.encoder.isAac
        ? (encoding.aacEncoder ?? NativeAacEncoder())
        : null;
    final bitrateBps = _resolveEncodingBitrateBps(encoding);

    return (() async* {
      final splitter = Pcm16StreamPauseSplitter(
        options: splitOptions,
        vadBackend: managedBackend.backend,
      );
      var segmentIndex = 0;

      Stream<VoiceSegment> emitSnippets(List<Pcm16Snippet> snippets) async* {
        for (final snippet in snippets) {
          segmentIndex++;
          try {
            final segment = await _materializeVoiceSegment(
              index: segmentIndex,
              snippet: snippet,
              outputDirectory: outputDirectory,
              splitOptions: splitOptions,
              encoding: encoding,
              bitrateBps: bitrateBps,
              aacEncoder: resolvedAacEncoder,
              segmentPathBuilder: segmentPathBuilder,
            );
            yield segment;
          } on Object catch (error, stackTrace) {
            yield* Stream<VoiceSegment>.error(error, stackTrace);
          }
        }
      }

      try {
        await for (final chunk in pcmStream) {
          yield* emitSnippets(splitter.addChunk(chunk));
        }
        if (flushOnStop) {
          yield* emitSnippets(splitter.flush());
        }
      } finally {
        managedBackend.disposeIfOwned();
      }
    })();
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

  Future<void> dispose() async {
    await stop();
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
        final chunk = _readStreamFn(maxSamples: _streamReadSampleCapacity);
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

  bool _shouldUseNativeMacosDirectAacStart({
    required String outputPath,
    required AudioRecorderConfig config,
  }) {
    final isMacosAac =
        _platform == NativeAudioRecorderPlatform.macOS && config.encoding.encoder.isAac;
    if (!isMacosAac) {
      return false;
    }

    final extension = path.extension(outputPath).toLowerCase();
    if (extension != '.m4a') {
      throw ArgumentError.value(
        outputPath,
        'outputPath',
        'macOS direct AAC recording requires an .m4a output path.',
      );
    }

    return true;
  }

  void _validateVadSegmentationConfig({
    required AudioRecorderConfig config,
    required PauseSplitOptions splitOptions,
  }) {
    if (!config.encoding.encoder.supportsVadSegmentationOutput) {
      throw ArgumentError.value(
        config.encoding.encoder,
        'config.encoding.encoder',
        'startWithVadSegmentation() supports AudioEncoder.wav, '
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
    required AacEncoder? aacEncoder,
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
        if (aacEncoder == null) {
          throw StateError('AAC encoder is required for AAC segment output.');
        }
        await aacEncoder.encodePcm16BytesToAac(
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
      final useMacosDirectAacStart =
          _platform == NativeAudioRecorderPlatform.macOS && config.encoding.encoder.isAac;
      if (!config.encoding.encoder.supportsNativeStartFile && !useMacosDirectAacStart) {
        if (tempWavPath == null) {
          throw StateError('Missing temporary WAV recording for encoded output.');
        }
        final aacEncoder = config.encoding.aacEncoder ?? NativeAacEncoder();
        await aacEncoder.encodeAudioFileToAac(
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

    if (_mode != _RecorderMode.file) {
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
    if (_mode != _RecorderMode.file || _nativeAmplitudePollInFlight) {
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

    if (_mode != _RecorderMode.stream) {
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

final class _ManagedVadBackend {
  const _ManagedVadBackend._({required this.backend, required this.owned});

  final VadBackend backend;
  final bool owned;

  factory _ManagedVadBackend.resolve({
    required PauseSplitOptions options,
    required SpeechVadConfig config,
  }) {
    final resolved = resolveSpeechVadBackend(options: options, config: config);
    return _ManagedVadBackend._(backend: resolved.backend, owned: true);
  }

  void disposeIfOwned() {
    if (!owned) {
      return;
    }
    backend.dispose();
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
    NativeAudioRecorderPlatform.macOS => _isMacosAudioRecorderAvailableViaFfi,
    NativeAudioRecorderPlatform.windows => _isWindowsAudioRecorderAvailableViaFfi,
    NativeAudioRecorderPlatform.iOS => _isIosAudioRecorderAvailableViaFfi,
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

NativeAudioRecorderStartFileFn _resolveStartFileFn(NativeAudioRecorderPlatform platform) {
  return switch (platform) {
    NativeAudioRecorderPlatform.macOS => _startMacosAudioRecorderFileViaFfi,
    NativeAudioRecorderPlatform.windows => _startWindowsAudioRecorderFileViaFfi,
    NativeAudioRecorderPlatform.iOS => _startIosAudioRecorderFileViaFfi,
    NativeAudioRecorderPlatform.unsupported =>
      ({
        required outputPath,
        required sampleRateHz,
        required channelCount,
        required inputDeviceId,
      }) => throw UnsupportedError(
        'NativeAudioRecorder is currently supported on macOS, Windows, and iOS.',
      ),
  };
}

NativeAudioRecorderStartStreamFn _resolveStartStreamFn(NativeAudioRecorderPlatform platform) {
  return switch (platform) {
    NativeAudioRecorderPlatform.macOS => _startMacosAudioRecorderStreamViaFfi,
    NativeAudioRecorderPlatform.windows => _startWindowsAudioRecorderStreamViaFfi,
    NativeAudioRecorderPlatform.iOS => _startIosAudioRecorderStreamViaFfi,
    NativeAudioRecorderPlatform.unsupported =>
      ({
        required sampleRateHz,
        required channelCount,
        required framesPerChunk,
        required inputDeviceId,
      }) => throw UnsupportedError(
        'NativeAudioRecorder is currently supported on macOS, Windows, and iOS.',
      ),
  };
}

NativeAudioRecorderReadStreamFn _resolveReadStreamFn(NativeAudioRecorderPlatform platform) {
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

typedef _NativeHealthcheckFn = int Function(ffi.Pointer<ffi.Char>, int);
typedef _NativeBoolOutFn = int Function(ffi.Pointer<ffi.Int32>, ffi.Pointer<ffi.Char>, int);
typedef _NativeStartFileFn =
    int Function(
      ffi.Pointer<ffi.Char>,
      int,
      int,
      ffi.Pointer<ffi.Char>,
      ffi.Pointer<ffi.Char>,
      int,
    );
typedef _NativeStartStreamFn =
    int Function(int, int, int, ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, int);
typedef _NativeReadStreamFn =
    int Function(ffi.Pointer<ffi.Int16>, int, ffi.Pointer<ffi.Uint32>, ffi.Pointer<ffi.Char>, int);
typedef _NativeStopFn = int Function(ffi.Pointer<ffi.Char>, int);
typedef _NativeListInputDevicesFn =
    int Function(ffi.Pointer<ffi.Char>, int, ffi.Pointer<ffi.Char>, int);
typedef _NativeGetAmplitudeFn =
    int Function(ffi.Pointer<ffi.Double>, ffi.Pointer<ffi.Double>, ffi.Pointer<ffi.Char>, int);

const _recorderErrorBufferBytes = 4096;

bool _runRecorderHealthcheck(_NativeHealthcheckFn fn) {
  final errorPtr = calloc<ffi.Char>(_recorderErrorBufferBytes);
  try {
    try {
      final code = fn(errorPtr, _recorderErrorBufferBytes);
      return code == 0;
    } on Object {
      return false;
    }
  } finally {
    calloc.free(errorPtr);
  }
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
  required String operation,
}) {
  final outputPathPtr = outputPath.toNativeUtf8(allocator: calloc).cast<ffi.Char>();
  final inputDeviceIdPtr = (inputDeviceId == null || inputDeviceId.trim().isEmpty)
      ? ffi.nullptr
      : inputDeviceId.toNativeUtf8(allocator: calloc).cast<ffi.Char>();
  final errorPtr = calloc<ffi.Char>(_recorderErrorBufferBytes);
  try {
    final code = fn(
      outputPathPtr,
      sampleRateHz,
      channelCount,
      inputDeviceIdPtr,
      errorPtr,
      _recorderErrorBufferBytes,
    );
    _throwRecorderExceptionIfNeeded(code: code, errorPtr: errorPtr, operation: operation);
  } finally {
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
  required String operation,
}) {
  final inputDeviceIdPtr = (inputDeviceId == null || inputDeviceId.trim().isEmpty)
      ? ffi.nullptr
      : inputDeviceId.toNativeUtf8(allocator: calloc).cast<ffi.Char>();
  final errorPtr = calloc<ffi.Char>(_recorderErrorBufferBytes);
  try {
    final code = fn(
      sampleRateHz,
      channelCount,
      framesPerChunk,
      inputDeviceIdPtr,
      errorPtr,
      _recorderErrorBufferBytes,
    );
    _throwRecorderExceptionIfNeeded(code: code, errorPtr: errorPtr, operation: operation);
  } finally {
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

bool _isMacosAudioRecorderAvailableViaFfi() {
  return _runRecorderHealthcheck(macos_bindings.speech_utils_macos_audio_recorder_healthcheck);
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
}) {
  _runRecorderStartFile(
    macos_bindings.speech_utils_macos_audio_recorder_start_file,
    outputPath: outputPath,
    sampleRateHz: sampleRateHz,
    channelCount: channelCount,
    inputDeviceId: inputDeviceId,
    operation: 'macOS file recording start',
  );
}

void _startMacosAudioRecorderStreamViaFfi({
  required int sampleRateHz,
  required int channelCount,
  required int framesPerChunk,
  required String? inputDeviceId,
}) {
  _runRecorderStartStream(
    macos_bindings.speech_utils_macos_audio_recorder_start_stream,
    sampleRateHz: sampleRateHz,
    channelCount: channelCount,
    framesPerChunk: framesPerChunk,
    inputDeviceId: inputDeviceId,
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
  return _runRecorderHealthcheck(windows_bindings.speech_utils_windows_audio_recorder_healthcheck);
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
}) {
  _runRecorderStartFile(
    windows_bindings.speech_utils_windows_audio_recorder_start_file,
    outputPath: outputPath,
    sampleRateHz: sampleRateHz,
    channelCount: channelCount,
    inputDeviceId: inputDeviceId,
    operation: 'Windows file recording start',
  );
}

void _startWindowsAudioRecorderStreamViaFfi({
  required int sampleRateHz,
  required int channelCount,
  required int framesPerChunk,
  required String? inputDeviceId,
}) {
  _runRecorderStartStream(
    windows_bindings.speech_utils_windows_audio_recorder_start_stream,
    sampleRateHz: sampleRateHz,
    channelCount: channelCount,
    framesPerChunk: framesPerChunk,
    inputDeviceId: inputDeviceId,
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

bool _isIosAudioRecorderAvailableViaFfi() {
  return _runRecorderHealthcheck(ios_bindings.speech_utils_ios_audio_recorder_healthcheck);
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
}) {
  _runRecorderStartFile(
    ios_bindings.speech_utils_ios_audio_recorder_start_file,
    outputPath: outputPath,
    sampleRateHz: sampleRateHz,
    channelCount: channelCount,
    inputDeviceId: inputDeviceId,
    operation: 'iOS file recording start',
  );
}

void _startIosAudioRecorderStreamViaFfi({
  required int sampleRateHz,
  required int channelCount,
  required int framesPerChunk,
  required String? inputDeviceId,
}) {
  _runRecorderStartStream(
    ios_bindings.speech_utils_ios_audio_recorder_start_stream,
    sampleRateHz: sampleRateHz,
    channelCount: channelCount,
    framesPerChunk: framesPerChunk,
    inputDeviceId: inputDeviceId,
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
