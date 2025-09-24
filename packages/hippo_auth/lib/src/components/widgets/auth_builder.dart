import 'package:flutter/widgets.dart';
import 'package:hippo_auth/hippo_auth.dart';
import 'package:hippo_utils/hippo_utils.dart';

class HippoAuthBuilder extends StatelessWidget {
  final Widget Function(
    BuildContext context,
    SelectedValue<AuthSession?>? session,
  )
  builder;
  const HippoAuthBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final authBloc = HippoAuthBloc.of(context);
    return StatefulDataSubjectBuilder(
      subject: authBloc.apiController.sessionSubject,
      builder: builder,
    );
  }
}
