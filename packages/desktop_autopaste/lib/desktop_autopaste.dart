import 'desktop_autopaste_platform_interface.dart';
import 'src/focused_text_field_context.dart';

export 'src/focused_text_field_context.dart';

class DesktopAutopaste {
  Future<bool> pasteIntoCursor(String text) {
    return DesktopAutopastePlatform.instance.pasteIntoCursor(text);
  }

  Future<bool> pasteIntoCursorViaClipboard(String text) {
    return DesktopAutopastePlatform.instance.pasteIntoCursorViaClipboard(text);
  }

  Future<FocusedTextFieldContext> getFocusedTextFieldContext({
    int maxCharsBefore = 120,
    int maxCharsAfter = 120,
  }) {
    return DesktopAutopastePlatform.instance.getFocusedTextFieldContext(
      maxCharsBefore: maxCharsBefore,
      maxCharsAfter: maxCharsAfter,
    );
  }
}
