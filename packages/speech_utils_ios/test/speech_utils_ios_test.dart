import 'package:flutter_test/flutter_test.dart';
import 'package:speech_utils_ios/speech_utils_ios.dart';
import 'package:speech_utils_platform_interface/speech_utils_platform_interface.dart';

void main() {
  test('registers the iOS implementation', () {
    final previous = SpeechUtilsPlatform.instance;
    addTearDown(() => SpeechUtilsPlatform.instance = previous);
    SpeechUtilsIos.registerWith();
    expect(SpeechUtilsPlatform.instance, isA<SpeechUtilsIos>());
    expect(
      SpeechUtilsPlatform.instance.platform,
      NativeAudioRecorderPlatform.iOS,
    );
  });
}
