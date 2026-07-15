import 'package:flutter_test/flutter_test.dart';
import 'package:speech_utils_macos/speech_utils_macos.dart';
import 'package:speech_utils_platform_interface/speech_utils_platform_interface.dart';

void main() {
  test('registers the macOS implementation', () {
    final previous = SpeechUtilsPlatform.instance;
    addTearDown(() => SpeechUtilsPlatform.instance = previous);

    SpeechUtilsMacos.registerWith();

    expect(SpeechUtilsPlatform.instance, isA<SpeechUtilsMacos>());
    expect(
      SpeechUtilsPlatform.instance.platform,
      NativeAudioRecorderPlatform.macOS,
    );
  });

  test('loads the native recorder asset and calls permission status', () async {
    final platform = SpeechUtilsMacos();
    expect(await platform.hasPermission(), isA<bool>());
  });
}
