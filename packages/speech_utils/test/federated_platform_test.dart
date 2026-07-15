import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:speech_utils/speech_utils.dart';

void main() {
  test('default recorder uses a registered federated implementation', () async {
    final platform = _hostPlatform();
    if (platform == NativeAudioRecorderPlatform.unsupported) return;

    final previous = SpeechUtilsPlatform.instance;
    final fake = _RegisteredPlatform(platform);
    SpeechUtilsPlatform.instance = fake;
    addTearDown(() => SpeechUtilsPlatform.instance = previous);

    final recorder = NativeAudioRecorder();
    expect(recorder.platform, platform);
    expect(await recorder.hasPermission(), isTrue);
    expect(fake.permissionChecks, 1);
  });
}

NativeAudioRecorderPlatform _hostPlatform() {
  if (Platform.isAndroid) return NativeAudioRecorderPlatform.android;
  if (Platform.isIOS) return NativeAudioRecorderPlatform.iOS;
  if (Platform.isMacOS) return NativeAudioRecorderPlatform.macOS;
  if (Platform.isWindows) return NativeAudioRecorderPlatform.windows;
  if (Platform.isLinux) return NativeAudioRecorderPlatform.linux;
  return NativeAudioRecorderPlatform.unsupported;
}

final class _RegisteredPlatform extends SpeechUtilsPlatform {
  _RegisteredPlatform(NativeAudioRecorderPlatform platform)
    : super(
        platform: platform,
        supportsInputSelection: true,
        capabilities: const NativeAudioRecorderCapabilities(
          supportsNoiseCancellation: false,
          supportsEchoCancellation: false,
          supportsVoiceIsolation: false,
        ),
      );

  int permissionChecks = 0;

  @override
  bool isAvailable() => true;

  @override
  bool hasPermission() {
    permissionChecks += 1;
    return true;
  }

  @override
  FutureOr<bool> requestPermission() => true;

  @override
  List<InputDevice> listInputDevices() => const [];

  @override
  FutureOr<void> startFile({required String outputPath, required AudioRecorderConfig config}) {}

  @override
  FutureOr<void> startStream({required AudioRecorderConfig config}) {}

  @override
  Uint8List readStream({required int maxSamples}) => Uint8List(0);

  @override
  FutureOr<void> stop() {}

  @override
  FutureOr<void> reset() {}

  @override
  bool isRecording() => false;

  @override
  Amplitude getAmplitude() => const Amplitude(current: -90);
}
