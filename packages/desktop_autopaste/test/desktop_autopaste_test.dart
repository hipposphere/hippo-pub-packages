import 'package:desktop_autopaste/desktop_autopaste.dart';
import 'package:desktop_autopaste_platform_interface/desktop_autopaste_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late DesktopAutopastePlatform previousPlatform;
  late _RecordingPlatform platform;

  setUp(() {
    previousPlatform = DesktopAutopastePlatform.instance;
    platform = _RecordingPlatform();
    DesktopAutopastePlatform.instance = platform;
  });

  tearDown(() {
    DesktopAutopastePlatform.instance = previousPlatform;
  });

  test('delegates app-facing calls to the registered implementation', () async {
    final autopaste = DesktopAutopaste();
    const delay = Duration(milliseconds: 25);

    expect(
      await autopaste.pasteIntoCursorViaClipboard(
        'hello',
        prePasteDelay: delay,
        pasteShortcut: DesktopAutopastePasteShortcut.shiftInsert,
      ),
      isTrue,
    );
    expect(platform.text, 'hello');
    expect(platform.prePasteDelay, delay);
    expect(platform.pasteShortcut, DesktopAutopastePasteShortcut.shiftInsert);

    expect(
      await autopaste.replaceRangeInFocusedTextField(
        start: 2,
        end: 4,
        replacement: 'x',
      ),
      isTrue,
    );
    expect(platform.operations, hasLength(1));
    expect(platform.operations.single.toMap(), {
      'start': 2,
      'end': 4,
      'replacement': 'x',
    });
  });
}

final class _RecordingPlatform extends DesktopAutopastePlatform {
  String? text;
  Duration? prePasteDelay;
  DesktopAutopastePasteShortcut? pasteShortcut;
  List<FocusedTextEditOperation> operations = const [];

  @override
  Future<bool> pasteIntoCursorViaClipboard(
    String text, {
    required Duration prePasteDelay,
    required DesktopAutopastePasteShortcut pasteShortcut,
  }) async {
    this.text = text;
    this.prePasteDelay = prePasteDelay;
    this.pasteShortcut = pasteShortcut;
    return true;
  }

  @override
  Future<bool> pasteFromClipboard({
    required Duration prePasteDelay,
    required DesktopAutopastePasteShortcut pasteShortcut,
  }) async => true;

  @override
  Future<FocusedTextFieldContext> getFocusedTextFieldContext({
    int? maxCharsBefore,
    int? maxCharsAfter,
    required bool enableScreenReader,
  }) async => const FocusedTextFieldContext(available: true);

  @override
  Future<bool> editFocusedTextField(
    List<FocusedTextEditOperation> operations,
  ) async {
    this.operations = operations;
    return true;
  }
}
