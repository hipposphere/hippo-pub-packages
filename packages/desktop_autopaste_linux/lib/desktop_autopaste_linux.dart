import 'dart:ffi' as ffi;

import 'package:desktop_autopaste_platform_interface/desktop_autopaste_platform_ffi.dart';
import 'package:desktop_autopaste_platform_interface/desktop_autopaste_platform_interface.dart';

import 'src/generated/desktop_autopaste_linux_bindings.dart' as bindings;

final class DesktopAutopasteLinux extends FfiDesktopAutopastePlatform {
  DesktopAutopasteLinux()
    : super(
        bindings.desktop_autopaste_paste_into_cursor_via_clipboard,
        bindings.desktop_autopaste_paste_from_clipboard,
        bindings.desktop_autopaste_get_focused_text_field_context_json,
        _editFocusedTextField,
      );

  static void registerWith() {
    DesktopAutopastePlatform.instance = DesktopAutopasteLinux();
  }
}

int _editFocusedTextField(
  ffi.Pointer<DesktopAutopasteTextEditOperation> operations,
  int operationCount,
  ffi.Pointer<ffi.Char> errorUtf8,
  int errorUtf8Capacity,
) {
  return bindings.desktop_autopaste_edit_focused_text_field(
    operations.cast<bindings.desktop_autopaste_text_edit_operation_t>(),
    operationCount,
    errorUtf8,
    errorUtf8Capacity,
  );
}
