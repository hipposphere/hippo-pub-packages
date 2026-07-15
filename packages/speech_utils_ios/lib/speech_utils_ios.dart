import 'dart:typed_data';

import 'package:speech_utils_platform_interface/speech_utils_platform_ffi.dart';
import 'package:speech_utils_platform_interface/speech_utils_platform_interface.dart';

import 'src/generated/ios_audio_recorder_bindings.dart' as bindings;
import 'src/ios_aac_encoder.dart';

final class SpeechUtilsIos extends SpeechUtilsPlatform {
  const SpeechUtilsIos()
    : super(
        platform: NativeAudioRecorderPlatform.iOS,
        supportsInputSelection: true,
        capabilities: const NativeAudioRecorderCapabilities(
          supportsNoiseCancellation: false,
          supportsEchoCancellation: false,
          supportsVoiceIsolation: true,
        ),
      );

  static void registerWith() {
    SpeechUtilsPlatform.instance = const SpeechUtilsIos();
  }

  @override
  NativeAacEncoderBackend get aacEncoder => const IosAacEncoderBackend();

  @override
  NativeAudioMetadataBackend get metadataReader =>
      const IosAudioMetadataBackend();

  @override
  bool isAvailable() => true;

  @override
  bool hasPermission() => runRecorderBoolCall(
    bindings.speech_utils_ios_audio_recorder_has_permission,
    operation: 'iOS microphone permission check',
  );

  @override
  bool requestPermission() => runRecorderBoolCall(
    bindings.speech_utils_ios_audio_recorder_request_permission,
    operation: 'iOS microphone permission request',
  );

  @override
  List<InputDevice> listInputDevices() => runRecorderListInputDevices(
    bindings.speech_utils_ios_audio_recorder_list_input_devices_json,
    operation: 'iOS input device listing',
  );

  @override
  void startFile({
    required String outputPath,
    required AudioRecorderConfig config,
  }) {
    runRecorderStartFile(
      bindings.speech_utils_ios_audio_recorder_start_file,
      outputPath: outputPath,
      sampleRateHz: config.sampleRateHz,
      channelCount: config.channelCount,
      inputDeviceId: config.inputDeviceId,
      runtimeConfig: _runtime(config),
      operation: 'iOS file recording start',
    );
  }

  @override
  void startStream({required AudioRecorderConfig config}) {
    runRecorderStartStream(
      bindings.speech_utils_ios_audio_recorder_start_stream,
      sampleRateHz: config.sampleRateHz,
      channelCount: config.channelCount,
      framesPerChunk: config.framesPerChunk,
      inputDeviceId: config.inputDeviceId,
      runtimeConfig: _runtime(config),
      operation: 'iOS stream recording start',
    );
  }

  @override
  Uint8List readStream({required int maxSamples}) => runRecorderReadStream(
    bindings.speech_utils_ios_audio_recorder_read_stream_pcm16,
    maxSamples: maxSamples,
    operation: 'iOS stream read',
  );

  @override
  void stop() => runRecorderStop(
    bindings.speech_utils_ios_audio_recorder_stop,
    operation: 'iOS recording stop',
  );

  @override
  void reset() => runRecorderReset(
    bindings.speech_utils_ios_audio_recorder_reset,
    operation: 'iOS recorder reset',
  );

  @override
  bool isRecording() => runRecorderBoolCall(
    bindings.speech_utils_ios_audio_recorder_is_recording,
    operation: 'iOS recorder state read',
  );

  @override
  Amplitude getAmplitude() => runRecorderGetAmplitude(
    bindings.speech_utils_ios_audio_recorder_get_amplitude,
    operation: 'iOS recorder amplitude read',
  );
}

NativeRecorderRuntimeConfig _runtime(AudioRecorderConfig config) {
  final ios = config.iosConfig;
  final latency = config.processing.preferredLatency;
  final ioDuration = ios?.preferredIoBufferDuration ?? latency;
  final mode =
      ios?.sessionMode ??
      switch (config.processing.preset) {
        AudioCapturePreset.voice ||
        AudioCapturePreset.voiceIsolation => IosAudioSessionMode.voiceChat,
        AudioCapturePreset.raw ||
        AudioCapturePreset.music => IosAudioSessionMode.measurement,
      };
  var categoryFlags = 0;
  if (ios?.allowBluetoothInput ?? true) categoryFlags |= 1 << 0;
  if (ios?.allowBluetoothA2dp ?? false) categoryFlags |= 1 << 1;
  if (ios?.defaultToSpeaker ?? false) categoryFlags |= 1 << 2;
  if (ios?.mixWithOthers ?? false) categoryFlags |= 1 << 3;
  if (ios?.duckOthers ?? false) categoryFlags |= 1 << 4;

  return NativeRecorderRuntimeConfig(
    processingFlags: switch (config.processing.preset) {
      AudioCapturePreset.voice => 1 << 4,
      AudioCapturePreset.voiceIsolation => 1 << 5,
      AudioCapturePreset.raw => 1 << 6,
      AudioCapturePreset.music => 1 << 7,
    },
    iosSessionModeCode: switch (mode) {
      IosAudioSessionMode.defaultMode => 0,
      IosAudioSessionMode.voiceChat => 1,
      IosAudioSessionMode.videoChat => 2,
      IosAudioSessionMode.measurement => 3,
      IosAudioSessionMode.gameChat => 4,
      IosAudioSessionMode.spokenAudio => 5,
    },
    iosCategoryOptionsFlags: categoryFlags,
    preferredLatencySeconds: _seconds(latency),
    iosPreferredIoBufferDurationSeconds: _seconds(ioDuration),
    iosPreferredInputGain: ios?.preferredInputGain ?? -1,
    fileBitrateBps: config.encoding.encoder.isAac
        ? (config.encoding.bitrateBps ?? 64000)
        : 0,
    fileEncoderCode: 0,
  );
}

double _seconds(Duration? duration) => duration == null
    ? 0
    : duration.inMicroseconds / Duration.microsecondsPerSecond;
