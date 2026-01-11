/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited 
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
import 'package:flutter/material.dart';
import 'package:hippo_components/hippo_components.dart';

class ModalActionsBar extends StatelessWidget {
  final List<Widget> actions;
  const ModalActionsBar({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    return Column(children: actions);
  }
}

class OkModalActionsBar extends StatelessWidget {
  final bool enabled;
  final String? label;
  final VoidCallback? onTap;
  const OkModalActionsBar({super.key, required this.label, this.onTap, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return Button(
      onTap: enabled
          ? (onTap ??
                () {
                  Navigator.of(context).pop();
                })
          : null,
      label: label ?? context.cl.actions_ok,
    );
  }
}

class CancelConfirmModalActionsBar extends StatelessWidget {
  final WidgetBuilder confirmBuilder;
  final bool isConfirmLarge;
  final void Function(BuildContext context)? onCancel;
  const CancelConfirmModalActionsBar({
    super.key,
    required this.confirmBuilder,
    this.isConfirmLarge = true,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return ModalActionsBar(
      actions: [
        Button(
          onTap: onCancel != null
              ? () {
                  onCancel!(context);
                }
              : () {
                  Navigator.of(context).pop();
                },
          label: context.cl.actions_cancel,
          type: ButtonType.outline,
        ),

        Gap(16),
        confirmBuilder(context),
      ],
    );
  }
}
