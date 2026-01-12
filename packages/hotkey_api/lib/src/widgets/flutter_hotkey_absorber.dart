import 'package:flutter/material.dart';
import 'package:hotkey_api/hotkey_api.dart';

class FlutterHotkeyAbsorber extends StatelessWidget {
  final HotkeyStatusController statusController;
  final Widget child;
  const FlutterHotkeyAbsorber({
    super.key,
    required this.statusController,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      autofocus: true,
      onKeyEvent: (node, event) {
        return statusController.handleFlutterKeyEvent(event);
      },
      child: child,
    );
  }
}
