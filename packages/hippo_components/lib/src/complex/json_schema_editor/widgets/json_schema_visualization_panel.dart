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
import 'package:flutter/services.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:hippo_utils/hippo_utils.dart';

class JsonSchemaVisualizationPanel extends StatelessWidget {
  const JsonSchemaVisualizationPanel({
    super.key,
    required this.controller,
    required this.schema,
  });

  final JsonSchemaEditorController controller;
  final JsonSchema schema;

  @override
  Widget build(BuildContext context) {
    return HippoGradientCard(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Button(
                      onTap: () {
                        Clipboard.setData(
                          ClipboardData(text: schema.toJsonString(pretty: true)),
                        );
                      },
                      label: 'Copy JSON',
                      type: ButtonType.secondary,
                    ),
                  ),
                  const Gap(8),
                  Button(
                    onTap: controller.reset,
                    label: 'Reset',
                    type: ButtonType.outline,
                  ),
                  const Gap(8),
                  Button(
                    onTap: controller.clearRootObject,
                    label: 'Clear',
                    type: ButtonType.outline,
                  ),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(12),
              child: SelectableText(
                schema.toJsonString(pretty: true),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
