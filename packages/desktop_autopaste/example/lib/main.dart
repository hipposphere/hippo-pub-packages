import 'package:desktop_autopaste/desktop_autopaste.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:hippo_utils/hippo_utils.dart';
import 'package:hotkey_api/hotkey_api.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final bloc = AutopasteBloc();
  runApp(
    MultiBlocProvider(
      blocDefiners: [BlocDefiner<AutopasteBloc>(bloc: bloc)],
      child: App(
        brightness: Brightness.light,
        title: 'Desktop Autopaste Example',
        home: _HomePage(),
      ),
    ),
  );
}

enum PasteMode { pasteIntoCursor, pasteIntoCursorViaClipboard }

class AutopasteBloc extends BlocBase {
  final hotkeyController = HotkeyStatusController(
    initialHotkey: Hotkey.single(PhysicalKeyboardKey.metaRight),
  );

  final modeSubject = DataSubject<PasteMode>.seeded(
    PasteMode.pasteIntoCursorViaClipboard,
  );

  AutopasteBloc() {
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

  static AutopasteBloc of(BuildContext context) {
    return BlocProvider.of<AutopasteBloc>(context);
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    return PageContainer(
      title: 'Desktop Autopaste Example',
      backAction: null,
      body: CustomScrollView(
        slivers: [
          SliverGap(16),
          SliverColumn(children: [TextField()]),
          SliverGap(16),
        ],
      ),
    );
  }
}
