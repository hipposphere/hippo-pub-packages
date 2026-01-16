import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_permissions/app_permissions_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelAppPermissions platform = MethodChannelAppPermissions();
  const MethodChannel channel = MethodChannel('app_permissions');

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
