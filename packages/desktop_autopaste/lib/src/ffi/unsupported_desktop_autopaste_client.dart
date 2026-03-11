import '../focused_text_edit_operation.dart';
import '../focused_text_field_context.dart';
import '../paste_shortcut.dart';
import 'desktop_autopaste_client.dart';

final class UnsupportedDesktopAutopasteClient
    implements DesktopAutopasteClient {
  const UnsupportedDesktopAutopasteClient({required this.reason});

  final String reason;

  @override
  Future<bool> pasteIntoCursorViaClipboard(
    String text, {
    required Duration prePasteDelay,
    required DesktopAutopastePasteShortcut pasteShortcut,
  }) async => false;

  @override
  Future<FocusedTextFieldContext> getFocusedTextFieldContext({
    int? maxCharsBefore,
    int? maxCharsAfter,
    required bool enableScreenReader,
  }) async {
    return FocusedTextFieldContext(available: false, reason: reason);
  }

  @override
  Future<bool> editFocusedTextField(
    List<FocusedTextEditOperation> operations,
  ) async => false;
}
