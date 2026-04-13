part of 'package:speech_utils/src/recording/native_audio_recorder.dart';

final class _IosNativeAudioRecorderPlatformImplementation
    extends NativeAudioRecorderPlatformImplementation {
  const _IosNativeAudioRecorderPlatformImplementation()
    : super(
        platform: NativeAudioRecorderPlatform.iOS,
        supportsInputSelection: true,
        capabilities: const NativeAudioRecorderCapabilities(
          supportsNoiseCancellation: false,
          supportsEchoCancellation: false,
          supportsVoiceIsolation: true,
        ),
      );

  static const _runtimeConfigBuilder = _IosNativeRecorderRuntimeConfigBuilder();

  @override
  bool isAvailable() => true;

  @override
  bool hasPermission() => _hasIosMicrophonePermissionViaFfi();

  @override
  bool requestPermission() => _requestIosMicrophonePermissionViaFfi();

  @override
  List<InputDevice> listInputDevices() => _listIosAudioRecorderInputDevicesViaFfi();

  @override
  void startFile({required String outputPath, required AudioRecorderConfig config}) {
    _startIosAudioRecorderFileViaFfi(
      outputPath: outputPath,
      sampleRateHz: config.sampleRateHz,
      channelCount: config.channelCount,
      inputDeviceId: config.inputDeviceId,
      runtimeConfig: _runtimeConfigBuilder.build(config),
    );
  }

  @override
  void startStream({required AudioRecorderConfig config}) {
    _startIosAudioRecorderStreamViaFfi(
      sampleRateHz: config.sampleRateHz,
      channelCount: config.channelCount,
      framesPerChunk: config.framesPerChunk,
      inputDeviceId: config.inputDeviceId,
      runtimeConfig: _runtimeConfigBuilder.build(config),
    );
  }

  @override
  Uint8List readStream({required int maxSamples}) {
    return _readIosAudioRecorderStreamViaFfi(maxSamples: maxSamples);
  }

  @override
  void stop() => _stopIosAudioRecorderViaFfi();

  @override
  void reset() => _resetIosAudioRecorderViaFfi();

  @override
  bool isRecording() => _isIosAudioRecorderRunningViaFfi();

  @override
  Amplitude getAmplitude() => _getIosAudioRecorderAmplitudeViaFfi();
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
