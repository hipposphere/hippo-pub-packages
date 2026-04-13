// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:hippo_utils/hippo_utils.dart';

import '../json_schema_editor_descriptions.dart';
import 'json_schema_editor_controls.dart';
import 'json_schema_editor_info_icon.dart';

class JsonSchemaEditorNodeHeader extends StatelessWidget {
  const JsonSchemaEditorNodeHeader({
    super.key,
    required this.nodeType,
    required this.path,
    required this.onTypeChanged,
    this.compactMode = false,
    this.showPath = true,
  });

  final JsonSchemaNodeType nodeType;
  final JsonSchemaPath path;
  final ValueChanged<JsonSchemaNodeType> onTypeChanged;
  final bool compactMode;
  final bool showPath;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final typeBadgeColor = compactMode
        ? colorScheme.secondaryContainer.withValues(alpha: 0.55)
        : colorScheme.primaryContainer.withValues(alpha: 0.65);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: typeBadgeColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      jsonSchemaTypeLabel(nodeType),
                      style: Theme.of(
                        context,
                      ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const Gap(4),
                    JsonSchemaEditorInfoIcon(message: jsonSchemaTypeHelp(nodeType), size: 14),
                  ],
                ),
              ),
              if (showPath && !path.isRoot) ...[
                const Gap(6),
                Text(
                  path.toJsonPointerString(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ],
          ),
        ),
        const Gap(8),
        JsonSchemaEditorNodeTypeDropdown(
          value: nodeType,
          compact: compactMode,
          onChanged: (value) {
            if (value == null) {
              return;
            }
            onTypeChanged(value);
          },
        ),
      ],
    );
  }
}
