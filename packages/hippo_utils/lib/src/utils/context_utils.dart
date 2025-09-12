import 'package:flutter/widgets.dart';
import 'package:hippo_utils/hippo_utils.dart';

extension UtilsContextExtension on BuildContext {
  GlobalKey<NavigatorState> get navigatorKey {
    return NavigatorKeyBloc.of(this).navigatorKey;
  }

  Size get mediaSize => MediaQuery.sizeOf(this);

  bool get isDesktop => mediaSize.width >= 850.0;
}
