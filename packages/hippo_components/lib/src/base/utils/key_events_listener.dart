import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class KeyEventsListenerController {
  final KeyEventResult Function(KeyDownEvent keyDownEvent) onKeyDownEvent;

  KeyEventsListenerController({required this.onKeyDownEvent});

  factory KeyEventsListenerController.fromTransformer(KeyEventTransformer transformer) {
    return KeyEventsListenerController(onKeyDownEvent: transformer.handleEvent);
  }
}

abstract class KeyEventTransformer {
  KeyEventResult handleEvent(KeyDownEvent event);
}

class KeyEventsListenerContainer extends StatelessWidget {
  final KeyEventsListenerController controller;
  final bool isEnabled;
  final Widget child;
  const KeyEventsListenerContainer({
    super.key,
    this.isEnabled = true,
    required this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (!isEnabled) {
      return child;
    }
    return FocusScope(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (node.hasPrimaryFocus == false) {
          return KeyEventResult.ignored;
        }
        if (event is KeyDownEvent) {
          return controller.onKeyDownEvent(event);
        }
        return KeyEventResult.ignored;
      },
      child: child,
    );
  }
}
