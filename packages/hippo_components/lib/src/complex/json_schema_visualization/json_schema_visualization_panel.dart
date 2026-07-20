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
import 'package:hippo_utils/hippo_utils.dart';
import 'package:json_schema/json_schema.dart';

enum _JsonSchemaPreviewMode { optimized, json }

class JsonSchemaVisualizationPanel extends StatefulWidget {
  const JsonSchemaVisualizationPanel({super.key, required this.controller, required this.schema});

  final JsonSchemaEditorController controller;
  final JsonSchema schema;

  @override
  State<JsonSchemaVisualizationPanel> createState() => _JsonSchemaVisualizationPanelState();
}

class _JsonSchemaVisualizationPanelState extends State<JsonSchemaVisualizationPanel> {
  _JsonSchemaPreviewMode _mode = _JsonSchemaPreviewMode.optimized;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.lazyTranslate(en: 'Schema Preview', de: 'Schema-Vorschau', zh: 'Schema 预览'),
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const Gap(10),
          SegmentedButton<_JsonSchemaPreviewMode>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: _JsonSchemaPreviewMode.optimized,
                icon: const Icon(Icons.auto_awesome_rounded),
                label: Text(context.lazyTranslate(en: 'Optimized', de: 'Optimiert', zh: '优化视图')),
              ),
              ButtonSegment(
                value: _JsonSchemaPreviewMode.json,
                icon: const Icon(Icons.data_object_rounded),
                label: Text('JSON'),
              ),
            ],
            selected: {_mode},
            style: const ButtonStyle(
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onSelectionChanged: (selection) {
              final next = selection.isEmpty ? null : selection.first;
              if (next == null || next == _mode) {
                return;
              }
              setState(() {
                _mode = next;
              });
            },
          ),
          const Gap(12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: switch (_mode) {
              _JsonSchemaPreviewMode.optimized => JsonSchemaVisualization(
                key: const ValueKey('optimized-view'),
                schema: widget.schema,
                extensionOptions: widget.controller.extensionOptions,
              ),
              _JsonSchemaPreviewMode.json => _RawJsonSchemaView(
                key: const ValueKey('json-view'),
                schema: widget.schema,
              ),
            },
          ),
        ],
      ),
    );
  }
}

class _RawJsonSchemaView extends StatelessWidget {
  const _RawJsonSchemaView({super.key, required this.schema});

  final JsonSchema schema;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 360),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.55)),
      ),
      child: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          child: SelectableText(
            schema.toJsonString(pretty: true),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
              height: 1.4,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
