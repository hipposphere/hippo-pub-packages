part of 'package:speech_utils/src/recording/native_audio_recorder.dart';

final class _WindowsNativeAudioRecorderPlatformImplementation
    extends NativeAudioRecorderPlatformImplementation {
  const _WindowsNativeAudioRecorderPlatformImplementation()
    : super(
        platform: NativeAudioRecorderPlatform.windows,
        supportsInputSelection: true,
        capabilities: const NativeAudioRecorderCapabilities(
          supportsNoiseCancellation: true,
          supportsEchoCancellation: false,
          supportsVoiceIsolation: true,
        ),
      );

  static const _runtimeConfigBuilder = _WindowsNativeRecorderRuntimeConfigBuilder();

  @override
  bool isAvailable() => _isWindowsAudioRecorderAvailableViaFfi();

  @override
  bool hasPermission() => _hasWindowsMicrophonePermissionViaFfi();

  @override
  bool requestPermission() => _requestWindowsMicrophonePermissionViaFfi();

  @override
  List<InputDevice> listInputDevices() => _listWindowsAudioRecorderInputDevicesViaFfi();

  @override
  void startFile({required String outputPath, required AudioRecorderConfig config}) {
    _startWindowsAudioRecorderFileViaFfi(
      outputPath: outputPath,
      sampleRateHz: config.sampleRateHz,
      channelCount: config.channelCount,
      inputDeviceId: config.inputDeviceId,
      runtimeConfig: _runtimeConfigBuilder.build(config),
    );
  }

  @override
  void startStream({required AudioRecorderConfig config}) {
    _startWindowsAudioRecorderStreamViaFfi(
      sampleRateHz: config.sampleRateHz,
      channelCount: config.channelCount,
      framesPerChunk: config.framesPerChunk,
      inputDeviceId: config.inputDeviceId,
      runtimeConfig: _runtimeConfigBuilder.build(config),
    );
  }

  @override
  Uint8List readStream({required int maxSamples}) {
    return _readWindowsAudioRecorderStreamViaFfi(maxSamples: maxSamples);
  }

  @override
  void stop() => _stopWindowsAudioRecorderViaFfi();

  @override
  void reset() => _resetWindowsAudioRecorderViaFfi();

  @override
  void setContinousRecording(
    bool enabled, {
    AudioRecorderConfig config = const AudioRecorderConfig(),
  }) {
    _setWindowsAudioRecorderContinousCaptureViaFfi(
      enabled: enabled,
      sampleRateHz: config.sampleRateHz,
      channelCount: config.channelCount,
      framesPerChunk: config.framesPerChunk,
      inputDeviceId: config.inputDeviceId,
      runtimeConfig: _runtimeConfigBuilder.build(config),
    );
  }

  @override
  bool isRecording() => _isWindowsAudioRecorderRunningViaFfi();

  @override
  Amplitude getAmplitude() => _getWindowsAudioRecorderAmplitudeViaFfi();
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

void _setWindowsAudioRecorderContinousCaptureViaFfi({
  required bool enabled,
  required int sampleRateHz,
  required int channelCount,
  required int framesPerChunk,
  required String? inputDeviceId,
  required _NativeRecorderRuntimeConfig runtimeConfig,
}) {
  _runRecorderSetContinousCapture(
    windows_bindings.speech_utils_windows_audio_recorder_set_continous_capture,
    enabled: enabled,
    sampleRateHz: sampleRateHz,
    channelCount: channelCount,
    framesPerChunk: framesPerChunk,
    inputDeviceId: inputDeviceId,
    runtimeConfig: runtimeConfig,
    operation: 'Windows continuous capture toggle',
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
