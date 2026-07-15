import 'package:desktop_autopaste_platform_interface/desktop_autopaste_platform_interface.dart';
import 'package:test/test.dart';

void main() {
  test('starts with a safe unsupported implementation', () async {
    final platform = DesktopAutopastePlatform.instance;

    expect(platform, isA<UnsupportedDesktopAutopastePlatform>());
    expect(
      await platform.pasteIntoCursorViaClipboard(
        'text',
        prePasteDelay: Duration.zero,
        pasteShortcut: DesktopAutopastePasteShortcut.ctrlV,
      ),
      isFalse,
    );
    expect(
      await platform.getFocusedTextFieldContext(enableScreenReader: false),
      isA<FocusedTextFieldContext>()
          .having((context) => context.available, 'available', isFalse)
          .having((context) => context.reason, 'reason', 'unsupportedPlatform'),
    );
  });
}
