part of 'package:speech_utils/src/recording/native_audio_recorder.dart';

final class _MacosNativeAudioRecorderPlatformImplementation
    extends NativeAudioRecorderPlatformImplementation {
  const _MacosNativeAudioRecorderPlatformImplementation()
      : super(
          platform: NativeAudioRecorderPlatform.macOS,
          supportsInputSelection: true,
          capabilities: const NativeAudioRecorderCapabilities(
            supportsNoiseCancellation: false,
            supportsEchoCancellation: false,
            supportsVoiceIsolation: true,
          ),
        );

  static const _runtimeConfigBuilder = _MacosNativeRecorderRuntimeConfigBuilder();

  @override
  bool isAvailable() => true;

  @override
  bool hasPermission() => _hasMacosMicrophonePermissionViaFfi();

  @override
  bool requestPermission() => _requestMacosMicrophonePermissionViaFfi();

  @override
  List<InputDevice> listInputDevices() =>
      _listMacosAudioRecorderInputDevicesViaFfi();

  @override
  void startFile({required String outputPath, required AudioRecorderConfig config}) {
    _startMacosAudioRecorderFileViaFfi(
      outputPath: outputPath,
      sampleRateHz: config.sampleRateHz,
      channelCount: config.channelCount,
      inputDeviceId: config.inputDeviceId,
      runtimeConfig: _runtimeConfigBuilder.build(config),
    );
  }

  @override
  void startStream({required AudioRecorderConfig config}) {
    _startMacosAudioRecorderStreamViaFfi(
      sampleRateHz: config.sampleRateHz,
      channelCount: config.channelCount,
      framesPerChunk: config.framesPerChunk,
      inputDeviceId: config.inputDeviceId,
      runtimeConfig: _runtimeConfigBuilder.build(config),
    );
  }

  @override
  Uint8List readStream({required int maxSamples}) {
    return _readMacosAudioRecorderStreamViaFfi(maxSamples: maxSamples);
  }

  @override
  void stop() => _stopMacosAudioRecorderViaFfi();

  @override
  void reset() => _resetMacosAudioRecorderViaFfi();

  @override
  bool isRecording() => _isMacosAudioRecorderRunningViaFfi();

  @override
  Amplitude getAmplitude() => _getMacosAudioRecorderAmplitudeViaFfi();
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
