import 'package:flutter_test/flutter_test.dart';
import 'package:hid_api_linux/hid_api_linux.dart';
import 'package:hid_api_platform_interface/hid_api_platform_interface.dart';

void main() {
  test('registers the Linux implementation', () {
    final previous = HidApiPlatform.instance;
    addTearDown(() => HidApiPlatform.instance = previous);

    HidApiLinux.registerWith();

    expect(HidApiPlatform.instance, isA<HidApiLinux>());
  });
}
