import 'package:flutter_test/flutter_test.dart';
import 'package:speech_utils_linux/speech_utils_linux.dart';
import 'package:speech_utils_platform_interface/speech_utils_platform_interface.dart';

void main() {
  test('registers the Linux implementation', () {
    final previous = SpeechUtilsPlatform.instance;
    addTearDown(() => SpeechUtilsPlatform.instance = previous);
    SpeechUtilsLinux.registerWith();
    expect(SpeechUtilsPlatform.instance, isA<SpeechUtilsLinux>());
    expect(
      SpeechUtilsPlatform.instance.platform,
      NativeAudioRecorderPlatform.linux,
    );
  });
}
