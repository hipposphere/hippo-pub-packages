import 'desktop_autopaste_platform_interface.dart';
import 'src/focused_text_edit_operation.dart';
import 'src/focused_text_field_context.dart';

export 'src/focused_text_field_context.dart';
export 'src/focused_text_edit_operation.dart';

class DesktopAutopaste {
  Future<bool> pasteIntoCursorViaClipboard(String text) {
    return DesktopAutopastePlatform.instance.pasteIntoCursorViaClipboard(text);
  }

  Future<FocusedTextFieldContext> getFocusedTextFieldContext({
    int? maxCharsBefore = 120,
    int? maxCharsAfter = 120,
    bool enableScreenReader = false,
  }) {
    return DesktopAutopastePlatform.instance.getFocusedTextFieldContext(
      maxCharsBefore: maxCharsBefore,
      maxCharsAfter: maxCharsAfter,
      enableScreenReader: enableScreenReader,
    );
  }

  Future<bool> editFocusedTextField(List<FocusedTextEditOperation> operations) {
    return DesktopAutopastePlatform.instance.editFocusedTextField(operations);
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
