import 'dart:convert';
import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart';

import 'desktop_autopaste_platform_interface.dart';

const _errorBufferBytes = 2048;
const _contextBufferBytes = 65536;

typedef NativePasteIntoCursorViaClipboard =
    int Function(
      ffi.Pointer<ffi.Char> textUtf8,
      int prePasteDelayMs,
      int pasteShortcut,
      ffi.Pointer<ffi.Char> errorUtf8,
      int errorUtf8Capacity,
    );

typedef NativePasteFromClipboard =
    int Function(
      int prePasteDelayMs,
      int pasteShortcut,
      ffi.Pointer<ffi.Char> errorUtf8,
      int errorUtf8Capacity,
    );

typedef NativeGetFocusedTextFieldContext =
    int Function(
      int maxCharsBefore,
      int maxCharsAfter,
      int enableScreenReader,
      ffi.Pointer<ffi.Char> contextJsonUtf8,
      int contextJsonUtf8Capacity,
      ffi.Pointer<ffi.Char> errorUtf8,
      int errorUtf8Capacity,
    );

typedef NativeEditFocusedTextField =
    int Function(
      ffi.Pointer<DesktopAutopasteTextEditOperation> operations,
      int operationCount,
      ffi.Pointer<ffi.Char> errorUtf8,
      int errorUtf8Capacity,
    );

final class DesktopAutopasteTextEditOperation extends ffi.Struct {
  @ffi.Int32()
  external int start;

  @ffi.Int32()
  external int end;

  external ffi.Pointer<ffi.Char> replacementUtf8;
}

/// Shared FFI marshalling used by the endorsed native packages.
///
/// Platform packages still own their generated bindings, native assets, and
/// registration. This adapter keeps their Dart-side behavior consistent.
abstract class FfiDesktopAutopastePlatform extends DesktopAutopastePlatform {
  FfiDesktopAutopastePlatform(
    this._pasteIntoCursorViaClipboard,
    this._pasteFromClipboard,
    this._getFocusedTextFieldContext,
    this._editFocusedTextField,
  );

  final NativePasteIntoCursorViaClipboard _pasteIntoCursorViaClipboard;
  final NativePasteFromClipboard _pasteFromClipboard;
  final NativeGetFocusedTextFieldContext _getFocusedTextFieldContext;
  final NativeEditFocusedTextField _editFocusedTextField;

  /// Allows a platform package to use a direct native bridge before FFI.
  /// Return `null` to continue through the standard C ABI.
  bool? tryPasteViaPlatformBridge(String text) => null;

  @override
  Future<bool> pasteIntoCursorViaClipboard(
    String text, {
    required Duration prePasteDelay,
    required DesktopAutopastePasteShortcut pasteShortcut,
  }) async {
    final platformResult = tryPasteViaPlatformBridge(text);
    if (platformResult != null) {
      return platformResult;
    }

    final textPointer = text.toNativeUtf8(allocator: calloc).cast<ffi.Char>();
    final errorPointer = calloc<ffi.Char>(_errorBufferBytes);
    try {
      return _pasteIntoCursorViaClipboard(
            textPointer,
            _delayMilliseconds(prePasteDelay),
            pasteShortcut.index,
            errorPointer,
            _errorBufferBytes,
          ) ==
          0;
    } finally {
      calloc
        ..free(textPointer)
        ..free(errorPointer);
    }
  }

  @override
  Future<bool> pasteFromClipboard({
    required Duration prePasteDelay,
    required DesktopAutopastePasteShortcut pasteShortcut,
  }) async {
    final errorPointer = calloc<ffi.Char>(_errorBufferBytes);
    try {
      return _pasteFromClipboard(
            _delayMilliseconds(prePasteDelay),
            pasteShortcut.index,
            errorPointer,
            _errorBufferBytes,
          ) ==
          0;
    } finally {
      calloc.free(errorPointer);
    }
  }

  @override
  Future<FocusedTextFieldContext> getFocusedTextFieldContext({
    int? maxCharsBefore,
    int? maxCharsAfter,
    required bool enableScreenReader,
  }) async {
    final contextPointer = calloc<ffi.Char>(_contextBufferBytes);
    final errorPointer = calloc<ffi.Char>(_errorBufferBytes);
    try {
      final code = _getFocusedTextFieldContext(
        maxCharsBefore ?? -1,
        maxCharsAfter ?? -1,
        enableScreenReader ? 1 : 0,
        contextPointer,
        _contextBufferBytes,
        errorPointer,
        _errorBufferBytes,
      );
      if (code != 0) {
        final reason = errorPointer.cast<Utf8>().toDartString();
        return FocusedTextFieldContext(
          available: false,
          reason: reason.isEmpty ? 'ffiError' : reason,
        );
      }

      final jsonValue = contextPointer.cast<Utf8>().toDartString();
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
      calloc
        ..free(contextPointer)
        ..free(errorPointer);
    }
  }

  @override
  Future<bool> editFocusedTextField(
    List<FocusedTextEditOperation> operations,
  ) async {
    if (operations.isEmpty) {
      return false;
    }

    final operationPointer = calloc<DesktopAutopasteTextEditOperation>(
      operations.length,
    );
    final replacementPointers = <ffi.Pointer<ffi.Char>>[];
    final errorPointer = calloc<ffi.Char>(_errorBufferBytes);
    try {
      for (var index = 0; index < operations.length; index++) {
        final operation = operations[index];
        final replacementPointer = operation.replacement
            .toNativeUtf8(allocator: calloc)
            .cast<ffi.Char>();
        replacementPointers.add(replacementPointer);

        final nativeOperation = (operationPointer + index).ref;
        nativeOperation.start = operation.start;
        nativeOperation.end = operation.end;
        nativeOperation.replacementUtf8 = replacementPointer;
      }

      return _editFocusedTextField(
            operationPointer,
            operations.length,
            errorPointer,
            _errorBufferBytes,
          ) ==
          0;
    } finally {
      for (final pointer in replacementPointers) {
        calloc.free(pointer);
      }
      calloc
        ..free(operationPointer)
        ..free(errorPointer);
    }
  }
}

int _delayMilliseconds(Duration delay) =>
    delay.isNegative ? 0 : delay.inMilliseconds;
