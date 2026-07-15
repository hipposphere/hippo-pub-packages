import 'package:desktop_autopaste_macos/desktop_autopaste_macos.dart';
import 'package:desktop_autopaste_platform_interface/desktop_autopaste_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registers the macOS implementation', () {
    final previous = DesktopAutopastePlatform.instance;
    addTearDown(() => DesktopAutopastePlatform.instance = previous);

    DesktopAutopasteMacos.registerWith();

    expect(DesktopAutopastePlatform.instance, isA<DesktopAutopasteMacos>());
  });
}
