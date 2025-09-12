import 'package:flutter/widgets.dart';
import 'package:hippo_components/hippo_components.dart';

class AdaptiveBuilder extends StatelessWidget {
  final Function(BuildContext context, bool isDesktop) builder;
  const AdaptiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return builder(context, size.width > ComponentConstants.kMobileDesktopBreakpoint);
  }
}
