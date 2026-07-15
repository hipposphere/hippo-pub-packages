import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:speech_utils_platform_interface/speech_utils_platform_ffi.dart';
import 'package:speech_utils_platform_interface/speech_utils_platform_interface.dart';

import 'src/generated/windows_audio_recorder_bindings.dart' as bindings;
import 'src/windows_aac_encoder.dart';

final class SpeechUtilsWindows extends SpeechUtilsPlatform {
  SpeechUtilsWindows()
    : super(
        platform: NativeAudioRecorderPlatform.windows,
        supportsInputSelection: true,
        capabilities: const NativeAudioRecorderCapabilities(
          supportsNoiseCancellation: true,
          supportsEchoCancellation: false,
          supportsVoiceIsolation: true,
        ),
      );

  static final NativeWorkerExecutor _controlWorker = NativeWorkerExecutor(
    entrypoint: _windowsWorkerMain,
    debugName: 'speech_utils Windows control',
  );

  static void registerWith() {
    SpeechUtilsPlatform.instance = SpeechUtilsWindows();
  }

  @override
  NativeAacEncoderBackend get aacEncoder => const WindowsAacEncoderBackend();

  @override
  NativeAudioMetadataBackend get metadataReader =>
      const WindowsAudioMetadataBackend();

  @override
  bool isAvailable() => true;

  @override
  Future<bool> hasPermission() =>
      _controlWorker.execute<bool>(const {'op': 'hasPermission'});

  @override
  Future<bool> requestPermission() =>
      _controlWorker.execute<bool>(const {'op': 'requestPermission'});

  @override
  Future<List<InputDevice>> listInputDevices() async {
    final values = await _controlWorker.execute<List<Object?>>(const {
      'op': 'listDevices',
    });
    return values
        .whereType<Map<Object?, Object?>>()
        .map((value) => InputDevice.fromJson(value.cast<String, Object?>()))
        .toList(growable: false);
  }

  @override
  Future<void> startFile({
    required String outputPath,
    required AudioRecorderConfig config,
  }) {
    return _controlWorker.execute<void>(
      _request('startFile', config, outputPath: outputPath),
    );
  }

  @override
  Future<void> startStream({required AudioRecorderConfig config}) {
    return _controlWorker.execute<void>(_request('startStream', config));
  }

  @override
  Uint8List readStream({required int maxSamples}) {
    return runRecorderReadStream(
      bindings.speech_utils_windows_audio_recorder_read_stream_pcm16,
      maxSamples: maxSamples,
      operation: 'Windows stream read',
    );
  }

  @override
  Future<void> stop() => _controlWorker.execute<void>(const {'op': 'stop'});

  @override
  Future<void> reset() => _controlWorker.execute<void>(const {'op': 'reset'});

  @override
  Future<void> setContinousRecording(
    bool enabled, {
    AudioRecorderConfig config = const AudioRecorderConfig(),
  }) {
    return _controlWorker.execute<void>(
      _request('setContinuous', config, enabled: enabled),
    );
  }

  @override
  bool isRecording() {
    return runRecorderBoolCall(
      bindings.speech_utils_windows_audio_recorder_is_recording,
      operation: 'Windows recorder state read',
    );
  }

  @override
  Amplitude getAmplitude() {
    return runRecorderGetAmplitude(
      bindings.speech_utils_windows_audio_recorder_get_amplitude,
      operation: 'Windows recorder amplitude read',
    );
  }
}

Map<String, Object?> _request(
  String operation,
  AudioRecorderConfig config, {
  String? outputPath,
  bool? enabled,
}) {
  final runtime = _windowsRuntimeConfig(config);
  return <String, Object?>{
    'op': operation,
    'outputPath': outputPath,
    'enabled': enabled,
    'sampleRateHz': config.sampleRateHz,
    'channelCount': config.channelCount,
    'framesPerChunk': config.framesPerChunk,
    'inputDeviceId': config.inputDeviceId,
    'processingFlags': runtime.processingFlags,
    'preferredLatencySeconds': runtime.preferredLatencySeconds,
    'windowsPreferredPeriodFrames': runtime.windowsPreferredPeriodFrames,
    'windowsFlags': runtime.windowsFlags,
    'windowsCaptureCategoryCode': runtime.windowsCaptureCategoryCode,
    'windowsUseCommunicationsDevice': runtime.windowsUseCommunicationsDevice,
    'windowsVoiceProcessingModeCode': runtime.windowsVoiceProcessingModeCode,
  };
}

NativeRecorderRuntimeConfig _windowsRuntimeConfig(AudioRecorderConfig config) {
  final processing = config.processing;
  final windows = config.windowsConfig;
  var processingFlags = switch (processing.preset) {
    AudioCapturePreset.voice => 1 << 4,
    AudioCapturePreset.voiceIsolation => 1 << 5,
    AudioCapturePreset.raw => 1 << 6,
    AudioCapturePreset.music => 1 << 7,
  };
  if (processing.resolveNoiseSuppressionForPlatform(
    AudioProcessingPlatform.windows,
  )) {
    processingFlags |= 1 << 0;
  }
  if (processing.resolveEchoCancellationForPlatform(
    AudioProcessingPlatform.windows,
  )) {
    processingFlags |= 1 << 1;
  }
  if (processing.resolveAutomaticGainControlForPlatform(
    AudioProcessingPlatform.windows,
  )) {
    processingFlags |= 1 << 2;
  }
  if (processing.resolveHighPassFilterForPlatform(
    AudioProcessingPlatform.windows,
  )) {
    processingFlags |= 1 << 3;
  }

  final targetDuration =
      windows?.targetBufferDuration ?? processing.preferredLatency;
  final preferredPeriodFrames = targetDuration == null
      ? 0
      : ((targetDuration.inMicroseconds * config.sampleRateHz) ~/
                Duration.microsecondsPerSecond)
            .clamp(0, 0x7fffffff);

  return NativeRecorderRuntimeConfig(
    processingFlags: processingFlags,
    preferredLatencySeconds: _seconds(processing.preferredLatency),
    windowsPreferredPeriodFrames: preferredPeriodFrames,
    windowsFlags:
        (windows?.useExclusiveMode == true ? 1 << 0 : 0) |
        (windows?.useRawCapture == true ? 1 << 1 : 0),
    windowsCaptureCategoryCode: switch (windows?.captureCategory) {
      WindowsCaptureCategory.media => 0,
      WindowsCaptureCategory.communications => 1,
      WindowsCaptureCategory.speech || null => 2,
    },
    windowsUseCommunicationsDevice: windows?.useCommunicationsDevice == true
        ? 1
        : 0,
    windowsVoiceProcessingModeCode: switch (windows?.voiceProcessingMode) {
      WindowsVoiceProcessingMode.system => 1,
      WindowsVoiceProcessingMode.software => 2,
      WindowsVoiceProcessingMode.off => 3,
      WindowsVoiceProcessingMode.auto || null => 0,
    },
  );
}

double _seconds(Duration? duration) => duration == null
    ? 0
    : duration.inMicroseconds / Duration.microsecondsPerSecond;

void _windowsWorkerMain(SendPort replyPort) {
  runNativeWorker(replyPort, _handleWindowsWorkerRequest);
}

Object? _handleWindowsWorkerRequest(Object? rawRequest) {
  final request = (rawRequest! as Map<Object?, Object?>)
      .cast<String, Object?>();
  final operation = request['op']! as String;
  switch (operation) {
    case 'hasPermission':
      return runRecorderBoolCall(
        bindings.speech_utils_windows_audio_recorder_has_permission,
        operation: 'Windows microphone permission check',
      );
    case 'requestPermission':
      return runRecorderBoolCall(
        bindings.speech_utils_windows_audio_recorder_request_permission,
        operation: 'Windows microphone permission request',
      );
    case 'listDevices':
      return runRecorderListInputDevices(
        bindings.speech_utils_windows_audio_recorder_list_input_devices_json,
        operation: 'Windows input device listing',
      ).map((device) => device.toJson()).toList(growable: false);
    case 'startFile':
      runRecorderStartFile(
        bindings.speech_utils_windows_audio_recorder_start_file,
        outputPath: request['outputPath']! as String,
        sampleRateHz: request['sampleRateHz']! as int,
        channelCount: request['channelCount']! as int,
        inputDeviceId: request['inputDeviceId'] as String?,
        runtimeConfig: _runtimeFromRequest(request),
        operation: 'Windows file recording start',
      );
      return null;
    case 'startStream':
      runRecorderStartStream(
        bindings.speech_utils_windows_audio_recorder_start_stream,
        sampleRateHz: request['sampleRateHz']! as int,
        channelCount: request['channelCount']! as int,
        framesPerChunk: request['framesPerChunk']! as int,
        inputDeviceId: request['inputDeviceId'] as String?,
        runtimeConfig: _runtimeFromRequest(request),
        operation: 'Windows stream recording start',
      );
      return null;
    case 'setContinuous':
      runRecorderSetContinousCapture(
        bindings.speech_utils_windows_audio_recorder_set_continous_capture,
        enabled: request['enabled']! as bool,
        sampleRateHz: request['sampleRateHz']! as int,
        channelCount: request['channelCount']! as int,
        framesPerChunk: request['framesPerChunk']! as int,
        inputDeviceId: request['inputDeviceId'] as String?,
        runtimeConfig: _runtimeFromRequest(request),
        operation: 'Windows continuous capture toggle',
      );
      return null;
    case 'stop':
      runRecorderStop(
        bindings.speech_utils_windows_audio_recorder_stop,
        operation: 'Windows recording stop',
      );
      return null;
    case 'reset':
      runRecorderReset(
        bindings.speech_utils_windows_audio_recorder_reset,
        operation: 'Windows recorder reset',
      );
      return null;
  }
  throw UnsupportedError('Unknown Windows recorder operation: $operation');
}

NativeRecorderRuntimeConfig _runtimeFromRequest(Map<String, Object?> request) {
  return NativeRecorderRuntimeConfig(
    processingFlags: request['processingFlags']! as int,
    preferredLatencySeconds: request['preferredLatencySeconds']! as double,
    windowsPreferredPeriodFrames:
        request['windowsPreferredPeriodFrames']! as int,
    windowsFlags: request['windowsFlags']! as int,
    windowsCaptureCategoryCode: request['windowsCaptureCategoryCode']! as int,
    windowsUseCommunicationsDevice:
        request['windowsUseCommunicationsDevice']! as int,
    windowsVoiceProcessingModeCode:
        request['windowsVoiceProcessingModeCode']! as int,
  );
}
