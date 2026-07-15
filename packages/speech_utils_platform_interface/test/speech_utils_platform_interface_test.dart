import 'package:speech_utils_platform_interface/speech_utils_platform_interface.dart';
import 'package:test/test.dart';

void main() {
  test('starts with an explicit unsupported implementation', () {
    expect(SpeechUtilsPlatform.instance, isA<UnsupportedSpeechUtilsPlatform>());
    expect(SpeechUtilsPlatform.instance.isAvailable(), isFalse);
    expect(
      SpeechUtilsPlatform.instance.platform,
      NativeAudioRecorderPlatform.unsupported,
    );
  });
}
