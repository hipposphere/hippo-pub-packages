import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:app_permissions/app_permissions.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('check accessibility permission', (WidgetTester tester) async {
    final bool isGranted = await AppPermissions.isAccessibilityGranted();
    // On platforms where permissions are not required, this should return true
    // On macOS, it depends on whether the permission has been granted
    expect(isGranted, isA<bool>());
  });

  testWidgets('get accessibility status', (WidgetTester tester) async {
    final PermissionStatus status =
        await AppPermissions.getAccessibilityStatus();
    expect(status, isA<PermissionStatus>());
  });
}
