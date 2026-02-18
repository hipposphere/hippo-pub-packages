import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'desktop_autopaste_platform_interface.dart';
import 'src/focused_text_edit_operation.dart';
import 'src/focused_text_field_context.dart';

/// An implementation of [DesktopAutopastePlatform] that uses method channels.
class MethodChannelDesktopAutopaste extends DesktopAutopastePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('desktop_autopaste');

  @override
  Future<bool> pasteIntoCursorViaClipboard(String text) async {
    final result = await methodChannel.invokeMethod<bool>(
      'pasteIntoCursorViaClipboard',
      {'text': text},
    );
    return result ?? false;
  }

  @override
  Future<FocusedTextFieldContext> getFocusedTextFieldContext({
    int? maxCharsBefore = 120,
    int? maxCharsAfter = 120,
    bool enableScreenReader = false,
  }) async {
    final result =
        await methodChannel.invokeMapMethod<String, dynamic>(
          'getFocusedTextFieldContext',
          <String, dynamic>{
            'maxCharsBefore': maxCharsBefore,
            'maxCharsAfter': maxCharsAfter,
            'enableScreenReader': enableScreenReader,
          },
        ) ??
        const <String, dynamic>{'available': false, 'reason': 'noResult'};

    return FocusedTextFieldContext.fromMap(result);
  }

  @override
  Future<bool> editFocusedTextField(
    List<FocusedTextEditOperation> operations,
  ) async {
    final result = await methodChannel.invokeMethod<bool>(
      'editFocusedTextField',
      <String, dynamic>{
        'operations': operations.map((operation) => operation.toMap()).toList(),
      },
    );
    return result ?? false;
  }
}
