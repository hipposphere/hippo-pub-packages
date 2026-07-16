import 'package:flutter_test/flutter_test.dart';
import 'package:hid_api_macos/hid_api_macos.dart';
import 'package:hid_api_platform_interface/hid_api_platform_interface.dart';

void main() {
  test('registers the macOS implementation', () {
    final previous = HidApiPlatform.instance;
    addTearDown(() => HidApiPlatform.instance = previous);

    HidApiMacos.registerWith();

    expect(HidApiPlatform.instance, isA<HidApiMacos>());
  });
}
