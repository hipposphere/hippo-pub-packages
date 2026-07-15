import 'package:desktop_autopaste_platform_interface/desktop_autopaste_platform_interface.dart';
import 'package:desktop_autopaste_windows/desktop_autopaste_windows.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registers the Windows implementation', () {
    final previous = DesktopAutopastePlatform.instance;
    addTearDown(() => DesktopAutopastePlatform.instance = previous);

    DesktopAutopasteWindows.registerWith();

    expect(DesktopAutopastePlatform.instance, isA<DesktopAutopasteWindows>());
  });
}
