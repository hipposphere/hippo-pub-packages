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

  Future<void> _confirmAndRun({
    required String title,
    required String message,
    required String confirmLabel,
    required VoidCallback action,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      action();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.55)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Schema Preview',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const Gap(4),
            Text(switch (_mode) {
              _JsonSchemaPreviewMode.optimized => 'Compact structural view',
              _JsonSchemaPreviewMode.json => 'Formatted JSON source',
            }, style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
            const Gap(10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
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
                  style: ButtonStyle(
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
                _PreviewActionChip(
                  onTap: () {
                    Clipboard.setData(
                      ClipboardData(text: widget.schema.toJsonString(pretty: true)),
                    );
                  },
                  label: 'Copy JSON',
                  icon: Icons.content_copy_rounded,
                ),
                _PreviewActionChip(
                  onTap: () {
                    _confirmAndRun(
                      title: 'Reset schema?',
                      message: 'This discards current edits and restores the initial schema.',
                      confirmLabel: 'Reset schema',
                      action: widget.controller.reset,
                    );
                  },
                  label: 'Reset',
                  icon: Icons.history_rounded,
                ),
                _PreviewActionChip(
                  onTap: () {
                    _confirmAndRun(
                      title: 'Clear schema?',
                      message:
                          'This removes the current schema content and starts again with an empty root object.',
                      confirmLabel: 'Clear schema',
                      action: widget.controller.clearRootObject,
                    );
                  },
                  label: 'Clear',
                  icon: Icons.layers_clear_rounded,
                ),
              ],
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

class _PreviewActionChip extends StatelessWidget {
  const _PreviewActionChip({required this.onTap, required this.label, required this.icon});

  final VoidCallback onTap;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.7)),
    );
  }
}
