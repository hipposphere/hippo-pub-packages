import 'src/ffi/desktop_autopaste_ffi.dart';
import 'src/focused_text_edit_operation.dart';
import 'src/focused_text_field_context.dart';
import 'src/paste_shortcut.dart';

export 'src/focused_text_field_context.dart';
export 'src/focused_text_edit_operation.dart';
export 'src/paste_shortcut.dart';

class DesktopAutopaste {
  Future<bool> pasteIntoCursorViaClipboard(
    String text, {
    Duration prePasteDelay = Duration.zero,
    DesktopAutopastePasteShortcut pasteShortcut =
        DesktopAutopastePasteShortcut.shiftInsert,
  }) {
    return DesktopAutopasteFfi.instance.pasteIntoCursorViaClipboard(
      text,
      prePasteDelay: prePasteDelay,
      pasteShortcut: pasteShortcut,
    );
  }

  Future<FocusedTextFieldContext> getFocusedTextFieldContext({
    int? maxCharsBefore = 120,
    int? maxCharsAfter = 120,
    bool enableScreenReader = false,
  }) {
    return DesktopAutopasteFfi.instance.getFocusedTextFieldContext(
      maxCharsBefore: maxCharsBefore,
      maxCharsAfter: maxCharsAfter,
      enableScreenReader: enableScreenReader,
    );
  }

  Future<bool> editFocusedTextField(List<FocusedTextEditOperation> operations) {
    return DesktopAutopasteFfi.instance.editFocusedTextField(operations);
  }

  Future<bool> replaceRangeInFocusedTextField({
    required int start,
    required int end,
    required String replacement,
  }) {
    return editFocusedTextField(<FocusedTextEditOperation>[
      FocusedTextEditOperation.replaceRange(
        start: start,
        end: end,
        replacement: replacement,
      ),
    ]);
  }

  Future<bool> insertAtInFocusedTextField({
    required int offset,
    required String text,
  }) {
    return editFocusedTextField(<FocusedTextEditOperation>[
      FocusedTextEditOperation.insert(offset: offset, text: text),
    ]);
  }
}
