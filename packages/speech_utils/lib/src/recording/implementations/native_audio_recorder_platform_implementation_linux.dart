part of 'package:speech_utils/src/recording/native_audio_recorder.dart';

final class _LinuxNativeAudioRecorderPlatformImplementation
    extends NativeAudioRecorderPlatformImplementation {
  const _LinuxNativeAudioRecorderPlatformImplementation()
    : super(
        platform: NativeAudioRecorderPlatform.linux,
        supportsInputSelection: true,
        capabilities: const NativeAudioRecorderCapabilities(
          supportsNoiseCancellation: true,
          supportsEchoCancellation: false,
          supportsVoiceIsolation: true,
        ),
      );

  static const _runtimeConfigBuilder = _LinuxNativeRecorderRuntimeConfigBuilder();

  @override
  bool isAvailable() => _isLinuxAudioRecorderAvailableViaFfi();

  @override
  bool hasPermission() => _hasLinuxMicrophonePermissionViaFfi();

  @override
  bool requestPermission() => _requestLinuxMicrophonePermissionViaFfi();

  @override
  List<InputDevice> listInputDevices() => _listLinuxAudioRecorderInputDevicesViaFfi();

  @override
  void startFile({required String outputPath, required AudioRecorderConfig config}) {
    _startLinuxAudioRecorderFileViaFfi(
      outputPath: outputPath,
      sampleRateHz: config.sampleRateHz,
      channelCount: config.channelCount,
      inputDeviceId: config.inputDeviceId,
      runtimeConfig: _runtimeConfigBuilder.build(config),
    );
  }

  @override
  void startStream({required AudioRecorderConfig config}) {
    _startLinuxAudioRecorderStreamViaFfi(
      sampleRateHz: config.sampleRateHz,
      channelCount: config.channelCount,
      framesPerChunk: config.framesPerChunk,
      inputDeviceId: config.inputDeviceId,
      runtimeConfig: _runtimeConfigBuilder.build(config),
    );
  }

  @override
  Uint8List readStream({required int maxSamples}) {
    return _readLinuxAudioRecorderStreamViaFfi(maxSamples: maxSamples);
  }

  @override
  void stop() => _stopLinuxAudioRecorderViaFfi();

  @override
  void reset() => _resetLinuxAudioRecorderViaFfi();

  @override
  void setContinousRecording(
    bool enabled, {
    AudioRecorderConfig config = const AudioRecorderConfig(),
  }) {
    _setLinuxAudioRecorderContinousCaptureViaFfi(
      enabled: enabled,
      sampleRateHz: config.sampleRateHz,
      channelCount: config.channelCount,
      framesPerChunk: config.framesPerChunk,
      inputDeviceId: config.inputDeviceId,
      runtimeConfig: _runtimeConfigBuilder.build(config),
    );
  }

  @override
  bool isRecording() => _isLinuxAudioRecorderRunningViaFfi();

  @override
  Amplitude getAmplitude() => _getLinuxAudioRecorderAmplitudeViaFfi();
}

bool _isLinuxAudioRecorderAvailableViaFfi() {
  return true;
}

bool _hasLinuxMicrophonePermissionViaFfi() {
  return _runRecorderBoolCall(
    linux_bindings.speech_utils_linux_audio_recorder_has_permission,
    operation: 'Linux microphone permission check',
  );
}

bool _requestLinuxMicrophonePermissionViaFfi() {
  return _runRecorderBoolCall(
    linux_bindings.speech_utils_linux_audio_recorder_request_permission,
    operation: 'Linux microphone permission request',
  );
}

void _startLinuxAudioRecorderFileViaFfi({
  required String outputPath,
  required int sampleRateHz,
  required int channelCount,
  required String? inputDeviceId,
  required _NativeRecorderRuntimeConfig runtimeConfig,
}) {
  _runRecorderStartFile(
    linux_bindings.speech_utils_linux_audio_recorder_start_file,
    outputPath: outputPath,
    sampleRateHz: sampleRateHz,
    channelCount: channelCount,
    inputDeviceId: inputDeviceId,
    runtimeConfig: runtimeConfig,
    operation: 'Linux file recording start',
  );
}

void _startLinuxAudioRecorderStreamViaFfi({
  required int sampleRateHz,
  required int channelCount,
  required int framesPerChunk,
  required String? inputDeviceId,
  required _NativeRecorderRuntimeConfig runtimeConfig,
}) {
  _runRecorderStartStream(
    linux_bindings.speech_utils_linux_audio_recorder_start_stream,
    sampleRateHz: sampleRateHz,
    channelCount: channelCount,
    framesPerChunk: framesPerChunk,
    inputDeviceId: inputDeviceId,
    runtimeConfig: runtimeConfig,
    operation: 'Linux stream recording start',
  );
}

List<InputDevice> _listLinuxAudioRecorderInputDevicesViaFfi() {
  return _runRecorderListInputDevices(
    linux_bindings.speech_utils_linux_audio_recorder_list_input_devices_json,
    operation: 'Linux input device listing',
  );
}

Uint8List _readLinuxAudioRecorderStreamViaFfi({required int maxSamples}) {
  return _runRecorderReadStream(
    linux_bindings.speech_utils_linux_audio_recorder_read_stream_pcm16,
    maxSamples: maxSamples,
    operation: 'Linux stream read',
  );
}

void _stopLinuxAudioRecorderViaFfi() {
  _runRecorderStop(
    linux_bindings.speech_utils_linux_audio_recorder_stop,
    operation: 'Linux recording stop',
  );
}

void _resetLinuxAudioRecorderViaFfi() {
  _runRecorderReset(
    linux_bindings.speech_utils_linux_audio_recorder_reset,
    operation: 'Linux recorder reset',
  );
}

void _setLinuxAudioRecorderContinousCaptureViaFfi({
  required bool enabled,
  required int sampleRateHz,
  required int channelCount,
  required int framesPerChunk,
  required String? inputDeviceId,
  required _NativeRecorderRuntimeConfig runtimeConfig,
}) {
  _runRecorderSetContinousCapture(
    linux_bindings.speech_utils_linux_audio_recorder_set_continous_capture,
    enabled: enabled,
    sampleRateHz: sampleRateHz,
    channelCount: channelCount,
    framesPerChunk: framesPerChunk,
    inputDeviceId: inputDeviceId,
    runtimeConfig: runtimeConfig,
    operation: 'Linux continuous capture toggle',
  );
}

bool _isLinuxAudioRecorderRunningViaFfi() {
  return _runRecorderBoolCall(
    linux_bindings.speech_utils_linux_audio_recorder_is_recording,
    operation: 'Linux recorder state read',
  );
}

Amplitude _getLinuxAudioRecorderAmplitudeViaFfi() {
  return _runRecorderGetAmplitude(
    linux_bindings.speech_utils_linux_audio_recorder_get_amplitude,
    operation: 'Linux recorder amplitude read',
  );
}
