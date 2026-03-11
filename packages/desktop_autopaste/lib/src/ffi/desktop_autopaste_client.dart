import '../focused_text_edit_operation.dart';
import '../focused_text_field_context.dart';
import '../paste_shortcut.dart';

abstract interface class DesktopAutopasteClient {
  Future<bool> pasteIntoCursorViaClipboard(
    String text, {
    required Duration prePasteDelay,
    required DesktopAutopastePasteShortcut pasteShortcut,
  });

  Future<FocusedTextFieldContext> getFocusedTextFieldContext({
    int? maxCharsBefore,
    int? maxCharsAfter,
    required bool enableScreenReader,
  });

  Future<bool> editFocusedTextField(List<FocusedTextEditOperation> operations);
}
