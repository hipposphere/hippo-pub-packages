import 'desktop_autopaste_platform_interface.dart';

class DesktopAutopaste {
  Future<bool> pasteIntoCursor(String text) {
    return DesktopAutopastePlatform.instance.pasteIntoCursor(text);
  }

  Future<bool> pasteIntoCursorViaClipboard(String text) {
    return DesktopAutopastePlatform.instance.pasteIntoCursorViaClipboard(text);
  }
}
