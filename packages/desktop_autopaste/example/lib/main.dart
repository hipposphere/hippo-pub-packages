import 'package:desktop_autopaste/desktop_autopaste.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:hippo_utils/hippo_utils.dart';
import 'package:hotkey_api/hotkey_api.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final bloc = Bloc();
  runApp(
    MultiBlocProvider(
      blocDefiners: [BlocDefiner<Bloc>(bloc: bloc)],
      child: App(
        brightness: Brightness.light,
        title: 'Desktop Autopaste Example',
        home: _HomePage(),
      ),
    ),
  );
}

enum PasteMode { pasteIntoCursor, pasteIntoCursorViaClipboard }

class Bloc extends BlocBase {
  final hotkeyController = HotkeyStatusController(
    initialHotkey: Hotkey.single(PhysicalKeyboardKey.altRight),
  );

  final modeSubject = DataSubject<PasteMode>.seeded(
    PasteMode.pasteIntoCursorViaClipboard,
  );

  Bloc() {
    hotkeyController.streamHotkeyStatusType().listen((event) {
      if (event == HotkeyStatusType.pressed) {
        final text = 'Autopaste at ${DateTime.now()}';
        switch (modeSubject.value) {
          case PasteMode.pasteIntoCursor:
            DesktopAutopaste().pasteIntoCursor(text);
          case PasteMode.pasteIntoCursorViaClipboard:
            DesktopAutopaste().pasteIntoCursorViaClipboard(text);
        }
      }
    });
  }

  @override
  void dispose() {}

  static Bloc of(BuildContext context) {
    return BlocProvider.of<Bloc>(context);
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    return PageContainer(
      title: 'Desktop Autopaste Example',
      backAction: null,
      body: Placeholder(),
    );
  }
}
