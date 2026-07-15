import 'package:flutter_test/flutter_test.dart';
import 'package:speech_utils_android/speech_utils_android.dart';
import 'package:speech_utils_platform_interface/speech_utils_platform_interface.dart';

void main() {
  test('registers the Android implementation and providers', () {
    final previous = SpeechUtilsPlatform.instance;
    addTearDown(() => SpeechUtilsPlatform.instance = previous);

    SpeechUtilsAndroid.registerWith();

    final implementation = SpeechUtilsPlatform.instance;
    expect(implementation, isA<SpeechUtilsAndroid>());
    expect(implementation.platform, NativeAudioRecorderPlatform.android);
    expect(implementation.aacEncoder, isNotNull);
    expect(implementation.metadataReader, isNotNull);
  });
}
