/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
import 'package:app_release_client/src/app_release_client_bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:hippo_core_flutter/hippo_core_flutter.dart';
import 'package:hippo_utils/hippo_utils.dart';

class AppReleaseClientBuilder extends StatelessWidget {
  final AppReleaseClientBloc? bloc;
  final Widget Function(BuildContext context, SelectedValue<Uri?>? value)
  builder;

  const AppReleaseClientBuilder({super.key, required this.builder, this.bloc});

  @override
  Widget build(BuildContext context) {
    final currentBloc = bloc ?? AppReleaseClientBloc.of(context);
    return StatefulDataSubjectBuilder(
      subject: currentBloc.appCastUrlSubject,
      builder: builder,
    );
  }
}
