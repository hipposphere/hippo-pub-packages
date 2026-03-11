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
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.55)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Schema Preview',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const Gap(6),
            Text(switch (_mode) {
              _JsonSchemaPreviewMode.optimized =>
                'Optimized structural view with nested fields, constraints, and schema extensions.',
              _JsonSchemaPreviewMode.json =>
                'Pure JSON output of the current schema, formatted for inspection and copy/paste.',
            }, style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
            const Gap(12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SegmentedButton<_JsonSchemaPreviewMode>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(
                      value: _JsonSchemaPreviewMode.optimized,
                      icon: Icon(Icons.auto_awesome_rounded),
                      label: Text('Optimized'),
                    ),
                    ButtonSegment(
                      value: _JsonSchemaPreviewMode.json,
                      icon: Icon(Icons.data_object_rounded),
                      label: Text('JSON'),
                    ),
                  ],
                  selected: {_mode},
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
                Button(
                  onTap: () {
                    Clipboard.setData(
                      ClipboardData(text: widget.schema.toJsonString(pretty: true)),
                    );
                  },
                  label: 'Copy JSON',
                  prefix: const Icon(Icons.content_copy_rounded),
                  type: ButtonType.secondary,
                ),
                Button(
                  onTap: widget.controller.reset,
                  label: 'Reset',
                  prefix: const Icon(Icons.history_rounded),
                  type: ButtonType.outline,
                ),
                Button(
                  onTap: widget.controller.clearRootObject,
                  label: 'Clear',
                  prefix: const Icon(Icons.layers_clear_rounded),
                  type: ButtonType.outline,
                ),
              ],
            ),
            const Gap(16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: switch (_mode) {
                _JsonSchemaPreviewMode.optimized => JsonSchemaVisualization(
                  key: const ValueKey('optimized-view'),
                  schema: widget.schema,
                  extensionOptions: widget.controller.extensionOptions,
                  showContainer: false,
                  showHeader: false,
                ),
                _JsonSchemaPreviewMode.json => _RawJsonSchemaView(
                  key: const ValueKey('json-view'),
                  schema: widget.schema,
                ),
              },
            ),
          ],
        ),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.55)),
      ),
      child: SelectableText(
        schema.toJsonString(pretty: true),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontFamily: 'monospace',
          height: 1.5,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }
}
