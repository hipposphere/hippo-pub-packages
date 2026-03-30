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

import 'widgets/json_schema_editor_info_icon.dart';
import 'widgets/json_schema_editor_text_field.dart';
import 'widgets/json_schema_validation_panel.dart';

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
  'default': 'Default value used when the field is not supplied.',
  'type': 'Type of JSON value this node validates.',
  'title': 'Optional human-readable name for this schema node.',
  'description': 'Optional description shown in docs and editor tooling.',
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
        padding: EdgeInsets.symmetric(horizontal: dense ? 8 : 8, vertical: dense ? 4 : 6),
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
      icon: Icon(icon, size: dense ? 18 : 18),
      visualDensity: VisualDensity.compact,
      constraints: BoxConstraints(minWidth: dense ? 36 : 32, minHeight: dense ? 36 : 32),
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
                  ),
                ),
                SliverGap(16),
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

class _ExtensionNodeEditor extends StatelessWidget {
  const _ExtensionNodeEditor({
    required this.controller,
    required this.path,
    required this.extensionKey,
    required this.extensionValue,
    required this.extensionField,
  });

  final JsonSchemaEditorController controller;
  final JsonSchemaPath path;
  final String extensionKey;
  final Object? extensionValue;
  final JsonSchemaEditorExtensionField? extensionField;

  @override
  Widget build(BuildContext context) {
    final fieldType = _resolveExtensionFieldType(
      extensionValue: extensionValue,
      configuredField: extensionField,
    );
    final helpText = extensionField?.normalizedDescription;

    return Padding(
      padding: const EdgeInsets.only(bottom: _editorSectionSpacing),
      child: switch (fieldType) {
        JsonSchemaEditorExtensionFieldType.string => _StringExtensionNodeField(
          controller: controller,
          path: path,
          extensionKey: extensionKey,
          extensionValue: _extensionValueAsString(extensionValue),
          helpText: helpText,
        ),
        JsonSchemaEditorExtensionFieldType.stringEnum => _StringEnumExtensionNodeField(
          controller: controller,
          path: path,
          extensionKey: extensionKey,
          extensionValue: _extensionValueAsString(extensionValue),
          values: extensionField?.availableEnumValues ?? const [],
          helpText: helpText,
        ),
        JsonSchemaEditorExtensionFieldType.number => _NumberExtensionNodeField(
          controller: controller,
          path: path,
          extensionKey: extensionKey,
          extensionValue: extensionValue,
          helpText: helpText,
        ),
        JsonSchemaEditorExtensionFieldType.boolean => _BooleanExtensionNodeField(
          controller: controller,
          path: path,
          extensionKey: extensionKey,
          extensionValue: extensionValue is bool ? (extensionValue as bool) : false,
          helpText: helpText,
        ),
      },
    );
  }
}

Future<void> _showCustomExtensionDialog({
  required BuildContext context,
  required JsonSchemaEditorController controller,
  required JsonSchemaPath path,
  required Set<String> existingExtensionKeys,
}) async {
  final keyController = TextEditingController();

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Add custom extension'),
        content: TextField(
          controller: keyController,
          decoration: const InputDecoration(labelText: 'Extension key'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final finalKey = keyController.text.trim();
              if (finalKey.isEmpty || existingExtensionKeys.contains(finalKey)) {
                return;
              }
              controller.setNodeField(path: path, key: finalKey, value: '');
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Add'),
          ),
        ],
      );
    },
  );
}

Object? _initialValueForField(JsonSchemaEditorExtensionField? field) {
  if (field == null) {
    return '';
  }
  if (field.defaultValue != null) {
    return field.defaultValue;
  }
  return switch (field.valueType) {
    JsonSchemaEditorExtensionFieldType.string => '',
    JsonSchemaEditorExtensionFieldType.stringEnum =>
      (field.availableEnumValues.isNotEmpty ? field.availableEnumValues.first : ''),
    JsonSchemaEditorExtensionFieldType.number => 0,
    JsonSchemaEditorExtensionFieldType.boolean => false,
  };
}

JsonSchemaEditorExtensionFieldType _resolveExtensionFieldType({
  required Object? extensionValue,
  required JsonSchemaEditorExtensionField? configuredField,
}) {
  if (configuredField != null) {
    if (configuredField.isStringEnum) {
      return configuredField.availableEnumValues.isNotEmpty
          ? JsonSchemaEditorExtensionFieldType.stringEnum
          : JsonSchemaEditorExtensionFieldType.string;
    }
    return configuredField.valueType;
  }

  if (extensionValue is bool) {
    return JsonSchemaEditorExtensionFieldType.boolean;
  }
  if (extensionValue is num) {
    return JsonSchemaEditorExtensionFieldType.number;
  }
  return JsonSchemaEditorExtensionFieldType.string;
}

class _BooleanExtensionNodeField extends StatelessWidget {
  const _BooleanExtensionNodeField({
    required this.controller,
    required this.path,
    required this.extensionKey,
    required this.extensionValue,
    this.helpText,
  });

  final JsonSchemaEditorController controller;
  final JsonSchemaPath path;
  final String extensionKey;
  final bool extensionValue;
  final String? helpText;

  @override
  Widget build(BuildContext context) {
    return _BooleanCapabilityField(
      label: extensionKey,
      value: extensionValue,
      helpText: helpText,
      onChanged: (value) {
        controller.setNodeField(path: path, key: extensionKey, value: value);
      },
      onCleared: () => controller.removeNodeField(path: path, key: extensionKey),
    );
  }
}

class _StringExtensionNodeField extends StatelessWidget {
  const _StringExtensionNodeField({
    required this.controller,
    required this.path,
    required this.extensionKey,
    required this.extensionValue,
    this.helpText,
  });

  final JsonSchemaEditorController controller;
  final JsonSchemaPath path;
  final String extensionKey;
  final String extensionValue;
  final String? helpText;

  @override
  Widget build(BuildContext context) {
    return _StringCapabilityField(
      value: extensionValue,
      hint: extensionKey,
      helpText: helpText,
      onChanged: (value) => controller.setNodeField(path: path, key: extensionKey, value: value),
      onEmpty: () => controller.removeNodeField(path: path, key: extensionKey),
      onRemove: () => controller.removeNodeField(path: path, key: extensionKey),
    );
  }
}

class _StringEnumExtensionNodeField extends StatelessWidget {
  const _StringEnumExtensionNodeField({
    required this.controller,
    required this.path,
    required this.extensionKey,
    required this.extensionValue,
    required this.values,
    this.helpText,
  });

  final JsonSchemaEditorController controller;
  final JsonSchemaPath path;
  final String extensionKey;
  final String extensionValue;
  final List<String> values;
  final String? helpText;

  @override
  Widget build(BuildContext context) {
    final valueEntries = values.where((item) => item.trim().isNotEmpty).toList(growable: false);
    final currentValue = _normalizeStringEnumValue(
      value: extensionValue,
      allowedValues: valueEntries,
    );

    return _DropdownCapabilityField(
      label: extensionKey,
      value: currentValue,
      values: valueEntries,
      helpText: helpText,
      onChanged: (value) {
        if (value == null || value.isEmpty) {
          controller.removeNodeField(path: path, key: extensionKey);
          return;
        }
        controller.setNodeField(path: path, key: extensionKey, value: value);
      },
      onRemove: () => controller.removeNodeField(path: path, key: extensionKey),
    );
  }
}

class _NumberExtensionNodeField extends StatelessWidget {
  const _NumberExtensionNodeField({
    required this.controller,
    required this.path,
    required this.extensionKey,
    required this.extensionValue,
    this.helpText,
  });

  final JsonSchemaEditorController controller;
  final JsonSchemaPath path;
  final String extensionKey;
  final Object? extensionValue;
  final String? helpText;

  @override
  Widget build(BuildContext context) {
    final value = extensionValue == null ? '' : extensionValue.toString();
    return _StringCapabilityField(
      value: value,
      hint: extensionKey,
      helpText: helpText,
      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
      onChanged: (next) => _updateDouble(
        next,
        (parsed) => controller.setNodeField(path: path, key: extensionKey, value: parsed),
        () => controller.removeNodeField(path: path, key: extensionKey),
      ),
      onEmpty: () => controller.removeNodeField(path: path, key: extensionKey),
      onRemove: () => controller.removeNodeField(path: path, key: extensionKey),
    );
  }
}

class _BooleanCapabilityField extends StatelessWidget {
  const _BooleanCapabilityField({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.onCleared,
    this.helpText,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final VoidCallback onCleared;
  final String? helpText;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CompactBooleanOption(label: label, value: value, helpText: helpText, onChanged: onChanged),
        const Spacer(),
        _EditorActionIconButton(
          tooltip: 'Remove capability',
          icon: Icons.close,
          onPressed: onCleared,
        ),
      ],
    );
  }
}

class _StringCapabilityField extends StatelessWidget {
  const _StringCapabilityField({
    required this.value,
    required this.hint,
    required this.onChanged,
    required this.onEmpty,
    required this.onRemove,
    this.helpText,
    this.maxLines = 1,
    this.keyboardType,
  });

  final String? value;
  final String hint;
  final ValueChanged<String> onChanged;
  final VoidCallback onEmpty;
  final VoidCallback onRemove;
  final String? helpText;
  final int maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: JsonSchemaEditorTextField(
            value: value,
            hint: hint,
            helpText: helpText,
            maxLines: maxLines,
            keyboardType: keyboardType,
            onChanged: onChanged,
            onCleared: onEmpty,
          ),
        ),
        const Gap(4),
        _EditorActionIconButton(
          tooltip: 'Remove capability',
          icon: Icons.close,
          onPressed: onRemove,
        ),
      ],
    );
  }
}

class _DropdownCapabilityField extends StatelessWidget {
  const _DropdownCapabilityField({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
    required this.onRemove,
    this.helpText,
  });

  final String label;
  final String? value;
  final List<String> values;
  final ValueChanged<String?> onChanged;
  final VoidCallback onRemove;
  final String? helpText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: value,
            isExpanded: true,
            isDense: true,
            decoration: InputDecoration(
              isDense: true,
              labelText: label,
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerLowest,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.7),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.7),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.2),
              ),
            ),
            items: <DropdownMenuItem<String>>[
              const DropdownMenuItem<String>(value: '', child: Text('Not set')),
              ...values.map((entry) => DropdownMenuItem<String>(value: entry, child: Text(entry))),
            ],
            onChanged: onChanged,
          ),
        ),
        if (helpText != null) ...[
          const Gap(4),
          JsonSchemaEditorInfoIcon(message: helpText!, size: 15),
        ],
        const Gap(4),
        _EditorActionIconButton(
          tooltip: 'Remove extension',
          icon: Icons.close,
          onPressed: onRemove,
        ),
      ],
    );
  }
}

class _StringNodeEditor extends StatelessWidget {
  const _StringNodeEditor({
    required this.controller,
    required this.featureOptions,
    required this.node,
    required this.path,
    required this.diagnostics,
    required this.compactMode,
    this.showCapabilities = true,
    this.showStructure = true,
  });

  final JsonSchemaEditorController controller;
  final JsonSchemaEditorFeatureOptions featureOptions;
  final JsonSchemaStringNode node;
  final JsonSchemaPath path;
  final List<JsonSchemaDiagnostic> diagnostics;
  final bool compactMode;
  final bool showCapabilities;
  final bool showStructure;

  @override
  Widget build(BuildContext context) {
    final shortFields = <Widget>[
      if (showCapabilities && featureOptions.stringMinLength && node.minLength != null)
        JsonSchemaEditorTextField(
          value: node.minLength?.toString(),
          hint: 'Min length',
          helpText: _jsonSchemaHelpByKeyword['minLength'],
          keyboardType: const TextInputType.numberWithOptions(),
          onChanged: (value) => _updateInt(
            value,
            (next) => controller.updateNode(
              path: path,
              updater: (JsonSchemaStringNode node) => node.copyWith(minLength: next),
            ),
            () => controller.updateNode(
              path: path,
              updater: (JsonSchemaStringNode node) => node.copyWith(clearMinLength: true),
            ),
          ),
        ),
      if (showCapabilities && featureOptions.stringMaxLength && node.maxLength != null)
        JsonSchemaEditorTextField(
          value: node.maxLength?.toString(),
          hint: 'Max length',
          helpText: _jsonSchemaHelpByKeyword['maxLength'],
          keyboardType: const TextInputType.numberWithOptions(),
          onChanged: (value) => _updateInt(
            value,
            (next) => controller.updateNode(
              path: path,
              updater: (JsonSchemaStringNode node) => node.copyWith(maxLength: next),
            ),
            () => controller.updateNode(
              path: path,
              updater: (JsonSchemaStringNode node) => node.copyWith(clearMaxLength: true),
            ),
          ),
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (shortFields.isNotEmpty) ...[
          _EditorFieldWrap(children: shortFields),
          const Gap(_editorSectionSpacing),
        ],
        if (showCapabilities &&
            featureOptions.stringPattern &&
            node.pattern != null &&
            node.pattern!.trim().isNotEmpty) ...[
          JsonSchemaEditorTextField(
            value: node.pattern,
            hint: 'Pattern (RegExp)',
            helpText: _jsonSchemaHelpByKeyword['pattern'],
            onChanged: (value) => controller.updateNode(
              path: path,
              updater: (JsonSchemaStringNode node) => node.copyWith(pattern: value),
            ),
            onCleared: () => controller.updateNode(
              path: path,
              updater: (JsonSchemaStringNode node) => node.copyWith(clearPattern: true),
            ),
          ),
          const Gap(_editorSectionSpacing),
        ],
        if (showCapabilities && featureOptions.stringEnum && node.enumValues != null) ...[
          _StringCapabilityField(
            value: _stringEnumInput(node.enumValues),
            hint: 'Enum (comma/line list)',
            helpText: _jsonSchemaHelpByKeyword['enum'],
            maxLines: 3,
            onChanged: (value) {
              final next = _readStringListFromText(value) ?? const <String>[];
              controller.updateNode(
                path: path,
                updater: (JsonSchemaStringNode node) => node.copyWith(enumValues: next),
              );
            },
            onEmpty: () => controller.updateNode(
              path: path,
              updater: (JsonSchemaStringNode node) => node.copyWith(enumValues: const []),
            ),
            onRemove: () => controller.updateNode(
              path: path,
              updater: (JsonSchemaStringNode node) => node.copyWith(clearEnumValues: true),
            ),
          ),
          const Gap(_editorSectionSpacing),
        ],
        if (showStructure) const SizedBox.shrink(),
      ],
    );
  }
}

class _NumberNodeEditor extends StatelessWidget {
  const _NumberNodeEditor({
    required this.controller,
    required this.featureOptions,
    required this.node,
    required this.path,
    required this.diagnostics,
    required this.compactMode,
    this.showCapabilities = true,
    this.showStructure = true,
  });

  final JsonSchemaEditorController controller;
  final JsonSchemaEditorFeatureOptions featureOptions;
  final JsonSchemaNumberNode node;
  final JsonSchemaPath path;
  final List<JsonSchemaDiagnostic> diagnostics;
  final bool compactMode;
  final bool showCapabilities;
  final bool showStructure;

  @override
  Widget build(BuildContext context) {
    final shortFields = <Widget>[
      if (showCapabilities && featureOptions.numberMinimum && node.minimum != null)
        JsonSchemaEditorTextField(
          value: node.minimum?.toString(),
          hint: 'Minimum',
          helpText: _jsonSchemaHelpByKeyword['minimum'],
          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
          onChanged: (value) => _updateDouble(
            value,
            (next) => controller.updateNode(
              path: path,
              updater: (JsonSchemaNumberNode node) => node.copyWith(minimum: next),
            ),
            () => controller.updateNode(
              path: path,
              updater: (JsonSchemaNumberNode node) => node.copyWith(clearMinimum: true),
            ),
          ),
        ),
      if (showCapabilities && featureOptions.numberMaximum && node.maximum != null)
        JsonSchemaEditorTextField(
          value: node.maximum?.toString(),
          hint: 'Maximum',
          helpText: _jsonSchemaHelpByKeyword['maximum'],
          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
          onChanged: (value) => _updateDouble(
            value,
            (next) => controller.updateNode(
              path: path,
              updater: (JsonSchemaNumberNode node) => node.copyWith(maximum: next),
            ),
            () => controller.updateNode(
              path: path,
              updater: (JsonSchemaNumberNode node) => node.copyWith(clearMaximum: true),
            ),
          ),
        ),
      if (showCapabilities && featureOptions.numberMultipleOf && node.multipleOf != null)
        JsonSchemaEditorTextField(
          value: node.multipleOf?.toString(),
          hint: 'Multiple of',
          helpText: _jsonSchemaHelpByKeyword['multipleOf'],
          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
          onChanged: (value) => _updateDouble(
            value,
            (next) => controller.updateNode(
              path: path,
              updater: (JsonSchemaNumberNode node) => node.copyWith(multipleOf: next),
            ),
            () => controller.updateNode(
              path: path,
              updater: (JsonSchemaNumberNode node) => node.copyWith(clearMultipleOf: true),
            ),
          ),
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (shortFields.isNotEmpty) ...[
          _EditorFieldWrap(children: shortFields),
          const Gap(_editorSectionSpacing),
        ],
        if (showCapabilities &&
            featureOptions.numberExclusiveMinimum &&
            node.exclusiveMinimum != null) ...[
          _BooleanCapabilityField(
            label: 'Exclusive min',
            value: node.exclusiveMinimum!,
            helpText: _jsonSchemaHelpByKeyword['exclusiveMinimum'],
            onChanged: (value) => controller.updateNode(
              path: path,
              updater: (JsonSchemaNumberNode node) => node.copyWith(exclusiveMinimum: value),
            ),
            onCleared: () => controller.updateNode(
              path: path,
              updater: (JsonSchemaNumberNode node) => node.copyWith(clearExclusiveMinimum: true),
            ),
          ),
          const Gap(_editorSectionSpacing),
        ],
        if (showCapabilities &&
            featureOptions.numberExclusiveMaximum &&
            node.exclusiveMaximum != null) ...[
          _BooleanCapabilityField(
            label: 'Exclusive max',
            value: node.exclusiveMaximum!,
            helpText: _jsonSchemaHelpByKeyword['exclusiveMaximum'],
            onChanged: (value) => controller.updateNode(
              path: path,
              updater: (JsonSchemaNumberNode node) => node.copyWith(exclusiveMaximum: value),
            ),
            onCleared: () => controller.updateNode(
              path: path,
              updater: (JsonSchemaNumberNode node) => node.copyWith(clearExclusiveMaximum: true),
            ),
          ),
          const Gap(_editorSectionSpacing),
        ],
        if (showStructure) const SizedBox.shrink(),
      ],
    );
  }
}

class _BooleanNodeEditor extends StatelessWidget {
  const _BooleanNodeEditor({
    required this.controller,
    required this.node,
    required this.path,
    required this.diagnostics,
    required this.compactMode,
    this.showCapabilities = true,
    this.showStructure = true,
  });

  final JsonSchemaEditorController controller;
  final JsonSchemaBooleanNode node;
  final JsonSchemaPath path;
  final List<JsonSchemaDiagnostic> diagnostics;
  final bool compactMode;
  final bool showCapabilities;
  final bool showStructure;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showCapabilities && node.defaultValue != null)
          _BooleanCapabilityField(
            label: 'Default true',
            value: node.defaultValue!,
            helpText: _jsonSchemaHelpByKeyword['default'],
            onChanged: (value) => controller.updateNode(
              path: path,
              updater: (JsonSchemaBooleanNode node) => node.copyWith(defaultValue: value),
            ),
            onCleared: () => controller.updateNode(
              path: path,
              updater: (JsonSchemaBooleanNode node) => node.copyWith(clearDefaultValue: true),
            ),
          ),
        if (showStructure) const SizedBox.shrink(),
      ],
    );
  }
}

class _ObjectNodeEditor extends StatelessWidget {
  const _ObjectNodeEditor({
    required this.controller,
    required this.featureOptions,
    required this.node,
    required this.path,
    required this.diagnostics,
    required this.compactMode,
    this.showCapabilities = true,
    this.showStructure = true,
  });

  final JsonSchemaEditorController controller;
  final JsonSchemaEditorFeatureOptions featureOptions;
  final JsonSchemaObjectNode node;
  final JsonSchemaPath path;
  final List<JsonSchemaDiagnostic> diagnostics;
  final bool compactMode;
  final bool showCapabilities;
  final bool showStructure;

  @override
  Widget build(BuildContext context) {
    final propertyEntries = node.orderedPropertyEntries.toList(growable: false);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showCapabilities &&
            featureOptions.objectAdditionalProperties &&
            !node.additionalProperties) ...[
          _BooleanCapabilityField(
            label: 'Additional props',
            value: node.additionalProperties,
            helpText: _jsonSchemaHelpByKeyword['additionalProperties'],
            onChanged: (value) => controller.updateNode(
              path: path,
              updater: (JsonSchemaObjectNode node) => node.copyWith(additionalProperties: value),
            ),
            onCleared: () => controller.updateNode(
              path: path,
              updater: (JsonSchemaObjectNode node) =>
                  node.copyWith(clearAdditionalProperties: true),
            ),
          ),
          const Gap(_editorSectionSpacing),
        ],
        if (showStructure) ...[
          Wrap(
            spacing: _editorSectionSpacing,
            runSpacing: _editorSectionSpacing,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _EditorSectionLabel(
                label: 'Properties',
                helpText: _jsonSchemaHelpByKeyword['properties'],
              ),
            ],
          ),
          const Gap(_editorSectionSpacing),
        ],
        if (showStructure && propertyEntries.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.7)),
            ),
            child: Text(
              'No properties defined yet.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ),
        if (showStructure)
          ...List.generate(propertyEntries.length, (index) {
            final entry = propertyEntries[index];
            final propertyPath = path.childProperty(entry.key);
            final propertyNode = entry.value;
            final required = node.required.contains(entry.key);
            final propertyWarnings = diagnostics
                .where((item) => item.path == propertyPath)
                .toList();
            final propertyHeader = LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth >= 760;
                final trailingChildren = <Widget>[
                  _NodeTypeDropdown(
                    value: propertyNode.type,
                    compact: true,
                    onChanged: (value) {
                      final nextType = value;
                      if (nextType == null) {
                        return;
                      }
                      controller.replaceNode(
                        path: propertyPath,
                        node: _defaultNodeForTypePreservingMetadata(propertyNode, nextType),
                      );
                    },
                  ),
                  _CompactBooleanOption(
                    label: 'Required',
                    value: required,
                    helpText: _jsonSchemaHelpByKeyword['required'],
                    dense: isDesktop,
                    onChanged: (nextRequired) => controller.setRequired(
                      objectPath: path,
                      key: entry.key,
                      required: nextRequired,
                    ),
                  ),
                  _EditorActionIconButton(
                    tooltip: 'Move property up',
                    icon: Icons.arrow_upward_rounded,
                    dense: isDesktop,
                    onPressed: index == 0
                        ? null
                        : () => controller.movePropertyUp(objectPath: path, key: entry.key),
                  ),
                  _EditorActionIconButton(
                    tooltip: 'Move property down',
                    icon: Icons.arrow_downward_rounded,
                    dense: isDesktop,
                    onPressed: index == propertyEntries.length - 1
                        ? null
                        : () => controller.movePropertyDown(objectPath: path, key: entry.key),
                  ),
                  _EditorActionIconButton(
                    tooltip: 'Remove property',
                    icon: Icons.delete_outline,
                    dense: isDesktop,
                    onPressed: () => controller.removeProperty(objectPath: path, key: entry.key),
                  ),
                ];
                final trailingRow = isDesktop
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
                  value: entry.key,
                  hint: 'Property key',
                  helpText: _jsonSchemaHelpByKeyword['propertyKey'],
                  onChanged: (value) {
                    final nextKey = value.trim();
                    if (nextKey.isEmpty || nextKey == entry.key) {
                      return;
                    }
                    controller.renameProperty(
                      objectPath: path,
                      currentKey: entry.key,
                      nextKey: nextKey,
                    );
                  },
                  debounceDelay: const Duration(milliseconds: 450),
                  onSubmitted: (value) {
                    final nextKey = value.trim();
                    if (nextKey.isEmpty || nextKey == entry.key) {
                      return;
                    }
                    controller.renameProperty(
                      objectPath: path,
                      currentKey: entry.key,
                      nextKey: nextKey,
                    );
                  },
                  onCleared: () {},
                );

                if (isDesktop) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: propertyKeyField),
                      const Gap(8),
                      trailingRow,
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [propertyKeyField, const Gap(6), trailingRow],
                );
              },
            );

            final propertyDetails = Container(
              key: ValueKey('property-card-${entry.key}'),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.8)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (propertyWarnings.isNotEmpty) ...[
                    ...propertyWarnings.map(
                      (item) => JsonSchemaWarningBadge(message: item.message),
                    ),
                    const Gap(6),
                  ],
                  _SchemaNodeEditor(
                    controller: controller,
                    featureOptions: featureOptions,
                    node: propertyNode,
                    path: propertyPath,
                    diagnostics: diagnostics,
                    compactMode: true,
                    showHeader: false,
                    showContainer: false,
                    showPath: false,
                  ),
                ],
              ),
            );

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [propertyHeader, Gap(4), propertyDetails, Gap(16)],
              ),
            );
          }),
        if (showStructure)
          Button(
            onTap: () {
              controller.addProperty(
                objectPath: path,
                key: 'property',
                node: const JsonSchemaStringNode(),
              );
            },
            type: ButtonType.secondary,
            prefix: const Icon(Icons.add_rounded),
            label: 'Add property',
          ),
      ],
    );
  }
}

class _ArrayNodeEditor extends StatelessWidget {
  const _ArrayNodeEditor({
    required this.controller,
    required this.featureOptions,
    required this.node,
    required this.path,
    required this.diagnostics,
    required this.compactMode,
    this.showCapabilities = true,
    this.showStructure = true,
  });

  final JsonSchemaEditorController controller;
  final JsonSchemaEditorFeatureOptions featureOptions;
  final JsonSchemaArrayNode node;
  final JsonSchemaPath path;
  final List<JsonSchemaDiagnostic> diagnostics;
  final bool compactMode;
  final bool showCapabilities;
  final bool showStructure;

  @override
  Widget build(BuildContext context) {
    final shortFields = <Widget>[
      if (showCapabilities && featureOptions.arrayMinItems && node.minItems != null)
        JsonSchemaEditorTextField(
          value: node.minItems?.toString(),
          hint: 'Min items',
          helpText: _jsonSchemaHelpByKeyword['minItems'],
          keyboardType: const TextInputType.numberWithOptions(),
          onChanged: (value) => _updateInt(
            value,
            (next) => controller.updateNode(
              path: path,
              updater: (JsonSchemaArrayNode node) => node.copyWith(minItems: next),
            ),
            () => controller.updateNode(
              path: path,
              updater: (JsonSchemaArrayNode node) => node.copyWith(clearMinItems: true),
            ),
          ),
        ),
      if (showCapabilities && featureOptions.arrayMaxItems && node.maxItems != null)
        JsonSchemaEditorTextField(
          value: node.maxItems?.toString(),
          hint: 'Max items',
          helpText: _jsonSchemaHelpByKeyword['maxItems'],
          keyboardType: const TextInputType.numberWithOptions(),
          onChanged: (value) => _updateInt(
            value,
            (next) => controller.updateNode(
              path: path,
              updater: (JsonSchemaArrayNode node) => node.copyWith(maxItems: next),
            ),
            () => controller.updateNode(
              path: path,
              updater: (JsonSchemaArrayNode node) => node.copyWith(clearMaxItems: true),
            ),
          ),
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (shortFields.isNotEmpty) ...[
          _EditorFieldWrap(children: shortFields),
          const Gap(_editorSectionSpacing),
        ],
        if (showCapabilities && featureOptions.arrayUniqueItems && node.uniqueItems != null) ...[
          _BooleanCapabilityField(
            label: 'Unique items',
            value: node.uniqueItems!,
            helpText: _jsonSchemaHelpByKeyword['uniqueItems'],
            onChanged: (value) => controller.updateNode(
              path: path,
              updater: (JsonSchemaArrayNode node) => node.copyWith(uniqueItems: value),
            ),
            onCleared: () => controller.updateNode(
              path: path,
              updater: (JsonSchemaArrayNode node) => node.copyWith(clearUniqueItems: true),
            ),
          ),
          const Gap(_editorSectionSpacing),
        ],
        if (showStructure) ...[
          const Divider(height: 20),
          const _EditorSectionLabel(label: 'Item schema'),
          const Gap(6),
          _SchemaNodeEditor(
            controller: controller,
            featureOptions: featureOptions,
            node: node.items,
            path: path.childItems(),
            diagnostics: diagnostics,
            compactMode: true,
          ),
        ],
      ],
    );
  }
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

/// TODO (v2): add support for `const`, `allOf` / `oneOf` / `$ref`
/// and external schema references for full Draft-2020-12 authoring.
