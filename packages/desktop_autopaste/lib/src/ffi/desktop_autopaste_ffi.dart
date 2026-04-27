import 'dart:io';

import '../focused_text_edit_operation.dart';
import '../focused_text_field_context.dart';
import '../paste_shortcut.dart';
import 'desktop_autopaste_client.dart';
import 'native_ffi_desktop_autopaste_client.dart';
import 'unsupported_desktop_autopaste_client.dart';

final class DesktopAutopasteFfi {
  DesktopAutopasteFfi._();

  static final DesktopAutopasteFfi instance = DesktopAutopasteFfi._();

  late final DesktopAutopasteClient _client = _createClient();

  Future<bool> pasteIntoCursorViaClipboard(
    String text, {
    Duration prePasteDelay = Duration.zero,
    DesktopAutopastePasteShortcut pasteShortcut =
        DesktopAutopastePasteShortcut.ctrlV,
  }) {
    return _client.pasteIntoCursorViaClipboard(
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
    return _client.getFocusedTextFieldContext(
      maxCharsBefore: maxCharsBefore,
      maxCharsAfter: maxCharsAfter,
      enableScreenReader: enableScreenReader,
    );
  }

  Future<bool> editFocusedTextField(List<FocusedTextEditOperation> operations) {
    return _client.editFocusedTextField(operations);
  }

  DesktopAutopasteClient _createClient() {
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      return const NativeFfiDesktopAutopasteClient();
    }

    return const UnsupportedDesktopAutopasteClient(
      reason: 'unsupportedPlatform',
    );
  }
}
