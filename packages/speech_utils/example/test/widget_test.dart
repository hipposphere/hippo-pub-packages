import 'package:flutter_test/flutter_test.dart';
import 'package:speech_utils_example/main.dart';

void main() {
  testWidgets('renders speech utils example controls', (tester) async {
    await tester.pumpWidget(const SpeechUtilsExampleApp());

    expect(find.text('speech_utils Example'), findsOneWidget);
    expect(find.text('Integrated VAD + Compression'), findsOneWidget);
    expect(find.text('Simple Recorder + Waveform'), findsOneWidget);
  });
}
