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

import 'widgets/json_schema_editor_controls.dart';
import 'widgets/json_schema_editor_info_icon.dart';
import 'widgets/json_schema_editor_node_header.dart';
import 'widgets/json_schema_editor_text_field.dart';
import 'widgets/json_schema_object_property_header.dart';
import 'widgets/json_schema_validation_panel.dart';

part 'parts/array.dart';
part 'parts/boolean.dart';
part 'parts/capabilities.dart';
part 'parts/extensions.dart';
part 'parts/number.dart';
part 'parts/object.dart';
part 'parts/schema_info.dart';
part 'parts/string.dart';

bool _isInternalSchemaExtensionKey(String key) {
  return key.trim() == jsonSchemaObjectPropertyOrderExtensionKey;
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
          JsonSchemaEditorNodeHeader(
            nodeType: node.type,
            path: path,
            compactMode: compactMode,
            showPath: showPath,
            onTypeChanged: (nextType) => controller.replaceNode(
              path: path,
              node: _defaultNodeForTypePreservingMetadata(node, nextType),
            ),
          ),
          const Gap(_editorSectionSpacing),
        ],
        _SchemaInfoFields(controller: controller, node: node, path: path),
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

bool _hasStructuralSections(JsonSchemaNode node) {
  return switch (node) {
    JsonSchemaObjectNode() => true,
    JsonSchemaArrayNode() => true,
    _ => false,
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
