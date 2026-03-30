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
import 'json_schema_editor_text_field.dart';

class JsonSchemaObjectPropertyHeader extends StatelessWidget {
  const JsonSchemaObjectPropertyHeader({
    super.key,
    required this.propertyKey,
    required this.nodeType,
    required this.required,
    required this.onPropertyKeyChanged,
    required this.onTypeChanged,
    required this.onRequiredChanged,
    required this.onRemove,
    this.propertyKeyHelpText,
    this.requiredHelpText,
    this.onMoveUp,
    this.onMoveDown,
    this.debounceDelay = const Duration(milliseconds: 450),
  });

  final String propertyKey;
  final JsonSchemaNodeType nodeType;
  final bool required;
  final String? propertyKeyHelpText;
  final String? requiredHelpText;
  final ValueChanged<String> onPropertyKeyChanged;
  final ValueChanged<JsonSchemaNodeType> onTypeChanged;
  final ValueChanged<bool> onRequiredChanged;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final VoidCallback onRemove;
  final Duration debounceDelay;

  void _commitPropertyKey(String value) {
    final nextKey = value.trim();
    if (nextKey.isEmpty || nextKey == propertyKey) {
      return;
    }
    onPropertyKeyChanged(nextKey);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 760;
        final trailingChildren = <Widget>[
          _NodeTypeDropdown(
            value: nodeType,
            onChanged: (value) {
              if (value == null) {
                return;
              }
              onTypeChanged(value);
            },
          ),
          _CompactBooleanOption(
            label: 'Required',
            value: required,
            helpText: requiredHelpText,
            dense: isDesktop,
            onChanged: onRequiredChanged,
          ),
          _EditorActionIconButton(
            tooltip: 'Move property up',
            icon: Icons.arrow_upward_rounded,
            dense: isDesktop,
            onPressed: onMoveUp,
          ),
          _EditorActionIconButton(
            tooltip: 'Move property down',
            icon: Icons.arrow_downward_rounded,
            dense: isDesktop,
            onPressed: onMoveDown,
          ),
          _EditorActionIconButton(
            tooltip: 'Remove property',
            icon: Icons.delete_outline,
            dense: isDesktop,
            onPressed: onRemove,
          ),
        ];
        final trailing = isDesktop
            ? Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  for (var i = 0; i < trailingChildren.length; i++) ...[
                    trailingChildren[i],
                    if (i < trailingChildren.length - 1) const Gap(4),
                  ],
                ],
              )
            : Wrap(
                spacing: 4,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: trailingChildren,
              );

        final propertyKeyField = JsonSchemaEditorTextField(
          value: propertyKey,
          hint: 'Property key',
          helpText: propertyKeyHelpText,
          debounceDelay: debounceDelay,
          onChanged: _commitPropertyKey,
          onSubmitted: _commitPropertyKey,
          onCleared: () {},
        );

        if (isDesktop) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: propertyKeyField),
              const Gap(8),
              trailing,
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [propertyKeyField, const Gap(6), trailing],
        );
      },
    );
  }
}

class _CompactBooleanOption extends StatelessWidget {
  const _CompactBooleanOption({
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

class _EditorActionIconButton extends StatelessWidget {
  const _EditorActionIconButton({
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

class _NodeTypeDropdown extends StatelessWidget {
  const _NodeTypeDropdown({required this.value, required this.onChanged});

  final JsonSchemaNodeType value;
  final ValueChanged<JsonSchemaNodeType?> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
