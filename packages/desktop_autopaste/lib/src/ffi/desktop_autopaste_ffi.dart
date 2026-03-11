import 'dart:io';

import '../focused_text_edit_operation.dart';
import '../focused_text_field_context.dart';
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
  }) {
    return _client.pasteIntoCursorViaClipboard(
      text,
      prePasteDelay: prePasteDelay,
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
    if (Platform.isWindows || Platform.isMacOS) {
      return const NativeFfiDesktopAutopasteClient();
    }

    if (Platform.isLinux) {
      return const UnsupportedDesktopAutopasteClient(
        reason: 'unsupportedOnLinux',
      );
    }

    return const UnsupportedDesktopAutopasteClient(
      reason: 'unsupportedPlatform',
    );
  }
}
