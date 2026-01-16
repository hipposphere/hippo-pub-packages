import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:desktop_permissions/desktop_permissions.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('check accessibility permission', (WidgetTester tester) async {
    final DesktopPermissions plugin = DesktopPermissions();
    final bool isGranted = await plugin.isAccessibilityGranted();
    // On platforms where permissions are not required, this should return true
    // On macOS, it depends on whether the permission has been granted
    expect(isGranted, isA<bool>());
  });

  testWidgets('get accessibility status', (WidgetTester tester) async {
    final DesktopPermissions plugin = DesktopPermissions();
    final PermissionStatus status = await plugin.getAccessibilityStatus();
    expect(status, isA<PermissionStatus>());
  });
}
