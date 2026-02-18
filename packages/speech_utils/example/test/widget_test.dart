import 'package:flutter_test/flutter_test.dart';
import 'package:speech_utils_example/main.dart';

void main() {
  testWidgets('renders speech utils example controls', (tester) async {
    await tester.pumpWidget(
      const SpeechUtilsExampleApp(detectAacOnStartup: false),
    );

    expect(find.text('speech_utils Example'), findsOneWidget);
    expect(find.text('Idle'), findsOneWidget);
  });
}
