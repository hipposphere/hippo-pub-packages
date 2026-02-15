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
import 'package:app_release_client/src/models/app_release_channel.dart';
import 'package:flutter/material.dart';
import 'package:hippo_utils/hippo_utils.dart';

class AppReleaseChannelSelector extends StatelessWidget {
  final AppReleaseClientBloc? bloc;
  final String labelText;
  final bool enabled;

  const AppReleaseChannelSelector({
    super.key,
    this.bloc,
    this.labelText = 'Release channel',
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final currentBloc = bloc ?? AppReleaseClientBloc.of(context);

    return CombinedDataSubjectBuilder<
      SelectedValue<List<AppReleaseChannel>>,
      SelectedValue<AppReleaseChannel?>
    >(
      subject1: currentBloc.channelsSubject,
      subject2: currentBloc.selectedChannelSubject,
      builder: (context, channelsState, selectedState) {
        final channels = channelsState.value;
        final selectedChannel = selectedState.value;

        if (channels.isEmpty) {
          return TextFormField(
            enabled: false,
            decoration: InputDecoration(labelText: labelText),
          );
        }

        final selectedSlug = selectedChannel?.slug;
        final hasSelectedValue =
            selectedSlug != null &&
            channels.any((channel) => channel.slug == selectedSlug);

        final selectedValue = hasSelectedValue
            ? selectedSlug
            : channels.first.slug;
        return DropdownButtonFormField<String>(
          key: ValueKey<String>(selectedValue),
          initialValue: selectedValue,
          decoration: InputDecoration(labelText: labelText),
          items: channels
              .map(
                (channel) => DropdownMenuItem<String>(
                  value: channel.slug,
                  child: Text(channel.label),
                ),
              )
              .toList(growable: false),
          onChanged: !enabled
              ? null
              : (nextValue) {
                  if (nextValue == null) {
                    return;
                  }
                  currentBloc.selectChannelBySlug(nextValue);
                },
        );
      },
    );
  }
}
