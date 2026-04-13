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
import 'package:flutter/services.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:hippo_components/src/complex/json_schema_editor/json_schema_editor_descriptions.dart';
import 'package:hippo_components/src/complex/json_schema_editor/widgets/json_schema_editor_info_icon.dart';
import 'package:hippo_utils/hippo_utils.dart';

bool _isInternalSchemaExtensionKey(String key) {
  return key.trim() == jsonSchemaObjectPropertyOrderExtensionKey;
}

class JsonSchemaVisualization extends StatefulWidget {
  const JsonSchemaVisualization({
    super.key,
    required this.schema,
    this.extensionOptions = JsonSchemaEditorExtensionOptions.none,
  });

  final JsonSchema schema;
  final JsonSchemaEditorExtensionOptions extensionOptions;

  @override
  State<JsonSchemaVisualization> createState() => _JsonSchemaVisualizationState();
}

class _JsonSchemaVisualizationState extends State<JsonSchemaVisualization> {
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    return _JsonSchemaNodeCard(
      node: widget.schema.node,
      path: const JsonSchemaPath.root(),
      extensionOptions: widget.extensionOptions,
      isRoot: true,
      showDetails: _showDetails,
      onToggleDetails: () {
        setState(() {
          _showDetails = !_showDetails;
        });
      },
    );
  }
}

class _JsonSchemaNodeCard extends StatelessWidget {
  const _JsonSchemaNodeCard({
    required this.node,
    required this.path,
    required this.extensionOptions,
    required this.showDetails,
    this.propertyKey,
    this.isRequired = false,
    this.isRoot = false,
    this.onToggleDetails,
  });

  final JsonSchemaNode node;
  final JsonSchemaPath path;
  final JsonSchemaEditorExtensionOptions extensionOptions;
  final bool showDetails;
  final String? propertyKey;
  final bool isRequired;
  final bool isRoot;
  final VoidCallback? onToggleDetails;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spec = _schemaTypeSpec(node.type);
    final title = _titleForNode(
      context: context,
      node: node,
      propertyKey: propertyKey,
      isRoot: isRoot,
    );
    final details = _detailsForNode(context, node);
    final jsonPointer = path.toJsonPointerString();
    final sortedExtensions =
        node.extensions.entries.where((entry) => !_isInternalSchemaExtensionKey(entry.key)).toList()
          ..sort((left, right) => left.key.compareTo(right.key));
    final configuredExtensions = {
      for (final field in extensionOptions.extensionsForNodeType(node.type, path: path))
        if (!_isInternalSchemaExtensionKey(field.key)) field.key.trim(): field,
    };
    final capabilityItems = <Widget>[
      ...details.map(
        (detail) => _SchemaDetailTile(
          label: detail.label,
          value: detail.value,
          icon: detail.icon,
          accent: spec.accent,
          monospace: detail.monospace,
        ),
      ),
      ...sortedExtensions.map((entry) {
        final configuredField = configuredExtensions[entry.key.trim()];
        final preview = _resolveSchemaExtensionPreview(
          context: context,
          configuredField: configuredField,
          value: entry.value,
        );
        return _SchemaExtensionPill(
          extensionKey: entry.key,
          extensionLabel: configuredField?.resolveDisplayLabel(context) ?? entry.key,
          extensionValue: entry.value,
          displayValue: preview.preview,
          description: _joinSchemaExtensionDescriptions(
            configuredField?.resolveDescription(context),
            preview.description,
          ),
          showRawValueInInfo: preview.showRawValueInInfo,
          accent: spec.accent,
        );
      }),
    ];
    final children = _childrenForNode(context, node, extensionOptions, path);
    final objectNode = switch (node) {
      JsonSchemaObjectNode objectNode => objectNode,
      _ => null,
    };

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
                            label: jsonSchemaTypeLabel(context, node.type),
                            icon: spec.icon,
                            backgroundColor: spec.accent.withValues(alpha: 0.14),
                            foregroundColor: spec.accent,
                          ),
                          if (showDetails)
                            _SchemaBadge(
                              label: path.toJsonPointerString(),
                              icon: Icons.route_rounded,
                              backgroundColor: colorScheme.surfaceContainerHighest.withValues(
                                alpha: 0.55,
                              ),
                              foregroundColor: colorScheme.onSurfaceVariant,
                              monospace: true,
                              tooltip: context.lazyTranslate(
                                en: 'Copy JSON Pointer',
                                de: 'JSON Pointer kopieren',
                                zh: '复制 JSON Pointer',
                              ),
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: jsonPointer));
                              },
                            ),
                          if (showDetails && propertyKey != null && propertyKey!.trim().isNotEmpty)
                            _SchemaBadge(
                              label: propertyKey!.trim(),
                              icon: Icons.key_rounded,
                              backgroundColor: colorScheme.surfaceContainerLow.withValues(
                                alpha: 0.8,
                              ),
                              foregroundColor: colorScheme.onSurface,
                              monospace: true,
                            ),
                          if (showDetails && isRequired)
                            _SchemaBadge(
                              label: context.lazyTranslate(en: 'required', de: 'Pflicht', zh: '必填'),
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
                if (isRoot && onToggleDetails != null) ...[
                  const Gap(8),
                  _SchemaDetailsToggleButton(showDetails: showDetails, onTap: onToggleDetails!),
                ],
              ],
            ),
            if (capabilityItems.isNotEmpty) ...[
              const Gap(10),
              Wrap(spacing: 6, runSpacing: 6, children: capabilityItems),
            ],
            if (node case JsonSchemaStringNode(
              enumValues: final enumValues?,
            ) when enumValues.isNotEmpty) ...[
              const Gap(10),
              _SectionHeading(
                label: context.lazyTranslate(en: 'Enum Values', de: 'Enum-Werte', zh: '枚举值'),
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
            if (children.isNotEmpty) ...[
              const Gap(10),
              _SectionHeading(
                label: node is JsonSchemaArrayNode
                    ? context.lazyTranslate(
                        en: 'Item Schema',
                        de: 'Element-Schema',
                        zh: '元素 Schema',
                      )
                    : jsonSchemaKeywordLabel(context, 'properties'),
                icon: node is JsonSchemaArrayNode
                    ? Icons.view_stream_rounded
                    : Icons.data_object_rounded,
                accent: spec.accent,
                trailing: showDetails && objectNode != null
                    ? [
                        _SectionMetaBadge(
                          key: const ValueKey('section-meta-Properties-properties'),
                          icon: Icons.data_object_rounded,
                          label: objectNode.properties.length.toString(),
                          tooltip: context.lazyTranslate(
                            en: '${objectNode.properties.length} properties',
                            de: '${objectNode.properties.length} Properties',
                            zh: '${objectNode.properties.length} 个属性',
                          ),
                          accent: spec.accent,
                        ),
                        _SectionMetaBadge(
                          key: const ValueKey('section-meta-Properties-required'),
                          icon: Icons.star_rounded,
                          label: objectNode.required.length.toString(),
                          tooltip: context.lazyTranslate(
                            en: '${objectNode.required.length} required properties',
                            de: '${objectNode.required.length} Pflicht-Properties',
                            zh: '${objectNode.required.length} 个必填属性',
                          ),
                          accent: spec.accent,
                        ),
                        _SectionMetaBadge(
                          key: const ValueKey('section-meta-Properties-additional'),
                          icon: objectNode.additionalProperties
                              ? Icons.lock_open_rounded
                              : Icons.lock_rounded,
                          tooltip: objectNode.additionalProperties
                              ? context.lazyTranslate(
                                  en: 'Additional properties allowed',
                                  de: 'Zusätzliche Properties erlaubt',
                                  zh: '允许额外属性',
                                )
                              : context.lazyTranslate(
                                  en: 'Additional properties blocked',
                                  de: 'Zusätzliche Properties blockiert',
                                  zh: '禁止额外属性',
                                ),
                          accent: spec.accent,
                        ),
                      ]
                    : const [],
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
    BuildContext context,
    JsonSchemaNode currentNode,
    JsonSchemaEditorExtensionOptions options,
    JsonSchemaPath currentPath,
  ) {
    if (currentNode is JsonSchemaObjectNode) {
      final entries = currentNode.orderedPropertyEntries.toList();
      return [
        if (entries.isEmpty)
          _SchemaEmptyState(
            message: context.lazyTranslate(
              en: 'No properties defined yet.',
              de: 'Noch keine Properties definiert.',
              zh: '尚未定义任何属性。',
            ),
          )
        else
          for (var index = 0; index < entries.length; index += 1) ...[
            _JsonSchemaNodeCard(
              node: entries[index].value,
              propertyKey: entries[index].key,
              path: currentPath.childProperty(entries[index].key),
              extensionOptions: options,
              showDetails: showDetails,
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
          showDetails: showDetails,
        ),
      ];
    }

    return const [];
  }
}

class _SchemaExtensionPill extends StatelessWidget {
  const _SchemaExtensionPill({
    required this.extensionKey,
    required this.extensionLabel,
    required this.extensionValue,
    required this.displayValue,
    required this.description,
    required this.showRawValueInInfo,
    required this.accent,
  });

  final String extensionKey;
  final String extensionLabel;
  final Object? extensionValue;
  final String displayValue;
  final String? description;
  final bool showRawValueInInfo;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final infoMessage = _schemaValueInfoMessage(
      context: context,
      value: extensionValue,
      preview: displayValue,
      description: description,
      showRawValue: showRawValueInInfo,
    );
    final useCodeStyle =
        extensionValue is Map ||
        extensionValue is List ||
        extensionValue is num ||
        extensionValue is bool;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accent.withValues(alpha: 0.12)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.extension_rounded, size: 13, color: accent),
            const Gap(6),
            Flexible(
              child: RichText(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: extensionLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'monospace',
                      ),
                    ),
                    TextSpan(
                      text: ': ',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text: displayValue,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                        fontFamily: useCodeStyle ? 'monospace' : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (infoMessage != null) ...[
              const Gap(4),
              JsonSchemaEditorInfoIcon(message: infoMessage, size: 13),
            ],
          ],
        ),
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

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 260),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accent.withValues(alpha: 0.12)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: accent),
            const Gap(6),
            Flexible(
              child: RichText(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$label: ',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text: value,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                        fontFamily: monospace ? 'monospace' : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
    this.trailing = const [],
  });

  final String label;
  final IconData icon;
  final Color accent;
  final int? count;
  final List<Widget> trailing;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Row(
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
        ),
        ...trailing,
      ],
    );
  }
}

class _SectionMetaBadge extends StatelessWidget {
  const _SectionMetaBadge({
    required this.icon,
    required this.tooltip,
    required this.accent,
    this.label,
    super.key,
  });

  final IconData icon;
  final String tooltip;
  final Color accent;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: label == null ? 7 : 8, vertical: 3),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: accent.withValues(alpha: 0.12)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: accent),
            if (label != null) ...[
              const Gap(4),
              Text(
                label!,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SchemaDetailsToggleButton extends StatelessWidget {
  const _SchemaDetailsToggleButton({required this.showDetails, required this.onTap});

  final bool showDetails;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: showDetails
          ? context.lazyTranslate(en: 'Hide details', de: 'Details ausblenden', zh: '隐藏详情')
          : context.lazyTranslate(en: 'Show details', de: 'Details anzeigen', zh: '显示详情'),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.55)),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                showDetails ? Icons.visibility_rounded : Icons.visibility_off_outlined,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
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
    this.onTap,
    this.tooltip,
  });

  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final bool monospace;
  final VoidCallback? onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final content = Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(999)),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
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
        ),
      ),
    );

    if (tooltip == null || tooltip!.trim().isEmpty) {
      return content;
    }

    return Tooltip(message: tooltip!, child: content);
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

String _titleForNode({
  required BuildContext context,
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
    return context.lazyTranslate(en: 'Root schema', de: 'Root-Schema', zh: '根 Schema');
  }
  return node is JsonSchemaArrayNode
      ? context.lazyTranslate(en: 'Array items', de: 'Array-Elemente', zh: '数组元素')
      : context.lazyTranslate(
          en: '${jsonSchemaTypeLabel(context, node.type)} schema',
          de: '${jsonSchemaTypeLabel(context, node.type)}-Schema',
          zh: '${jsonSchemaTypeLabel(context, node.type)} Schema',
        );
}

List<_SchemaDetail> _detailsForNode(BuildContext context, JsonSchemaNode node) {
  return switch (node) {
    JsonSchemaStringNode() => [
      if (node.minLength != null)
        _SchemaDetail(
          label: jsonSchemaKeywordLabel(context, 'minLength'),
          value: node.minLength.toString(),
          icon: Icons.straighten_rounded,
        ),
      if (node.maxLength != null)
        _SchemaDetail(
          label: jsonSchemaKeywordLabel(context, 'maxLength'),
          value: node.maxLength.toString(),
          icon: Icons.width_normal_rounded,
        ),
      if (node.pattern != null && node.pattern!.trim().isNotEmpty)
        _SchemaDetail(
          label: jsonSchemaKeywordLabel(context, 'pattern'),
          value: node.pattern!.trim(),
          icon: Icons.code_rounded,
          monospace: true,
        ),
    ],
    JsonSchemaNumberNode() => [
      if (node.minimum != null)
        _SchemaDetail(
          label: jsonSchemaKeywordLabel(context, 'minimum'),
          value: _formatNumber(node.minimum),
          icon: Icons.south_rounded,
        ),
      if (node.maximum != null)
        _SchemaDetail(
          label: jsonSchemaKeywordLabel(context, 'maximum'),
          value: _formatNumber(node.maximum),
          icon: Icons.north_rounded,
        ),
      if (node.exclusiveMinimum != null)
        _SchemaDetail(
          label: jsonSchemaKeywordLabel(context, 'exclusiveMinimum'),
          value: node.exclusiveMinimum! ? 'true' : 'false',
          icon: Icons.lock_open_rounded,
        ),
      if (node.exclusiveMaximum != null)
        _SchemaDetail(
          label: jsonSchemaKeywordLabel(context, 'exclusiveMaximum'),
          value: node.exclusiveMaximum! ? 'true' : 'false',
          icon: Icons.lock_outline_rounded,
        ),
      if (node.multipleOf != null)
        _SchemaDetail(
          label: jsonSchemaKeywordLabel(context, 'multipleOf'),
          value: _formatNumber(node.multipleOf),
          icon: Icons.grid_3x3_rounded,
        ),
    ],
    JsonSchemaBooleanNode() => [
      if (node.defaultValue != null)
        _SchemaDetail(
          label: jsonSchemaKeywordLabel(context, 'default'),
          value: node.defaultValue! ? 'true' : 'false',
          icon: Icons.toggle_on_rounded,
          monospace: true,
        ),
    ],
    JsonSchemaObjectNode() => const [],
    JsonSchemaArrayNode() => [
      if (node.minItems != null)
        _SchemaDetail(
          label: jsonSchemaKeywordLabel(context, 'minItems'),
          value: node.minItems.toString(),
          icon: Icons.format_list_numbered_rounded,
        ),
      if (node.maxItems != null)
        _SchemaDetail(
          label: jsonSchemaKeywordLabel(context, 'maxItems'),
          value: node.maxItems.toString(),
          icon: Icons.format_list_numbered_rtl_rounded,
        ),
      if (node.uniqueItems != null)
        _SchemaDetail(
          label: jsonSchemaKeywordLabel(context, 'uniqueItems'),
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

String _previewSchemaValue(BuildContext context, Object? value) {
  if (value == null || value is num || value is bool) {
    return _stringifySchemaValue(value);
  }
  if (value is String) {
    final singleLine = value.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (singleLine.length <= 36) {
      return singleLine;
    }
    return '${singleLine.substring(0, 35)}…';
  }
  if (value is List) {
    if (value.isEmpty) {
      return '[]';
    }
    return context.lazyTranslate(
      en: 'List (${value.length})',
      de: 'Liste (${value.length})',
      zh: '列表（${value.length}）',
    );
  }
  if (value is Map) {
    if (value.isEmpty) {
      return '{}';
    }
    return context.lazyTranslate(
      en: 'Object (${value.length})',
      de: 'Objekt (${value.length})',
      zh: '对象（${value.length}）',
    );
  }
  final text = value.toString().trim();
  if (text.length <= 36) {
    return text;
  }
  return '${text.substring(0, 35)}…';
}

String? _schemaValueInfoMessage({
  required BuildContext context,
  required Object? value,
  required String preview,
  String? description,
  bool showRawValue = true,
}) {
  final sections = <String>[];
  final trimmedDescription = description?.trim();
  if (trimmedDescription != null && trimmedDescription.isNotEmpty) {
    sections.add(trimmedDescription);
  }

  final fullValue = _stringifySchemaValue(value);
  if (showRawValue && fullValue != preview) {
    sections.add(
      context.lazyTranslate(en: 'Value: $fullValue', de: 'Wert: $fullValue', zh: '值：$fullValue'),
    );
  }

  if (sections.isEmpty) {
    return null;
  }
  return sections.join('\n\n');
}

class _ResolvedSchemaExtensionPreview {
  const _ResolvedSchemaExtensionPreview({
    required this.preview,
    this.description,
    this.showRawValueInInfo = true,
  });

  final String preview;
  final String? description;
  final bool showRawValueInInfo;
}

_ResolvedSchemaExtensionPreview _resolveSchemaExtensionPreview({
  required BuildContext context,
  required JsonSchemaEditorExtensionField? configuredField,
  required Object? value,
}) {
  if (configuredField == null || !configuredField.isStringEnum || value is! String) {
    return _ResolvedSchemaExtensionPreview(preview: _previewSchemaValue(context, value));
  }

  final normalizedValue = value.trim();
  if (normalizedValue.isEmpty) {
    return _ResolvedSchemaExtensionPreview(preview: _previewSchemaValue(context, value));
  }

  for (final entry in configuredField.availableEnumEntries) {
    if (entry.normalizedValue != normalizedValue) {
      continue;
    }
    return _ResolvedSchemaExtensionPreview(
      preview: entry.resolveDisplayLabel(context),
      description: entry.resolveDescription(context),
      showRawValueInInfo: false,
    );
  }

  return _ResolvedSchemaExtensionPreview(preview: _previewSchemaValue(context, value));
}

String? _joinSchemaExtensionDescriptions(String? first, String? second) {
  final values = [
    if (first != null && first.trim().isNotEmpty) first.trim(),
    if (second != null && second.trim().isNotEmpty) second.trim(),
  ];
  if (values.isEmpty) {
    return null;
  }
  return values.toSet().join('\n\n');
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
