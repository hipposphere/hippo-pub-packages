import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:desktop_permissions/desktop_permissions_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelDesktopPermissions platform = MethodChannelDesktopPermissions();
  const MethodChannel channel = MethodChannel('desktop_permissions');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'isAccessibilityGranted':
              return true;
            case 'getAccessibilityStatus':
              return 'granted';
            case 'isInputMonitoringGranted':
              return true;
            case 'getInputMonitoringStatus':
              return 'granted';
            default:
              return null;
          }
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('isAccessibilityGranted', () async {
    expect(await platform.isAccessibilityGranted(), true);
  });

  test('getAccessibilityStatus', () async {
    final result = await platform.getAccessibilityStatus();
    expect(result.name, 'granted');
  });
}
