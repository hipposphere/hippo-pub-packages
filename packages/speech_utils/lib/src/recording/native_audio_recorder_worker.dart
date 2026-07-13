part of 'native_audio_recorder.dart';

final _nativeAudioRecorderControlWorker = NativeWorkerExecutor(
  entrypoint: _nativeAudioRecorderControlWorkerMain,
  debugName: 'speech_utils recorder control',
);

bool _supportsRecorderControlWorker(NativeAudioRecorderPlatform platform) {
  return platform == NativeAudioRecorderPlatform.macOS ||
      platform == NativeAudioRecorderPlatform.windows;
}

enum _NativeAudioRecorderWorkerOperation {
  hasPermission,
  requestPermission,
  listInputDevices,
  startFile,
  startStream,
  stop,
  reset,
  setContinousRecording,
}

final class _NativeAudioRecorderWorkerRequest {
  const _NativeAudioRecorderWorkerRequest._({
    required this.operation,
    required this.platform,
    this.outputPath,
    this.sampleRateHz = 0,
    this.channelCount = 0,
    this.framesPerChunk = 0,
    this.inputDeviceId,
    this.runtimeConfig,
    this.enabled = false,
  });

  const _NativeAudioRecorderWorkerRequest.simple({
    required _NativeAudioRecorderWorkerOperation operation,
    required NativeAudioRecorderPlatform platform,
  }) : this._(operation: operation, platform: platform);

  factory _NativeAudioRecorderWorkerRequest.withConfig({
    required _NativeAudioRecorderWorkerOperation operation,
    required NativeAudioRecorderPlatform platform,
    required AudioRecorderConfig config,
    String? outputPath,
    bool enabled = false,
  }) {
    return _NativeAudioRecorderWorkerRequest._(
      operation: operation,
      platform: platform,
      outputPath: outputPath,
      sampleRateHz: config.sampleRateHz,
      channelCount: config.channelCount,
      framesPerChunk: config.framesPerChunk,
      inputDeviceId: config.inputDeviceId,
      runtimeConfig: _buildWorkerRuntimeConfig(platform: platform, config: config),
      enabled: enabled,
    );
  }

  final _NativeAudioRecorderWorkerOperation operation;
  final NativeAudioRecorderPlatform platform;
  final String? outputPath;
  final int sampleRateHz;
  final int channelCount;
  final int framesPerChunk;
  final String? inputDeviceId;
  final _NativeRecorderRuntimeConfig? runtimeConfig;
  final bool enabled;
}

_NativeRecorderRuntimeConfig _buildWorkerRuntimeConfig({
  required NativeAudioRecorderPlatform platform,
  required AudioRecorderConfig config,
}) {
  return switch (platform) {
    NativeAudioRecorderPlatform.macOS => const _MacosNativeRecorderRuntimeConfigBuilder().build(
      config,
    ),
    NativeAudioRecorderPlatform.windows => const _WindowsNativeRecorderRuntimeConfigBuilder().build(
      config,
    ),
    NativeAudioRecorderPlatform.android ||
    NativeAudioRecorderPlatform.linux ||
    NativeAudioRecorderPlatform.iOS ||
    NativeAudioRecorderPlatform.unsupported => throw UnsupportedError(
      'Recorder control worker is unavailable for $platform',
    ),
  };
}

@pragma('vm:entry-point')
void _nativeAudioRecorderControlWorkerMain(SendPort replyPort) {
  runNativeWorker(replyPort, (Object? rawRequest) {
    if (rawRequest is! _NativeAudioRecorderWorkerRequest) {
      throw ArgumentError.value(rawRequest, 'request', 'Invalid recorder worker request');
    }
    final request = rawRequest;
    return switch (request.operation) {
      _NativeAudioRecorderWorkerOperation.hasPermission => _workerRecorderHasPermission(
        request.platform,
      ),
      _NativeAudioRecorderWorkerOperation.requestPermission => _workerRecorderRequestPermission(
        request.platform,
      ),
      _NativeAudioRecorderWorkerOperation.listInputDevices => _workerRecorderListInputDevices(
        request.platform,
      ),
      _NativeAudioRecorderWorkerOperation.startFile => _workerRecorderStartFile(request),
      _NativeAudioRecorderWorkerOperation.startStream => _workerRecorderStartStream(request),
      _NativeAudioRecorderWorkerOperation.stop => _workerRecorderStop(request.platform),
      _NativeAudioRecorderWorkerOperation.reset => _workerRecorderReset(request.platform),
      _NativeAudioRecorderWorkerOperation.setContinousRecording =>
        _workerRecorderSetContinousRecording(request),
    };
  });
}

bool _workerRecorderHasPermission(NativeAudioRecorderPlatform platform) {
  return switch (platform) {
    NativeAudioRecorderPlatform.macOS => _hasMacosMicrophonePermissionViaFfi(),
    NativeAudioRecorderPlatform.windows => _hasWindowsMicrophonePermissionViaFfi(),
    _ => throw UnsupportedError('Recorder control worker is unavailable for $platform'),
  };
}

bool _workerRecorderRequestPermission(NativeAudioRecorderPlatform platform) {
  return switch (platform) {
    NativeAudioRecorderPlatform.macOS => _requestMacosMicrophonePermissionViaFfi(),
    NativeAudioRecorderPlatform.windows => _requestWindowsMicrophonePermissionViaFfi(),
    _ => throw UnsupportedError('Recorder control worker is unavailable for $platform'),
  };
}

List<InputDevice> _workerRecorderListInputDevices(NativeAudioRecorderPlatform platform) {
  return switch (platform) {
    NativeAudioRecorderPlatform.macOS => _listMacosAudioRecorderInputDevicesViaFfi(),
    NativeAudioRecorderPlatform.windows => _listWindowsAudioRecorderInputDevicesViaFfi(),
    _ => throw UnsupportedError('Recorder control worker is unavailable for $platform'),
  };
}

void _workerRecorderStartFile(_NativeAudioRecorderWorkerRequest request) {
  final outputPath = request.outputPath;
  final runtimeConfig = request.runtimeConfig;
  if (outputPath == null || runtimeConfig == null) {
    throw StateError('Recorder file-start worker request is incomplete');
  }
  switch (request.platform) {
    case NativeAudioRecorderPlatform.macOS:
      _startMacosAudioRecorderFileViaFfi(
        outputPath: outputPath,
        sampleRateHz: request.sampleRateHz,
        channelCount: request.channelCount,
        inputDeviceId: request.inputDeviceId,
        runtimeConfig: runtimeConfig,
      );
    case NativeAudioRecorderPlatform.windows:
      _startWindowsAudioRecorderFileViaFfi(
        outputPath: outputPath,
        sampleRateHz: request.sampleRateHz,
        channelCount: request.channelCount,
        inputDeviceId: request.inputDeviceId,
        runtimeConfig: runtimeConfig,
      );
    default:
      throw UnsupportedError('Recorder control worker is unavailable for ${request.platform}');
  }
}

void _workerRecorderStartStream(_NativeAudioRecorderWorkerRequest request) {
  final runtimeConfig = request.runtimeConfig;
  if (runtimeConfig == null) {
    throw StateError('Recorder stream-start worker request is incomplete');
  }
  switch (request.platform) {
    case NativeAudioRecorderPlatform.macOS:
      _startMacosAudioRecorderStreamViaFfi(
        sampleRateHz: request.sampleRateHz,
        channelCount: request.channelCount,
        framesPerChunk: request.framesPerChunk,
        inputDeviceId: request.inputDeviceId,
        runtimeConfig: runtimeConfig,
      );
    case NativeAudioRecorderPlatform.windows:
      _startWindowsAudioRecorderStreamViaFfi(
        sampleRateHz: request.sampleRateHz,
        channelCount: request.channelCount,
        framesPerChunk: request.framesPerChunk,
        inputDeviceId: request.inputDeviceId,
        runtimeConfig: runtimeConfig,
      );
    default:
      throw UnsupportedError('Recorder control worker is unavailable for ${request.platform}');
  }
}

void _workerRecorderStop(NativeAudioRecorderPlatform platform) {
  switch (platform) {
    case NativeAudioRecorderPlatform.macOS:
      _stopMacosAudioRecorderViaFfi();
    case NativeAudioRecorderPlatform.windows:
      _stopWindowsAudioRecorderViaFfi();
    default:
      throw UnsupportedError('Recorder control worker is unavailable for $platform');
  }
}

void _workerRecorderReset(NativeAudioRecorderPlatform platform) {
  switch (platform) {
    case NativeAudioRecorderPlatform.macOS:
      _resetMacosAudioRecorderViaFfi();
    case NativeAudioRecorderPlatform.windows:
      _resetWindowsAudioRecorderViaFfi();
    default:
      throw UnsupportedError('Recorder control worker is unavailable for $platform');
  }
}

void _workerRecorderSetContinousRecording(_NativeAudioRecorderWorkerRequest request) {
  final runtimeConfig = request.runtimeConfig;
  if (runtimeConfig == null) {
    throw StateError('Recorder continuous-capture worker request is incomplete');
  }
  switch (request.platform) {
    case NativeAudioRecorderPlatform.macOS:
      _setMacosAudioRecorderContinousCaptureViaFfi(
        enabled: request.enabled,
        sampleRateHz: request.sampleRateHz,
        channelCount: request.channelCount,
        framesPerChunk: request.framesPerChunk,
        inputDeviceId: request.inputDeviceId,
        runtimeConfig: runtimeConfig,
      );
    case NativeAudioRecorderPlatform.windows:
      _setWindowsAudioRecorderContinousCaptureViaFfi(
        enabled: request.enabled,
        sampleRateHz: request.sampleRateHz,
        channelCount: request.channelCount,
        framesPerChunk: request.framesPerChunk,
        inputDeviceId: request.inputDeviceId,
        runtimeConfig: runtimeConfig,
      );
    default:
      throw UnsupportedError('Recorder control worker is unavailable for ${request.platform}');
  }
}
