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

import 'json_schema_editor_controls.dart';
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
        final isWide = constraints.maxWidth >= 760;
        final useInlineLayout = constraints.maxWidth >= 460;
        final propertyKeyWidth = isWide ? 280.0 : 190.0;
        final trailingChildren = <Widget>[
          JsonSchemaEditorNodeTypeDropdown(
            value: nodeType,
            compact: true,
            onChanged: (value) {
              if (value == null) {
                return;
              }
              onTypeChanged(value);
            },
          ),
          JsonSchemaEditorCompactBooleanOption(
            label: 'Required',
            value: required,
            helpText: requiredHelpText,
            dense: useInlineLayout,
            onChanged: onRequiredChanged,
          ),
          JsonSchemaEditorActionIconButton(
            tooltip: 'Move property up',
            icon: Icons.arrow_upward_rounded,
            dense: useInlineLayout,
            onPressed: onMoveUp,
          ),
          JsonSchemaEditorActionIconButton(
            tooltip: 'Move property down',
            icon: Icons.arrow_downward_rounded,
            dense: useInlineLayout,
            onPressed: onMoveDown,
          ),
          JsonSchemaEditorActionIconButton(
            tooltip: 'Remove property',
            icon: Icons.delete_outline,
            dense: useInlineLayout,
            onPressed: onRemove,
          ),
        ];
        final trailing = isWide
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

        if (useInlineLayout) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: propertyKeyWidth, child: propertyKeyField),
              const Gap(8),
              Expanded(
                child: Align(alignment: Alignment.centerLeft, child: trailing),
              ),
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
