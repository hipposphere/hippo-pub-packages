import 'package:desktop_autopaste_linux/desktop_autopaste_linux.dart';
import 'package:desktop_autopaste_platform_interface/desktop_autopaste_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registers the Linux implementation', () {
    final previous = DesktopAutopastePlatform.instance;
    addTearDown(() => DesktopAutopastePlatform.instance = previous);

    DesktopAutopasteLinux.registerWith();

    expect(DesktopAutopastePlatform.instance, isA<DesktopAutopasteLinux>());
  });
}
