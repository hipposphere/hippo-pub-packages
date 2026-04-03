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

import 'json_schema_editor_info_icon.dart';

class JsonSchemaEditorCompactBooleanOption extends StatelessWidget {
  const JsonSchemaEditorCompactBooleanOption({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.helpText,
    this.dense = false,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? helpText;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderRadius = BorderRadius.circular(dense ? 10 : 12);

    return InkWell(
      borderRadius: borderRadius,
      onTap: () => onChanged(!value),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: dense ? 4 : 6),
        decoration: BoxDecoration(
          color: value
              ? colorScheme.primaryContainer.withValues(alpha: 0.75)
              : colorScheme.surfaceContainerLowest,
          borderRadius: borderRadius,
          border: Border.all(
            color: value
                ? colorScheme.primary.withValues(alpha: 0.3)
                : colorScheme.outlineVariant.withValues(alpha: 0.7),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: value,
              visualDensity: dense
                  ? const VisualDensity(horizontal: -3, vertical: -3)
                  : VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onChanged: (next) => onChanged(next ?? false),
            ),
            Text(
              label,
              style: dense
                  ? Theme.of(context).textTheme.labelSmall
                  : Theme.of(context).textTheme.bodySmall,
            ),
            if (helpText != null) ...[
              const Gap(4),
              JsonSchemaEditorInfoIcon(message: helpText, size: dense ? 12 : 14),
            ],
          ],
        ),
      ),
    );
  }
}

class JsonSchemaEditorActionIconButton extends StatelessWidget {
  const JsonSchemaEditorActionIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.dense = false,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      icon: Icon(icon, size: 18),
      visualDensity: VisualDensity.compact,
      constraints: BoxConstraints(minWidth: dense ? 36 : 32, minHeight: dense ? 36 : 32),
      onPressed: onPressed,
    );
  }
}

class JsonSchemaEditorNodeTypeDropdown extends StatelessWidget {
  const JsonSchemaEditorNodeTypeDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.compact = false,
  });

  final JsonSchemaNodeType value;
  final ValueChanged<JsonSchemaNodeType?> onChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: compact ? 5 : 2),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.7)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<JsonSchemaNodeType>(
          value: value,
          isDense: true,
          items: JsonSchemaNodeType.values
              .map(
                (type) => DropdownMenuItem(
                  value: type,
                  child: Text(switch (type) {
                    JsonSchemaNodeType.string => 'String',
                    JsonSchemaNodeType.number => 'Number',
                    JsonSchemaNodeType.integer => 'Integer',
                    JsonSchemaNodeType.boolean => 'Boolean',
                    JsonSchemaNodeType.object => 'Object',
                    JsonSchemaNodeType.array => 'Array',
                  }),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
