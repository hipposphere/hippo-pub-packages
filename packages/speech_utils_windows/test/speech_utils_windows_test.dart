import 'package:flutter_test/flutter_test.dart';
import 'package:speech_utils_platform_interface/speech_utils_platform_interface.dart';
import 'package:speech_utils_windows/speech_utils_windows.dart';

void main() {
  test('registers the Windows implementation', () {
    final previous = SpeechUtilsPlatform.instance;
    addTearDown(() => SpeechUtilsPlatform.instance = previous);
    SpeechUtilsWindows.registerWith();
    expect(SpeechUtilsPlatform.instance, isA<SpeechUtilsWindows>());
    expect(
      SpeechUtilsPlatform.instance.platform,
      NativeAudioRecorderPlatform.windows,
    );
  });
}
