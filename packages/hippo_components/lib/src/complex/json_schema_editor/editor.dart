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
import 'package:hippo_components/src/complex/json_schema_editor/widgets/json_schema_property_card.dart';
import 'package:hippo_utils/hippo_utils.dart';

import 'widgets/json_schema_editor_info_icon.dart';
import 'widgets/json_schema_editor_text_field.dart';
import 'widgets/json_schema_object_property_header.dart';
import 'widgets/json_schema_validation_panel.dart';

part 'parts/array.dart';
part 'parts/boolean.dart';
part 'parts/extensions.dart';
part 'parts/number.dart';
part 'parts/object.dart';
part 'parts/string.dart';

bool _isInternalSchemaExtensionKey(String key) {
  return key.trim() == jsonSchemaObjectPropertyOrderExtensionKey;
}

String? _schemaTypeHelp(JsonSchemaNodeType type) {
  return switch (type) {
    JsonSchemaNodeType.string => 'String: text value (e.g., names, labels, IDs).',
    JsonSchemaNodeType.integer => 'Integer: whole number without decimals.',
    JsonSchemaNodeType.number => 'Number: numeric value, including decimals.',
    JsonSchemaNodeType.boolean => 'Boolean: true/false value.',
    JsonSchemaNodeType.object => 'Object: map with named properties.',
    JsonSchemaNodeType.array => 'Array: ordered list of items.',
  };
}

const _jsonSchemaHelpByKeyword = {
  'const': 'Require this schema to match one exact JSON value.',
  'default': 'Default value used when the field is not supplied.',
  'type': 'Type of JSON value this node validates.',
  'title': 'Optional human-readable name for this schema node.',
  'description': 'Optional description shown in docs and editor tooling.',
  'allOf':
      'Combine this schema with every schema listed here. The instance must satisfy all of them.',
  'oneOf': 'Match exactly one schema from the listed alternatives.',
  r'$ref': 'Reference another schema by JSON Pointer, URI, or external schema location.',
  'minLength': 'Minimum number of characters allowed in the string.',
  'maxLength': 'Maximum number of characters allowed in the string.',
  'pattern': 'Regular expression pattern the string must match.',
  'enum': 'Allowed set of string values. Only one of these values is valid.',
  'minimum': 'Smallest allowed numeric value.',
  'maximum': 'Largest allowed numeric value.',
  'exclusiveMinimum': 'If true, value must be greater than minimum.',
  'exclusiveMaximum': 'If true, value must be less than maximum.',
  'multipleOf': 'Value must be a multiple of this number.',
  'minItems': 'Minimum number of items required in the array.',
  'maxItems': 'Maximum number of items allowed in the array.',
  'uniqueItems': 'All items must be unique across the array.',
  'additionalProperties': 'Allow properties not listed under "Properties" for this object.',
  'required': 'Whether this property must appear in the object.',
  'propertyKey': 'Property identifier used as key in the object.',
  'extensionField': 'Additional schema metadata entries (commonly namespaced as extension keys).',
  'properties': 'Property definitions for fields contained in the object.',
};

const _editorSectionSpacing = 8.0;

class _EditorSectionLabel extends StatelessWidget {
  const _EditorSectionLabel({required this.label, this.helpText});

  final String label;
  final String? helpText;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              if (helpText != null) ...[
                const Gap(4),
                JsonSchemaEditorInfoIcon(message: helpText, size: 15),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _EditorFieldWrap extends StatelessWidget {
  const _EditorFieldWrap({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    const minFieldWidth = 180.0;
    const maxColumns = 2;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite ? constraints.maxWidth : 600.0;
        final calculatedColumns = (availableWidth / minFieldWidth).floor().clamp(1, maxColumns);
        final widthForChild = calculatedColumns == 1
            ? availableWidth
            : (availableWidth - ((calculatedColumns - 1) * _editorSectionSpacing)) /
                  calculatedColumns;

        return Wrap(
          spacing: _editorSectionSpacing,
          runSpacing: _editorSectionSpacing,
          children: [for (final child in children) SizedBox(width: widthForChild, child: child)],
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
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? helpText;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderRadius = BorderRadius.circular(12);

    return InkWell(
      borderRadius: borderRadius,
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onChanged: (next) => onChanged(next ?? false),
            ),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            if (helpText != null) ...[
              const Gap(4),
              JsonSchemaEditorInfoIcon(message: helpText, size: 14),
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
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      icon: Icon(icon, size: 18),
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      onPressed: onPressed,
    );
  }
}

class _NodeTypeDropdown extends StatelessWidget {
  const _NodeTypeDropdown({required this.value, required this.onChanged, this.compact = false});

  final JsonSchemaNodeType value;
  final ValueChanged<JsonSchemaNodeType?> onChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 10, vertical: compact ? 5 : 2),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(compact ? 10 : 10),
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

class JsonSchemaEditor extends StatelessWidget {
  const JsonSchemaEditor({
    super.key,
    required this.controller,
    this.compactMode = false,
    this.title,
  });

  final JsonSchemaEditorController controller;
  final bool compactMode;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return DataSubjectBuilder<JsonSchemaNode>(
      subject: controller.schemaSubject,
      builder: (context, schema) {
        return DataSubjectBuilder<List<JsonSchemaDiagnostic>>(
          subject: controller.diagnosticsSubject,
          builder: (context, diagnostics) {
            return CustomScrollView(
              slivers: [
                SliverGap(16),
                if (title != null)
                  SliverChild(
                    maxWidth: 1400,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(title!, style: Theme.of(context).textTheme.titleMedium),
                    ),
                  ),
                SliverChild(
                  maxWidth: 1400,
                  child: _SchemaNodeEditor(
                    controller: controller,
                    node: schema,
                    featureOptions: controller.featureOptions,
                    path: const JsonSchemaPath.root(),
                    diagnostics: diagnostics,
                    compactMode: compactMode,
                    showContainer: false,
                  ),
                ),
                SliverGap(256),
              ],
            );
          },
        );
      },
    );
  }
}

class _SchemaNodeEditor extends StatelessWidget {
  const _SchemaNodeEditor({
    required this.controller,
    required this.node,
    required this.featureOptions,
    required this.path,
    required this.diagnostics,
    required this.compactMode,
    this.showHeader = true,
    this.showContainer = true,
    this.showPath = true,
  });

  final JsonSchemaEditorController controller;
  final JsonSchemaNode node;
  final JsonSchemaEditorFeatureOptions featureOptions;
  final JsonSchemaPath path;
  final List<JsonSchemaDiagnostic> diagnostics;
  final bool compactMode;
  final bool showHeader;
  final bool showContainer;
  final bool showPath;

  @override
  Widget build(BuildContext context) {
    final nodeDiagnostics = diagnostics.where((item) => item.path == path).toList();
    final configuredExtensions = controller
        .getConfiguredExtensions(node.type)
        .where((field) => !_isInternalSchemaExtensionKey(field.key))
        .toList(growable: false);
    final extensionEntries = <_ExtensionRowData>[];
    final configuredExtensionLookup = <String, JsonSchemaEditorExtensionField>{};
    for (final extension in configuredExtensions) {
      final key = extension.key.trim();
      if (key.isNotEmpty) {
        configuredExtensionLookup[key] = extension;
      }
    }
    for (final entry in node.extensions.entries) {
      final trimmedKey = entry.key.trim();
      if (trimmedKey.isEmpty || _isInternalSchemaExtensionKey(trimmedKey)) {
        continue;
      }
      final configuredField = configuredExtensionLookup[trimmedKey];
      extensionEntries.add(
        _ExtensionRowData(key: trimmedKey, value: entry.value, field: configuredField),
      );
    }
    final availableCapabilityOptions = _availableCapabilityOptions(
      node: node,
      path: path,
      controller: controller,
      featureOptions: featureOptions,
      configuredExtensions: configuredExtensions,
    );
    final hasVisibleNodeCapabilities = _hasVisibleNodeCapabilities(
      node: node,
      featureOptions: featureOptions,
    );
    final hasActiveCapabilitiesSection = extensionEntries.isNotEmpty || hasVisibleNodeCapabilities;
    final hasStructuralSections = _hasStructuralSections(node);
    final colorScheme = Theme.of(context).colorScheme;
    final typeBadgeColor = compactMode
        ? colorScheme.secondaryContainer.withValues(alpha: 0.55)
        : colorScheme.primaryContainer.withValues(alpha: 0.65);

    final nodeCapabilities = _buildNodeEditorSection(
      controller: controller,
      node: node,
      featureOptions: featureOptions,
      path: path,
      diagnostics: diagnostics,
      compactMode: compactMode,
      showCapabilities: true,
      showStructure: false,
    );
    final nodeStructure = _buildNodeEditorSection(
      controller: controller,
      node: node,
      featureOptions: featureOptions,
      path: path,
      diagnostics: diagnostics,
      compactMode: compactMode,
      showCapabilities: false,
      showStructure: true,
    );

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader) ...[
          Row(
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
                            _typeLabel(node.type),
                            style: Theme.of(
                              context,
                            ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const Gap(4),
                          JsonSchemaEditorInfoIcon(message: _schemaTypeHelp(node.type), size: 14),
                        ],
                      ),
                    ),
                    if (showPath && !path.isRoot) ...[
                      const Gap(6),
                      Text(
                        path.toString(),
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
              _NodeTypeDropdown(
                value: node.type,
                compact: compactMode,
                onChanged: (value) {
                  final nextType = value;
                  if (nextType == null) {
                    return;
                  }
                  final replacement = _replaceType(node: node, nextType: nextType);
                  controller.replaceNode(path: path, node: replacement);
                },
              ),
            ],
          ),
          const Gap(_editorSectionSpacing),
        ],
        _EditorFieldWrap(
          children: [
            JsonSchemaEditorTextField(
              value: node.title,
              hint: 'Title',
              helpText: _jsonSchemaHelpByKeyword['title'],
              onChanged: (value) => controller.updateNode(
                path: path,
                updater: (JsonSchemaNode current) => current.copyWith(title: value.trim()),
              ),
              onCleared: () => controller.updateNode(
                path: path,
                updater: (JsonSchemaNode current) => current.copyWith(title: null),
              ),
            ),
            JsonSchemaEditorTextField(
              value: node.description,
              hint: 'Description',
              maxLines: 3,
              helpText: _jsonSchemaHelpByKeyword['description'],
              onChanged: (value) => controller.updateNode(
                path: path,
                updater: (JsonSchemaNode current) => current.copyWith(description: value),
              ),
              onCleared: () => controller.updateNode(
                path: path,
                updater: (JsonSchemaNode current) => current.copyWith(description: null),
              ),
            ),
          ],
        ),
        if (nodeDiagnostics.isNotEmpty) ...[
          const Gap(_editorSectionSpacing),
          ...nodeDiagnostics.map((item) => JsonSchemaWarningBadge(message: item.message)),
        ],
        if (hasActiveCapabilitiesSection) ...[
          const Gap(_editorSectionSpacing),
          _EditorSectionLabel(
            label: 'Capabilities',
            helpText: _jsonSchemaHelpByKeyword['extensionField'],
          ),
          const Gap(6),
        ],
        if (extensionEntries.isNotEmpty) ...[
          ...extensionEntries.map(
            (entry) => _ExtensionNodeEditor(
              controller: controller,
              path: path,
              extensionKey: entry.key,
              extensionValue: entry.value,
              extensionField: entry.field,
            ),
          ),
        ],
        if (extensionEntries.isNotEmpty && hasVisibleNodeCapabilities) const Gap(6),
        if (hasVisibleNodeCapabilities) nodeCapabilities,
        if (availableCapabilityOptions.isNotEmpty) ...[
          if (hasActiveCapabilitiesSection) const Gap(_editorSectionSpacing),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () =>
                  _showAddCapabilityDialog(context: context, options: availableCapabilityOptions),
              icon: const Icon(Icons.add_circle_outline_rounded),
              label: const Text('Add capability'),
            ),
          ),
        ],
        if (hasStructuralSections) ...[
          if (hasActiveCapabilitiesSection || availableCapabilityOptions.isNotEmpty)
            const Gap(_editorSectionSpacing),
          nodeStructure,
        ],
      ],
    );

    if (!showContainer) {
      return content;
    }

    return Container(
      decoration: BoxDecoration(
        color: compactMode ? colorScheme.surfaceContainerLowest : colorScheme.surface,
        borderRadius: BorderRadius.circular(compactMode ? 12 : 16),
        border: Border.all(
          color: compactMode
              ? colorScheme.outlineVariant.withValues(alpha: 0.45)
              : colorScheme.outlineVariant.withValues(alpha: 0.7),
        ),
      ),
      child: Padding(padding: EdgeInsets.all(compactMode ? 8 : 10), child: content),
    );
  }

  JsonSchemaNode _replaceType({
    required JsonSchemaNode node,
    required JsonSchemaNodeType nextType,
  }) => _defaultNodeForTypePreservingMetadata(node, nextType);

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
}

Widget _buildNodeEditorSection({
  required JsonSchemaEditorController controller,
  required JsonSchemaNode node,
  required JsonSchemaEditorFeatureOptions featureOptions,
  required JsonSchemaPath path,
  required List<JsonSchemaDiagnostic> diagnostics,
  required bool compactMode,
  required bool showCapabilities,
  required bool showStructure,
}) {
  return switch (node) {
    JsonSchemaStringNode() => _StringNodeEditor(
      controller: controller,
      featureOptions: featureOptions,
      node: node,
      path: path,
      diagnostics: diagnostics,
      compactMode: compactMode,
      showCapabilities: showCapabilities,
      showStructure: showStructure,
    ),
    JsonSchemaBooleanNode() => _BooleanNodeEditor(
      controller: controller,
      node: node,
      path: path,
      diagnostics: diagnostics,
      compactMode: compactMode,
      showCapabilities: showCapabilities,
      showStructure: showStructure,
    ),
    JsonSchemaNumberNode() => _NumberNodeEditor(
      controller: controller,
      featureOptions: featureOptions,
      node: node,
      path: path,
      diagnostics: diagnostics,
      compactMode: compactMode,
      showCapabilities: showCapabilities,
      showStructure: showStructure,
    ),
    JsonSchemaObjectNode() => _ObjectNodeEditor(
      controller: controller,
      featureOptions: featureOptions,
      node: node,
      path: path,
      diagnostics: diagnostics,
      compactMode: compactMode,
      showCapabilities: showCapabilities,
      showStructure: showStructure,
    ),
    JsonSchemaArrayNode() => _ArrayNodeEditor(
      controller: controller,
      featureOptions: featureOptions,
      node: node,
      path: path,
      diagnostics: diagnostics,
      compactMode: compactMode,
      showCapabilities: showCapabilities,
      showStructure: showStructure,
    ),
  };
}

class _ExtensionRowData {
  const _ExtensionRowData({required this.key, required this.value, required this.field});

  final String key;
  final Object? value;
  final JsonSchemaEditorExtensionField? field;
}

class _CapabilityOption {
  const _CapabilityOption({
    required this.icon,
    required this.label,
    required this.description,
    required this.onSelected,
  });

  final IconData icon;
  final String label;
  final String description;
  final Future<void> Function(BuildContext context) onSelected;
}

Future<void> _showAddCapabilityDialog({
  required BuildContext context,
  required List<_CapabilityOption> options,
}) async {
  if (options.isEmpty) {
    return;
  }

  final sortedOptions = options.toList(growable: false)
    ..sort((left, right) => left.label.compareTo(right.label));

  final modal = AdaptiveCupertinoModal(
    barrierDismissible: true,
    builder: (dialogContext, isDesktop) {
      final colorScheme = Theme.of(dialogContext).colorScheme;

      return CupertinoModalPageContainer(
        title: const Text('Add capability'),
        child: Material(
          type: MaterialType.transparency,
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(isDesktop ? 24 : 16, 0, isDesktop ? 24 : 16, 8),
            itemCount: sortedOptions.length,
            itemBuilder: (context, index) {
              final option = sortedOptions[index];
              return Tile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                showArrowIndicator: true,
                leading: CircleAvatar(
                  radius: 18,
                  backgroundColor: colorScheme.secondaryContainer,
                  foregroundColor: colorScheme.onSecondaryContainer,
                  child: Icon(option.icon, size: 18),
                ),
                title: Text(option.label),
                subtitle: Text(option.description),
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    option.onSelected(context);
                  });
                },
              );
            },
          ),
        ),
      );
    },
  );

  await modal.show<void>(context);
}

List<_CapabilityOption> _availableCapabilityOptions({
  required JsonSchemaNode node,
  required JsonSchemaPath path,
  required JsonSchemaEditorController controller,
  required JsonSchemaEditorFeatureOptions featureOptions,
  required List<JsonSchemaEditorExtensionField> configuredExtensions,
}) {
  final options = <_CapabilityOption>[
    ..._nodeCapabilityOptions(
      node: node,
      path: path,
      controller: controller,
      featureOptions: featureOptions,
    ),
    ..._extensionCapabilityOptions(
      node: node,
      path: path,
      controller: controller,
      configuredExtensions: configuredExtensions,
    ),
  ];

  if (controller.extensionOptions.allowAddExtensions) {
    options.add(
      _CapabilityOption(
        icon: Icons.extension_rounded,
        label: 'Custom extension',
        description: 'Add a custom schema extension key/value entry.',
        onSelected: (context) => _showCustomExtensionDialog(
          context: context,
          controller: controller,
          path: path,
          existingExtensionKeys: node.extensions.keys
              .map((entry) => entry.trim())
              .where((entry) => !_isInternalSchemaExtensionKey(entry))
              .toSet(),
        ),
      ),
    );
  }

  return options;
}

bool _hasVisibleNodeCapabilities({
  required JsonSchemaNode node,
  required JsonSchemaEditorFeatureOptions featureOptions,
}) {
  return switch (node) {
    JsonSchemaStringNode() =>
      (featureOptions.stringMinLength && node.minLength != null) ||
          (featureOptions.stringMaxLength && node.maxLength != null) ||
          (featureOptions.stringPattern &&
              node.pattern != null &&
              node.pattern!.trim().isNotEmpty) ||
          (featureOptions.stringEnum && node.enumValues != null),
    JsonSchemaNumberNode() =>
      (featureOptions.numberMinimum && node.minimum != null) ||
          (featureOptions.numberMaximum && node.maximum != null) ||
          (featureOptions.numberExclusiveMinimum && node.exclusiveMinimum != null) ||
          (featureOptions.numberExclusiveMaximum && node.exclusiveMaximum != null) ||
          (featureOptions.numberMultipleOf && node.multipleOf != null),
    JsonSchemaBooleanNode() => node.defaultValue != null,
    JsonSchemaObjectNode() =>
      featureOptions.objectAdditionalProperties && !node.additionalProperties,
    JsonSchemaArrayNode() =>
      (featureOptions.arrayMinItems && node.minItems != null) ||
          (featureOptions.arrayMaxItems && node.maxItems != null) ||
          (featureOptions.arrayUniqueItems && node.uniqueItems != null),
  };
}

bool _hasStructuralSections(JsonSchemaNode node) {
  return switch (node) {
    JsonSchemaObjectNode() => true,
    JsonSchemaArrayNode() => true,
    _ => false,
  };
}

List<_CapabilityOption> _extensionCapabilityOptions({
  required JsonSchemaNode node,
  required JsonSchemaPath path,
  required JsonSchemaEditorController controller,
  required List<JsonSchemaEditorExtensionField> configuredExtensions,
}) {
  final options = <_CapabilityOption>[];
  for (final field in configuredExtensions) {
    final key = field.key.trim();
    if (key.isEmpty || node.extensions.containsKey(key)) {
      continue;
    }
    options.add(
      _CapabilityOption(
        icon: Icons.extension_rounded,
        label: key,
        description: field.normalizedDescription ?? 'Configured schema extension.',
        onSelected: (context) async {
          controller.setNodeField(path: path, key: key, value: _initialValueForField(field));
        },
      ),
    );
  }
  return options;
}

List<_CapabilityOption> _nodeCapabilityOptions({
  required JsonSchemaNode node,
  required JsonSchemaPath path,
  required JsonSchemaEditorController controller,
  required JsonSchemaEditorFeatureOptions featureOptions,
}) {
  return switch (node) {
    JsonSchemaStringNode() => [
      if (featureOptions.stringMinLength && node.minLength == null)
        _CapabilityOption(
          icon: Icons.straighten_rounded,
          label: 'Min length',
          description: _jsonSchemaHelpByKeyword['minLength']!,
          onSelected: (context) async => controller.updateNode(
            path: path,
            updater: (JsonSchemaStringNode node) => node.copyWith(minLength: 0),
          ),
        ),
      if (featureOptions.stringMaxLength && node.maxLength == null)
        _CapabilityOption(
          icon: Icons.width_normal_rounded,
          label: 'Max length',
          description: _jsonSchemaHelpByKeyword['maxLength']!,
          onSelected: (context) async => controller.updateNode(
            path: path,
            updater: (JsonSchemaStringNode node) => node.copyWith(maxLength: node.minLength ?? 1),
          ),
        ),
      if (featureOptions.stringPattern && (node.pattern == null || node.pattern!.trim().isEmpty))
        _CapabilityOption(
          icon: Icons.pattern_rounded,
          label: 'Pattern',
          description: _jsonSchemaHelpByKeyword['pattern']!,
          onSelected: (context) async => controller.updateNode(
            path: path,
            updater: (JsonSchemaStringNode node) => node.copyWith(pattern: '.*'),
          ),
        ),
      if (featureOptions.stringEnum && node.enumValues == null)
        _CapabilityOption(
          icon: Icons.list_alt_rounded,
          label: 'Enum',
          description: _jsonSchemaHelpByKeyword['enum']!,
          onSelected: (context) async => controller.updateNode(
            path: path,
            updater: (JsonSchemaStringNode node) => node.copyWith(enumValues: const ['value']),
          ),
        ),
    ],
    JsonSchemaNumberNode() => [
      if (featureOptions.numberMinimum && node.minimum == null)
        _CapabilityOption(
          icon: Icons.exposure_neg_1_rounded,
          label: 'Minimum',
          description: _jsonSchemaHelpByKeyword['minimum']!,
          onSelected: (context) async => controller.updateNode(
            path: path,
            updater: (JsonSchemaNumberNode node) => node.copyWith(minimum: 0),
          ),
        ),
      if (featureOptions.numberMaximum && node.maximum == null)
        _CapabilityOption(
          icon: Icons.exposure_plus_1_rounded,
          label: 'Maximum',
          description: _jsonSchemaHelpByKeyword['maximum']!,
          onSelected: (context) async => controller.updateNode(
            path: path,
            updater: (JsonSchemaNumberNode node) => node.copyWith(maximum: node.minimum ?? 1),
          ),
        ),
      if (featureOptions.numberExclusiveMinimum && node.exclusiveMinimum == null)
        _CapabilityOption(
          icon: Icons.chevron_left_rounded,
          label: 'Exclusive min',
          description: _jsonSchemaHelpByKeyword['exclusiveMinimum']!,
          onSelected: (context) async => controller.updateNode(
            path: path,
            updater: (JsonSchemaNumberNode node) => node.copyWith(exclusiveMinimum: false),
          ),
        ),
      if (featureOptions.numberExclusiveMaximum && node.exclusiveMaximum == null)
        _CapabilityOption(
          icon: Icons.chevron_right_rounded,
          label: 'Exclusive max',
          description: _jsonSchemaHelpByKeyword['exclusiveMaximum']!,
          onSelected: (context) async => controller.updateNode(
            path: path,
            updater: (JsonSchemaNumberNode node) => node.copyWith(exclusiveMaximum: false),
          ),
        ),
      if (featureOptions.numberMultipleOf && node.multipleOf == null)
        _CapabilityOption(
          icon: Icons.percent_rounded,
          label: 'Multiple of',
          description: _jsonSchemaHelpByKeyword['multipleOf']!,
          onSelected: (context) async => controller.updateNode(
            path: path,
            updater: (JsonSchemaNumberNode node) => node.copyWith(multipleOf: 1),
          ),
        ),
    ],
    JsonSchemaBooleanNode() => [
      if (node.defaultValue == null)
        _CapabilityOption(
          icon: Icons.toggle_on_rounded,
          label: 'Default',
          description: _jsonSchemaHelpByKeyword['default']!,
          onSelected: (context) async => controller.updateNode(
            path: path,
            updater: (JsonSchemaBooleanNode node) => node.copyWith(defaultValue: false),
          ),
        ),
    ],
    JsonSchemaObjectNode() => [
      if (featureOptions.objectAdditionalProperties && node.additionalProperties)
        _CapabilityOption(
          icon: Icons.data_object_rounded,
          label: 'Additional properties',
          description: _jsonSchemaHelpByKeyword['additionalProperties']!,
          onSelected: (context) async => controller.updateNode(
            path: path,
            updater: (JsonSchemaObjectNode node) => node.copyWith(additionalProperties: false),
          ),
        ),
    ],
    JsonSchemaArrayNode() => [
      if (featureOptions.arrayMinItems && node.minItems == null)
        _CapabilityOption(
          icon: Icons.format_list_numbered_rounded,
          label: 'Min items',
          description: _jsonSchemaHelpByKeyword['minItems']!,
          onSelected: (context) async => controller.updateNode(
            path: path,
            updater: (JsonSchemaArrayNode node) => node.copyWith(minItems: 0),
          ),
        ),
      if (featureOptions.arrayMaxItems && node.maxItems == null)
        _CapabilityOption(
          icon: Icons.format_list_numbered_rtl_rounded,
          label: 'Max items',
          description: _jsonSchemaHelpByKeyword['maxItems']!,
          onSelected: (context) async => controller.updateNode(
            path: path,
            updater: (JsonSchemaArrayNode node) => node.copyWith(maxItems: node.minItems ?? 1),
          ),
        ),
      if (featureOptions.arrayUniqueItems && node.uniqueItems == null)
        _CapabilityOption(
          icon: Icons.fingerprint_rounded,
          label: 'Unique items',
          description: _jsonSchemaHelpByKeyword['uniqueItems']!,
          onSelected: (context) async => controller.updateNode(
            path: path,
            updater: (JsonSchemaArrayNode node) => node.copyWith(uniqueItems: false),
          ),
        ),
    ],
  };
}

JsonSchemaNode _defaultNodeForTypePreservingMetadata(
  JsonSchemaNode node,
  JsonSchemaNodeType nextType,
) {
  return JsonSchemaNode.defaultForType(nextType, title: node.title, description: node.description);
}

void _updateInt(String value, void Function(int) onParsed, void Function() onClear) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    onClear();
    return;
  }
  final parsed = int.tryParse(trimmed);
  if (parsed == null) {
    return;
  }
  onParsed(parsed);
}

void _updateDouble(String value, void Function(double) onParsed, void Function() onClear) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    onClear();
    return;
  }
  final parsed = double.tryParse(trimmed);
  if (parsed == null) {
    return;
  }
  onParsed(parsed);
}

String _extensionValueAsString(Object? value) {
  if (value == null) {
    return '';
  }
  if (value is String) {
    return value;
  }
  return value.toString();
}

String _normalizeStringEnumValue({required String value, required List<String> allowedValues}) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return '';
  }
  return allowedValues.any((entry) => entry == trimmed) ? trimmed : '';
}

String? _stringEnumInput(List<String>? values) {
  if (values == null || values.isEmpty) {
    return null;
  }
  return values.join('\n');
}

List<String>? _readStringListFromText(String value) {
  final raw = value.trim();
  if (raw.isEmpty) {
    return null;
  }
  final split = raw.split(RegExp(r'[\n,]'));
  final values = <String>[];
  for (final entry in split) {
    final trimmed = entry.trim();
    if (trimmed.isNotEmpty && !values.contains(trimmed)) {
      values.add(trimmed);
    }
  }
  if (values.isEmpty) {
    return null;
  }
  return values;
}

String _jsonValueAsInput(Object? value) {
  final normalized = _normalizeJsonEditorValue(value);
  if (normalized is List || normalized is Map) {
    return const JsonEncoder.withIndent('  ').convert(normalized);
  }
  return jsonEncode(normalized);
}

Object? _normalizeJsonEditorValue(Object? value) {
  if (value is Map) {
    final normalized = <String, Object?>{};
    for (final entry in value.entries) {
      normalized[entry.key.toString()] = _normalizeJsonEditorValue(entry.value);
    }
    return normalized;
  }
  if (value is List) {
    return List<Object?>.unmodifiable(value.map(_normalizeJsonEditorValue));
  }
  return value;
}

void _updateJsonValue(
  String value,
  void Function(Object? value) onParsed,
  void Function() onClear,
) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    onClear();
    return;
  }
  try {
    onParsed(_normalizeJsonEditorValue(jsonDecode(trimmed)));
  } on FormatException {
    return;
  }
}

void _updateJsonArray(
  String value,
  void Function(List<Object?> value) onParsed,
  void Function() onClear,
) {
  _updateJsonValue(value, (parsed) {
    final normalized = _normalizeJsonEditorValue(parsed);
    if (normalized is! List) {
      return;
    }
    onParsed(List<Object?>.unmodifiable(normalized));
  }, onClear);
}
