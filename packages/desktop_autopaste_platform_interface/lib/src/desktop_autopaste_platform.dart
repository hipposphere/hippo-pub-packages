import 'focused_text_edit_operation.dart';
import 'focused_text_field_context.dart';
import 'paste_shortcut.dart';

/// Native behavior supplied by an endorsed desktop implementation.
abstract class DesktopAutopastePlatform {
  const DesktopAutopastePlatform();

  static DesktopAutopastePlatform instance =
      const UnsupportedDesktopAutopastePlatform();

  Future<bool> pasteIntoCursorViaClipboard(
    String text, {
    required Duration prePasteDelay,
    required DesktopAutopastePasteShortcut pasteShortcut,
  });

  Future<bool> pasteFromClipboard({
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

/// Safe fallback used until a supported desktop implementation registers.
final class UnsupportedDesktopAutopastePlatform
    extends DesktopAutopastePlatform {
  const UnsupportedDesktopAutopastePlatform({
    this.reason = 'unsupportedPlatform',
  });

  final String reason;

  @override
  Future<bool> pasteIntoCursorViaClipboard(
    String text, {
    required Duration prePasteDelay,
    required DesktopAutopastePasteShortcut pasteShortcut,
  }) async => false;

  @override
  Future<bool> pasteFromClipboard({
    required Duration prePasteDelay,
    required DesktopAutopastePasteShortcut pasteShortcut,
  }) async => false;

  @override
  Future<FocusedTextFieldContext> getFocusedTextFieldContext({
    int? maxCharsBefore,
    int? maxCharsAfter,
    required bool enableScreenReader,
  }) async => FocusedTextFieldContext(available: false, reason: reason);

  @override
  Future<bool> editFocusedTextField(
    List<FocusedTextEditOperation> operations,
  ) async => false;
}
