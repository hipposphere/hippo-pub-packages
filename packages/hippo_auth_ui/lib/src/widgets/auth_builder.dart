import 'package:flutter/widgets.dart';
import 'package:hippo_auth/hippo_auth.dart';
import 'package:hippo_core_flutter/hippo_core_flutter.dart';

class HippoAuthBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, HippoAuthState authState) builder;
  const HippoAuthBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final authBloc = HippoAuthBloc.of(context);
    return DataValueBuilder(
      value: authBloc.apiController.stateSubject,
      builder: builder,
    );
  }
}
