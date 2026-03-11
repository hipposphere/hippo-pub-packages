import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:objective_c/objective_c.dart' as objc;

import '../focused_text_edit_operation.dart';
import '../focused_text_field_context.dart';
import '../paste_shortcut.dart';
import 'desktop_autopaste_client.dart';
import 'generated/desktop_autopaste_bindings.dart' as bindings;
import 'generated/desktop_autopaste_macos_swiftgen_bindings.dart'
    as macos_swiftgen;

const _errorBufferBytes = 2048;
const _contextBufferBytes = 65536;

final class NativeFfiDesktopAutopasteClient implements DesktopAutopasteClient {
  const NativeFfiDesktopAutopasteClient();

  @override
  Future<bool> pasteIntoCursorViaClipboard(
    String text, {
    required Duration prePasteDelay,
    required DesktopAutopastePasteShortcut pasteShortcut,
  }) async {
    if (Platform.isMacOS) {
      final swiftgenResult = _tryPasteViaMacosSwiftgen(text);
      if (swiftgenResult != null) {
        return swiftgenResult;
      }
    }

    final textPtr = text.toNativeUtf8(allocator: calloc).cast<ffi.Char>();
    final errorPtr = calloc<ffi.Char>(_errorBufferBytes);

    try {
      final prePasteDelayMs = prePasteDelay.isNegative
          ? 0
          : prePasteDelay.inMilliseconds;
      final code = bindings.desktop_autopaste_paste_into_cursor_via_clipboard(
        textPtr,
        prePasteDelayMs,
        pasteShortcut.index,
        errorPtr,
        _errorBufferBytes,
      );
      return code == 0;
    } finally {
      calloc.free(textPtr);
      calloc.free(errorPtr);
    }
  }

  bool? _tryPasteViaMacosSwiftgen(String text) {
    try {
      return objc.autoReleasePool(() {
        final nsString = text.toNSString();
        return macos_swiftgen
            .DesktopAutopasteMacosBridge.pasteIntoCursorViaClipboard(nsString);
      });
    } on Object {
      return null;
    }
  }

  @override
  Future<FocusedTextFieldContext> getFocusedTextFieldContext({
    int? maxCharsBefore,
    int? maxCharsAfter,
    required bool enableScreenReader,
  }) async {
    final contextPtr = calloc<ffi.Char>(_contextBufferBytes);
    final errorPtr = calloc<ffi.Char>(_errorBufferBytes);

    try {
      final maxBefore = maxCharsBefore ?? -1;
      final maxAfter = maxCharsAfter ?? -1;
      final code = bindings
          .desktop_autopaste_get_focused_text_field_context_json(
            maxBefore,
            maxAfter,
            enableScreenReader ? 1 : 0,
            contextPtr,
            _contextBufferBytes,
            errorPtr,
            _errorBufferBytes,
          );
      if (code != 0) {
        final reason = errorPtr.cast<Utf8>().toDartString();
        return FocusedTextFieldContext(
          available: false,
          reason: reason.isEmpty ? 'ffiError' : reason,
        );
      }

      final jsonValue = contextPtr.cast<Utf8>().toDartString();
      if (jsonValue.isEmpty) {
        return const FocusedTextFieldContext(
          available: false,
          reason: 'emptyContext',
        );
      }

      final decoded = jsonDecode(jsonValue);
      if (decoded is Map<String, dynamic>) {
        return FocusedTextFieldContext.fromMap(decoded);
      }
      if (decoded is Map) {
        return FocusedTextFieldContext.fromMap(decoded.cast<String, dynamic>());
      }
      return const FocusedTextFieldContext(
        available: false,
        reason: 'invalidContextJson',
      );
    } on FormatException {
      return const FocusedTextFieldContext(
        available: false,
        reason: 'invalidContextJson',
      );
    } finally {
      calloc.free(contextPtr);
      calloc.free(errorPtr);
    }
  }

  @override
  Future<bool> editFocusedTextField(
    List<FocusedTextEditOperation> operations,
  ) async {
    if (operations.isEmpty) {
      return false;
    }

    final opPtr = calloc<bindings.desktop_autopaste_text_edit_operation_t>(
      operations.length,
    );
    final replacementPointers = <ffi.Pointer<ffi.Char>>[];
    final errorPtr = calloc<ffi.Char>(_errorBufferBytes);

    try {
      for (var i = 0; i < operations.length; i++) {
        final operation = operations[i];
        final replacementPtr = operation.replacement
            .toNativeUtf8(allocator: calloc)
            .cast<ffi.Char>();
        replacementPointers.add(replacementPtr);

        final nativeOp = (opPtr + i).ref;
        nativeOp.start = operation.start;
        nativeOp.end = operation.end;
        nativeOp.replacement_utf8 = replacementPtr;
      }

      final code = bindings.desktop_autopaste_edit_focused_text_field(
        opPtr,
        operations.length,
        errorPtr,
        _errorBufferBytes,
      );
      return code == 0;
    } finally {
      for (final pointer in replacementPointers) {
        calloc.free(pointer);
      }
      calloc.free(opPtr);
      calloc.free(errorPtr);
    }
  }
}
