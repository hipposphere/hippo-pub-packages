/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:hippo_utils/hippo_utils.dart';

bool _isInternalSchemaExtensionKey(String key) {
  return key.trim() == jsonSchemaObjectPropertyOrderExtensionKey;
}

class JsonSchemaVisualization extends StatelessWidget {
  const JsonSchemaVisualization({
    super.key,
    required this.schema,
    this.extensionOptions = JsonSchemaEditorExtensionOptions.none,
    this.title,
    this.showHeader = true,
    this.showContainer = true,
  });

  final JsonSchema schema;
  final JsonSchemaEditorExtensionOptions extensionOptions;
  final String? title;
  final bool showHeader;
  final bool showContainer;

  @override
  Widget build(BuildContext context) {
    final rootNode = schema.node;
    final metrics = _JsonSchemaVisualizationMetrics.fromNode(rootNode);
    final headerTitle = title?.trim();
    final content = SelectionArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showHeader) ...[
            Text(
              headerTitle == null || headerTitle.isEmpty ? 'Schema Overview' : headerTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const Gap(8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _SchemaBadge(
                  label: _typeLabel(rootNode.type),
                  icon: _schemaTypeSpec(rootNode.type).icon,
                  backgroundColor: _schemaTypeSpec(rootNode.type).accent.withValues(alpha: 0.14),
                  foregroundColor: _schemaTypeSpec(rootNode.type).accent,
                ),
                _SchemaBadge(
                  label: '${metrics.nodeCount} nodes',
                  icon: Icons.account_tree_rounded,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
                  foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                if (metrics.propertyCount > 0)
                  _SchemaBadge(
                    label: '${metrics.propertyCount} properties',
                    icon: Icons.data_object_rounded,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.secondaryContainer.withValues(alpha: 0.65),
                    foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                if (metrics.extensionCount > 0)
                  _SchemaBadge(
                    label: '${metrics.extensionCount} extensions',
                    icon: Icons.extension_rounded,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.tertiaryContainer.withValues(alpha: 0.65),
                    foregroundColor: Theme.of(context).colorScheme.onTertiaryContainer,
                  ),
              ],
            ),
            const Gap(12),
          ],
          _JsonSchemaNodeCard(
            node: rootNode,
            path: const JsonSchemaPath.root(),
            extensionOptions: extensionOptions,
            isRoot: true,
          ),
        ],
      ),
    );

    if (!showContainer) {
      return content;
    }

    return _SchemaSurface(padding: const EdgeInsets.all(12), child: content);
  }
}

class _JsonSchemaNodeCard extends StatelessWidget {
  const _JsonSchemaNodeCard({
    required this.node,
    required this.path,
    required this.extensionOptions,
    this.propertyKey,
    this.isRequired = false,
    this.isRoot = false,
  });

  final JsonSchemaNode node;
  final JsonSchemaPath path;
  final JsonSchemaEditorExtensionOptions extensionOptions;
  final String? propertyKey;
  final bool isRequired;
  final bool isRoot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spec = _schemaTypeSpec(node.type);
    final title = _titleForNode(node: node, propertyKey: propertyKey, isRoot: isRoot);
    final details = _detailsForNode(node);
    final sortedExtensions =
        node.extensions.entries.where((entry) => !_isInternalSchemaExtensionKey(entry.key)).toList()
          ..sort((left, right) => left.key.compareTo(right.key));
    final configuredExtensions = {
      for (final field in extensionOptions.extensionsForNodeType(node.type))
        if (!_isInternalSchemaExtensionKey(field.key)) field.key.trim(): field,
    };
    final children = _childrenForNode(node, extensionOptions, path);

    return Container(
      decoration: BoxDecoration(
        color: isRoot ? colorScheme.surface : colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(isRoot ? 16 : 14),
        border: Border.all(
          color: isRoot
              ? spec.accent.withValues(alpha: 0.18)
              : colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: spec.accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(spec.icon, color: spec.accent, size: 18),
                ),
                const Gap(10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _SchemaBadge(
                            label: _typeLabel(node.type),
                            icon: spec.icon,
                            backgroundColor: spec.accent.withValues(alpha: 0.14),
                            foregroundColor: spec.accent,
                          ),
                          _SchemaBadge(
                            label: path.toString(),
                            icon: Icons.route_rounded,
                            backgroundColor: colorScheme.surfaceContainerHighest.withValues(
                              alpha: 0.55,
                            ),
                            foregroundColor: colorScheme.onSurfaceVariant,
                            monospace: true,
                          ),
                          if (propertyKey != null && propertyKey!.trim().isNotEmpty)
                            _SchemaBadge(
                              label: propertyKey!.trim(),
                              icon: Icons.key_rounded,
                              backgroundColor: colorScheme.surfaceContainerLow.withValues(
                                alpha: 0.8,
                              ),
                              foregroundColor: colorScheme.onSurface,
                              monospace: true,
                            ),
                          if (isRequired)
                            _SchemaBadge(
                              label: 'required',
                              icon: Icons.star_rounded,
                              backgroundColor: colorScheme.primaryContainer,
                              foregroundColor: colorScheme.onPrimaryContainer,
                            ),
                        ],
                      ),
                      const Gap(8),
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      if (node.description != null && node.description!.trim().isNotEmpty) ...[
                        const Gap(6),
                        Text(
                          node.description!.trim(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (details.isNotEmpty) ...[
              const Gap(10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: details
                    .map(
                      (detail) => _SchemaDetailTile(
                        label: detail.label,
                        value: detail.value,
                        icon: detail.icon,
                        accent: spec.accent,
                        monospace: detail.monospace,
                      ),
                    )
                    .toList(),
              ),
            ],
            if (node case JsonSchemaStringNode(
              enumValues: final enumValues?,
            ) when enumValues.isNotEmpty) ...[
              const Gap(10),
              _SectionHeading(
                label: 'Enum Values',
                icon: Icons.format_list_bulleted_rounded,
                accent: spec.accent,
                count: enumValues.length,
              ),
              const Gap(6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: enumValues
                    .map(
                      (value) => _SchemaBadge(
                        label: value,
                        icon: Icons.label_outline_rounded,
                        backgroundColor: spec.accent.withValues(alpha: 0.10),
                        foregroundColor: spec.accent,
                        monospace: true,
                      ),
                    )
                    .toList(),
              ),
            ],
            if (sortedExtensions.isNotEmpty) ...[
              const Gap(10),
              _SectionHeading(
                label: 'Extensions',
                icon: Icons.extension_rounded,
                accent: spec.accent,
              ),
              const Gap(6),
              ...sortedExtensions.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: _SchemaExtensionCard(
                    extensionKey: entry.key,
                    extensionValue: entry.value,
                    description: configuredExtensions[entry.key.trim()]?.normalizedDescription,
                    isConfigured: configuredExtensions.containsKey(entry.key.trim()),
                    accent: spec.accent,
                  ),
                ),
              ),
            ],
            if (children.isNotEmpty) ...[
              const Gap(10),
              _SectionHeading(
                label: node is JsonSchemaArrayNode ? 'Item Schema' : 'Properties',
                icon: node is JsonSchemaArrayNode
                    ? Icons.view_stream_rounded
                    : Icons.data_object_rounded,
                accent: spec.accent,
              ),
              const Gap(8),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _childrenForNode(
    JsonSchemaNode currentNode,
    JsonSchemaEditorExtensionOptions options,
    JsonSchemaPath currentPath,
  ) {
    if (currentNode is JsonSchemaObjectNode) {
      final entries = currentNode.orderedPropertyEntries.toList();
      return [
        if (entries.isEmpty)
          const _SchemaEmptyState(message: 'No properties defined yet.')
        else
          for (var index = 0; index < entries.length; index += 1) ...[
            _JsonSchemaNodeCard(
              node: entries[index].value,
              propertyKey: entries[index].key,
              path: currentPath.childProperty(entries[index].key),
              extensionOptions: options,
              isRequired: currentNode.required.contains(entries[index].key),
            ),
            if (index < entries.length - 1) const Gap(8),
          ],
      ];
    }

    if (currentNode is JsonSchemaArrayNode) {
      return [
        _JsonSchemaNodeCard(
          node: currentNode.items,
          propertyKey: 'items',
          path: currentPath.childItems(),
          extensionOptions: options,
        ),
      ];
    }

    return const [];
  }
}

class _SchemaExtensionCard extends StatelessWidget {
  const _SchemaExtensionCard({
    required this.extensionKey,
    required this.extensionValue,
    required this.description,
    required this.isConfigured,
    required this.accent,
  });

  final String extensionKey;
  final Object? extensionValue;
  final String? description;
  final bool isConfigured;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final valueText = _stringifySchemaValue(extensionValue);
    final useCodeStyle =
        extensionValue is Map ||
        extensionValue is List ||
        extensionValue is num ||
        extensionValue is bool ||
        valueText.contains('\n');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _SchemaBadge(
                label: extensionKey,
                icon: Icons.extension_rounded,
                backgroundColor: accent.withValues(alpha: 0.14),
                foregroundColor: accent,
                monospace: true,
              ),
              _SchemaBadge(
                label: isConfigured ? 'configured' : 'custom',
                icon: isConfigured ? Icons.tune_rounded : Icons.auto_awesome_rounded,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.65),
                foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
          if (description != null && description!.trim().isNotEmpty) ...[
            const Gap(6),
            Text(
              description!.trim(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.25,
              ),
            ),
          ],
          const Gap(6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              valueText,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: useCodeStyle ? 'monospace' : null,
                color: theme.colorScheme.onSurface,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SchemaDetailTile extends StatelessWidget {
  const _SchemaDetailTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
    this.monospace = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accent;
  final bool monospace;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: accent),
          const Gap(6),
          Text(
            '$label:',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(4),
          Flexible(
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontFamily: monospace ? 'monospace' : null,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.label,
    required this.icon,
    required this.accent,
    this.count,
  });

  final String label;
  final IconData icon;
  final Color accent;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: accent),
        const Gap(6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        if (count != null) ...[
          const Gap(6),
          Container(
            key: ValueKey('section-count-$label'),
            constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
            padding: const EdgeInsets.symmetric(horizontal: 6),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: accent.withValues(alpha: 0.2)),
            ),
            child: Text(
              count.toString(),
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: accent, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ],
    );
  }
}

class _SchemaBadge extends StatelessWidget {
  const _SchemaBadge({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    this.monospace = false,
  });

  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final bool monospace;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(999)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: foregroundColor),
            const Gap(4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: foregroundColor,
                fontWeight: FontWeight.w600,
                fontFamily: monospace ? 'monospace' : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SchemaEmptyState extends StatelessWidget {
  const _SchemaEmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Text(
        message,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }
}

class _SchemaSurface extends StatelessWidget {
  const _SchemaSurface({required this.child, required this.padding});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.55)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class _JsonSchemaVisualizationMetrics {
  const _JsonSchemaVisualizationMetrics({
    required this.nodeCount,
    required this.propertyCount,
    required this.extensionCount,
  });

  factory _JsonSchemaVisualizationMetrics.fromNode(JsonSchemaNode root) {
    var nodeCount = 0;
    var propertyCount = 0;
    var extensionCount = 0;

    void visit(JsonSchemaNode node) {
      nodeCount += 1;
      extensionCount += node.extensions.keys
          .where((key) => !_isInternalSchemaExtensionKey(key))
          .length;
      if (node is JsonSchemaObjectNode) {
        propertyCount += node.properties.length;
        for (final child in node.orderedPropertyEntries.map((entry) => entry.value)) {
          visit(child);
        }
      } else if (node is JsonSchemaArrayNode) {
        visit(node.items);
      }
    }

    visit(root);
    return _JsonSchemaVisualizationMetrics(
      nodeCount: nodeCount,
      propertyCount: propertyCount,
      extensionCount: extensionCount,
    );
  }

  final int nodeCount;
  final int propertyCount;
  final int extensionCount;
}

class _SchemaTypeSpec {
  const _SchemaTypeSpec({required this.icon, required this.accent});

  final IconData icon;
  final Color accent;
}

class _SchemaDetail {
  const _SchemaDetail({
    required this.label,
    required this.value,
    required this.icon,
    this.monospace = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool monospace;
}

_SchemaTypeSpec _schemaTypeSpec(JsonSchemaNodeType type) {
  return switch (type) {
    JsonSchemaNodeType.object => const _SchemaTypeSpec(
      icon: Icons.data_object_rounded,
      accent: Color(0xFF0F766E),
    ),
    JsonSchemaNodeType.array => const _SchemaTypeSpec(
      icon: Icons.view_stream_rounded,
      accent: Color(0xFFD97706),
    ),
    JsonSchemaNodeType.string => const _SchemaTypeSpec(
      icon: Icons.text_fields_rounded,
      accent: HippoColors.primaryDarkened,
    ),
    JsonSchemaNodeType.number => const _SchemaTypeSpec(
      icon: Icons.pin_rounded,
      accent: HippoColors.orange,
    ),
    JsonSchemaNodeType.integer => const _SchemaTypeSpec(
      icon: Icons.tag_rounded,
      accent: Color(0xFFC2410C),
    ),
    JsonSchemaNodeType.boolean => const _SchemaTypeSpec(
      icon: Icons.toggle_on_rounded,
      accent: Color(0xFF15803D),
    ),
  };
}

String _typeLabel(JsonSchemaNodeType type) {
  return switch (type) {
    JsonSchemaNodeType.string => 'String',
    JsonSchemaNodeType.number => 'Number',
    JsonSchemaNodeType.integer => 'Integer',
    JsonSchemaNodeType.boolean => 'Boolean',
    JsonSchemaNodeType.object => 'Object',
    JsonSchemaNodeType.array => 'Array',
  };
}

String _titleForNode({
  required JsonSchemaNode node,
  required String? propertyKey,
  required bool isRoot,
}) {
  final trimmedTitle = node.title?.trim();
  if (trimmedTitle != null && trimmedTitle.isNotEmpty) {
    return trimmedTitle;
  }
  final trimmedPropertyKey = propertyKey?.trim();
  if (trimmedPropertyKey != null && trimmedPropertyKey.isNotEmpty) {
    return trimmedPropertyKey;
  }
  if (isRoot) {
    return 'Root schema';
  }
  return node is JsonSchemaArrayNode ? 'Array items' : '${_typeLabel(node.type)} schema';
}

List<_SchemaDetail> _detailsForNode(JsonSchemaNode node) {
  return switch (node) {
    JsonSchemaStringNode() => [
      if (node.minLength != null)
        _SchemaDetail(
          label: 'Min length',
          value: node.minLength.toString(),
          icon: Icons.straighten_rounded,
        ),
      if (node.maxLength != null)
        _SchemaDetail(
          label: 'Max length',
          value: node.maxLength.toString(),
          icon: Icons.width_normal_rounded,
        ),
      if (node.pattern != null && node.pattern!.trim().isNotEmpty)
        _SchemaDetail(
          label: 'Pattern',
          value: node.pattern!.trim(),
          icon: Icons.code_rounded,
          monospace: true,
        ),
    ],
    JsonSchemaNumberNode() => [
      if (node.minimum != null)
        _SchemaDetail(
          label: 'Minimum',
          value: _formatNumber(node.minimum),
          icon: Icons.south_rounded,
        ),
      if (node.maximum != null)
        _SchemaDetail(
          label: 'Maximum',
          value: _formatNumber(node.maximum),
          icon: Icons.north_rounded,
        ),
      if (node.exclusiveMinimum != null)
        _SchemaDetail(
          label: 'Exclusive min',
          value: node.exclusiveMinimum! ? 'true' : 'false',
          icon: Icons.lock_open_rounded,
        ),
      if (node.exclusiveMaximum != null)
        _SchemaDetail(
          label: 'Exclusive max',
          value: node.exclusiveMaximum! ? 'true' : 'false',
          icon: Icons.lock_outline_rounded,
        ),
      if (node.multipleOf != null)
        _SchemaDetail(
          label: 'Multiple of',
          value: _formatNumber(node.multipleOf),
          icon: Icons.grid_3x3_rounded,
        ),
    ],
    JsonSchemaBooleanNode() => [
      if (node.defaultValue != null)
        _SchemaDetail(
          label: 'Default',
          value: node.defaultValue! ? 'true' : 'false',
          icon: Icons.toggle_on_rounded,
          monospace: true,
        ),
    ],
    JsonSchemaObjectNode() => [
      _SchemaDetail(
        label: 'Properties',
        value: node.properties.length.toString(),
        icon: Icons.data_object_rounded,
      ),
      _SchemaDetail(
        label: 'Required',
        value: node.required.length.toString(),
        icon: Icons.star_rounded,
      ),
      _SchemaDetail(
        label: 'Additional props',
        value: node.additionalProperties ? 'allowed' : 'blocked',
        icon: node.additionalProperties ? Icons.lock_open_rounded : Icons.lock_rounded,
      ),
    ],
    JsonSchemaArrayNode() => [
      if (node.minItems != null)
        _SchemaDetail(
          label: 'Min items',
          value: node.minItems.toString(),
          icon: Icons.format_list_numbered_rounded,
        ),
      if (node.maxItems != null)
        _SchemaDetail(
          label: 'Max items',
          value: node.maxItems.toString(),
          icon: Icons.format_list_numbered_rtl_rounded,
        ),
      if (node.uniqueItems != null)
        _SchemaDetail(
          label: 'Unique items',
          value: node.uniqueItems! ? 'true' : 'false',
          icon: Icons.fingerprint_rounded,
          monospace: true,
        ),
    ],
  };
}

String _formatNumber(num? value) {
  if (value == null) {
    return '';
  }
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }
  return value.toString();
}

String _stringifySchemaValue(Object? value) {
  if (value == null) {
    return 'null';
  }
  if (value is String) {
    return value;
  }
  if (value is num || value is bool) {
    return value.toString();
  }
  if (value is List || value is Map) {
    return const JsonEncoder.withIndent('  ').convert(_normalizeJsonValue(value));
  }
  return value.toString();
}

Object? _normalizeJsonValue(Object? value) {
  if (value is Map) {
    return value.map(
      (entryKey, entryValue) => MapEntry(entryKey.toString(), _normalizeJsonValue(entryValue)),
    );
  }
  if (value is List) {
    return value.map(_normalizeJsonValue).toList();
  }
  return value;
}
