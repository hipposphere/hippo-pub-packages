import 'package:flutter_test/flutter_test.dart';
import 'package:hid_api_platform_interface/hid_api_method_channel.dart';
import 'package:hid_api_platform_interface/hid_api_platform_interface.dart';

void main() {
  test('uses the shared method-channel adapter by default', () {
    expect(HidApiPlatform.instance, isA<MethodChannelHidApi>());
  });
}
