import 'package:desktop_autopaste_platform_interface/desktop_autopaste_platform_interface.dart';

export 'package:desktop_autopaste_platform_interface/desktop_autopaste_platform_interface.dart'
    show
        DesktopAutopastePasteShortcut,
        FocusedTextEditOperation,
        FocusedTextFieldContext;

class DesktopAutopaste {
  Future<bool> pasteIntoCursorViaClipboard(
    String text, {
    Duration prePasteDelay = Duration.zero,
    DesktopAutopastePasteShortcut pasteShortcut =
        DesktopAutopastePasteShortcut.ctrlV,
  }) {
    return DesktopAutopastePlatform.instance.pasteIntoCursorViaClipboard(
      text,
      prePasteDelay: prePasteDelay,
      pasteShortcut: pasteShortcut,
    );
  }

  Future<bool> pasteFromClipboard({
    Duration prePasteDelay = Duration.zero,
    DesktopAutopastePasteShortcut pasteShortcut =
        DesktopAutopastePasteShortcut.ctrlV,
  }) {
    return DesktopAutopastePlatform.instance.pasteFromClipboard(
      prePasteDelay: prePasteDelay,
      pasteShortcut: pasteShortcut,
    );
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
