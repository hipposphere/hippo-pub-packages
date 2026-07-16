import 'package:flutter_test/flutter_test.dart';
import 'package:hid_api_platform_interface/hid_api_platform_interface.dart';
import 'package:hid_api_windows/hid_api_windows.dart';

void main() {
  test('registers the Windows implementation', () {
    final previous = HidApiPlatform.instance;
    addTearDown(() => HidApiPlatform.instance = previous);

    HidApiWindows.registerWith();

    expect(HidApiPlatform.instance, isA<HidApiWindows>());
  });
}
