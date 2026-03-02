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

import 'widgets/json_schema_validation_panel.dart';

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
            return _buildEditor(context, schema, diagnostics);
          },
        );
      },
    );
  }

  Widget _buildEditor(
    BuildContext context,
    JsonSchemaNode schema,
    List<JsonSchemaDiagnostic> diagnostics,
  ) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(title!, style: Theme.of(context).textTheme.titleMedium),
              ),
            _SchemaNodeEditor(
              controller: controller,
              node: schema,
              featureOptions: controller.featureOptions,
              path: const JsonSchemaPath.root(),
              diagnostics: diagnostics,
              compactMode: compactMode,
            ),
          ],
        ),
      ),
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
  });

  final JsonSchemaEditorController controller;
  final JsonSchemaNode node;
  final JsonSchemaEditorFeatureOptions featureOptions;
  final JsonSchemaPath path;
  final List<JsonSchemaDiagnostic> diagnostics;
  final bool compactMode;

  @override
  Widget build(BuildContext context) {
    final nodeDiagnostics = diagnostics.where((item) => item.path == path).toList();
    final configuredExtensions = controller.getConfiguredExtensions(node.type);
    final extensionEntries = <_ExtensionRowData>[];
    final configuredExtensionLookup = <String, JsonSchemaEditorExtensionField>{};
    for (final extension in configuredExtensions) {
      final key = extension.key.trim();
      if (key.isNotEmpty) {
        configuredExtensionLookup[key] = extension;
      }
    }
    for (final extension in configuredExtensions) {
      final key = extension.key.trim();
      if (key.isEmpty) {
        continue;
      }
      final hasValue = node.extensions.containsKey(key);
      extensionEntries.add(
        _ExtensionRowData(
          key: key,
          value: hasValue ? node.extensions[key] : extension.defaultValue,
          isConfigured: true,
          isImplemented: hasValue,
          field: extension,
        ),
      );
    }
    if (configuredExtensionLookup.isNotEmpty) {
      for (final entry in node.extensions.entries) {
        if (!configuredExtensionLookup.containsKey(entry.key)) {
          extensionEntries.add(
            _ExtensionRowData(
              key: entry.key,
              value: entry.value,
              isConfigured: false,
              isImplemented: true,
              field: null,
            ),
          );
        }
      }
    } else {
      for (final entry in node.extensions.entries) {
        extensionEntries.add(
          _ExtensionRowData(
            key: entry.key,
            value: entry.value,
            isConfigured: false,
            isImplemented: true,
            field: null,
          ),
        );
      }
    }
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(_typeLabel(node.type), style: Theme.of(context).textTheme.titleSmall),
                DropdownButton<JsonSchemaNodeType>(
                  value: node.type,
                  items: JsonSchemaNodeType.values
                      .map((type) => DropdownMenuItem(value: type, child: Text(_typeLabel(type))))
                      .toList(),
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
            const Gap(12),
            _SchemaTextField(
              value: node.title,
              hint: 'Title',
              onChanged: (value) => controller.updateNode(
                path: path,
                updater: (JsonSchemaNode current) => current.copyWith(title: value.trim()),
              ),
              onCleared: () => controller.updateNode(
                path: path,
                updater: (JsonSchemaNode current) => current.copyWith(title: null),
              ),
            ),
            const Gap(6),
            _SchemaTextField(
              value: node.description,
              hint: 'Description',
              maxLines: 3,
              onChanged: (value) => controller.updateNode(
                path: path,
                updater: (JsonSchemaNode current) => current.copyWith(description: value),
              ),
              onCleared: () => controller.updateNode(
                path: path,
                updater: (JsonSchemaNode current) => current.copyWith(description: null),
              ),
            ),
            if (nodeDiagnostics.isNotEmpty) ...[
              const Gap(8),
              ...nodeDiagnostics.map((item) => JsonSchemaWarningBadge(message: item.message)),
            ],
            if (extensionEntries.isNotEmpty ||
                (configuredExtensions.isNotEmpty && controller.extensionOptions.allowAddExtensions)) ...[
              const Gap(12),
              const Text('Extensions'),
              const Gap(8),
              ...extensionEntries.map(
                (entry) => _ExtensionNodeEditor(
                  controller: controller,
                  path: path,
                  extensionKey: entry.key,
                  extensionValue: entry.value,
                  isConfigured: entry.isConfigured,
                  isImplemented: entry.isImplemented,
                  extensionField: entry.field,
                ),
              ),
              if (controller.extensionOptions.allowAddExtensions)
                _AddExtensionNodeField(
                  controller: controller,
                  path: path,
                  configuredExtensions: configuredExtensions,
                  existingExtensionKeys: node.extensions.keys.map((entry) => entry.trim()).toSet(),
                ),
            ],
            const Gap(12),
            switch (node) {
              JsonSchemaStringNode() => _StringNodeEditor(
                controller: controller,
                featureOptions: featureOptions,
                node: node as JsonSchemaStringNode,
                path: path,
                diagnostics: diagnostics,
                compactMode: compactMode,
              ),
              JsonSchemaBooleanNode() => _BooleanNodeEditor(
                controller: controller,
                node: node as JsonSchemaBooleanNode,
                path: path,
                diagnostics: diagnostics,
                compactMode: compactMode,
              ),
              JsonSchemaNumberNode() => _NumberNodeEditor(
                controller: controller,
                featureOptions: featureOptions,
                node: node as JsonSchemaNumberNode,
                path: path,
                diagnostics: diagnostics,
                compactMode: compactMode,
              ),
              JsonSchemaObjectNode() => _ObjectNodeEditor(
                controller: controller,
                featureOptions: featureOptions,
                node: node as JsonSchemaObjectNode,
                path: path,
                diagnostics: diagnostics,
                compactMode: compactMode,
              ),
              JsonSchemaArrayNode() => _ArrayNodeEditor(
                controller: controller,
                featureOptions: featureOptions,
                node: node as JsonSchemaArrayNode,
                path: path,
                diagnostics: diagnostics,
                compactMode: compactMode,
              ),
            },
          ],
        ),
      ),
    );
  }

  JsonSchemaNode _replaceType({
    required JsonSchemaNode node,
    required JsonSchemaNodeType nextType,
  }) {
    final title = node.title;
    final description = node.description;
    return switch (nextType) {
      JsonSchemaNodeType.string => JsonSchemaNode.defaultForType(
        JsonSchemaNodeType.string,
        title: title,
        description: description,
      ),
      JsonSchemaNodeType.boolean => JsonSchemaNode.defaultForType(
        JsonSchemaNodeType.boolean,
        title: title,
        description: description,
      ),
      JsonSchemaNodeType.number => JsonSchemaNode.defaultForType(
        JsonSchemaNodeType.number,
        title: title,
        description: description,
      ),
      JsonSchemaNodeType.integer => JsonSchemaNode.defaultForType(
        JsonSchemaNodeType.integer,
        title: title,
        description: description,
      ),
      JsonSchemaNodeType.object => JsonSchemaNode.defaultForType(
        JsonSchemaNodeType.object,
        title: title,
        description: description,
      ),
      JsonSchemaNodeType.array => JsonSchemaNode.defaultForType(
        JsonSchemaNodeType.array,
        title: title,
        description: description,
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
}

class _ExtensionRowData {
  const _ExtensionRowData({
    required this.key,
    required this.value,
    required this.isConfigured,
    required this.isImplemented,
    required this.field,
  });

  final String key;
  final Object? value;
  final bool isConfigured;
  final bool isImplemented;
  final JsonSchemaEditorExtensionField? field;
}

class _ExtensionNodeEditor extends StatelessWidget {
  const _ExtensionNodeEditor({
    required this.controller,
    required this.path,
    required this.extensionKey,
    required this.extensionValue,
    required this.isConfigured,
    required this.isImplemented,
    required this.extensionField,
  });

  final JsonSchemaEditorController controller;
  final JsonSchemaPath path;
  final String extensionKey;
  final Object? extensionValue;
  final bool isConfigured;
  final bool isImplemented;
  final JsonSchemaEditorExtensionField? extensionField;

  @override
  Widget build(BuildContext context) {
    final fieldType = _resolveExtensionFieldType(
      extensionValue: extensionValue,
      configuredField: extensionField,
    );
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(extensionKey, style: Theme.of(context).textTheme.titleSmall)),
              _ExtensionStateBadge(isConfigured: isConfigured, isImplemented: isImplemented),
            ],
          ),
          const Gap(8),
          switch (fieldType) {
            JsonSchemaEditorExtensionFieldType.string => _StringExtensionNodeField(
              controller: controller,
              path: path,
              extensionKey: extensionKey,
              extensionValue: _extensionValueAsString(extensionValue),
            ),
            JsonSchemaEditorExtensionFieldType.stringEnum => _StringEnumExtensionNodeField(
              controller: controller,
              path: path,
              extensionKey: extensionKey,
              extensionValue: _extensionValueAsString(extensionValue),
              values: extensionField?.availableEnumValues ?? const [],
            ),
            JsonSchemaEditorExtensionFieldType.number => _NumberExtensionNodeField(
              controller: controller,
              path: path,
              extensionKey: extensionKey,
              extensionValue: extensionValue,
            ),
            JsonSchemaEditorExtensionFieldType.boolean => _BooleanExtensionNodeField(
              controller: controller,
              path: path,
              extensionKey: extensionKey,
              extensionValue: extensionValue is bool ? (extensionValue as bool) : false,
            ),
          },
        ],
      ),
    );
  }
}

class _AddExtensionNodeField extends StatelessWidget {
  const _AddExtensionNodeField({
    required this.controller,
    required this.path,
    required this.configuredExtensions,
    required this.existingExtensionKeys,
  });

  final JsonSchemaEditorController controller;
  final JsonSchemaPath path;
  final List<JsonSchemaEditorExtensionField> configuredExtensions;
  final Set<String> existingExtensionKeys;

  @override
  Widget build(BuildContext context) {
    final availableConfigured = configuredExtensions
        .where(
          (field) =>
              field.key.trim().isNotEmpty && !existingExtensionKeys.contains(field.key.trim()),
        )
        .toList(growable: false);

    return TextButton.icon(
      onPressed: () {
        _showAddExtensionDialog(
          context: context,
          availableConfiguredExtensions: availableConfigured,
          onAdd: (key, field) {
            final trimmedKey = key.trim();
            if (trimmedKey.isEmpty || existingExtensionKeys.contains(trimmedKey)) {
              return;
            }
            controller.setNodeField(
              path: path,
              key: trimmedKey,
              value: _initialValueForField(field),
            );
          },
        );
      },
      icon: const Icon(Icons.add),
      label: const Text('Add extension'),
    );
  }

  void _showAddExtensionDialog({
    required BuildContext context,
    required List<JsonSchemaEditorExtensionField> availableConfiguredExtensions,
    required void Function(String, JsonSchemaEditorExtensionField?) onAdd,
  }) {
    String? selectedConfiguredKey;
    final keyController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add extension field'),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              final trimmedKey = keyController.text.trim();
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (availableConfiguredExtensions.isNotEmpty)
                    DropdownButton<String>(
                      isExpanded: true,
                      hint: const Text('Select configured extension'),
                      value: selectedConfiguredKey,
                      items: availableConfiguredExtensions
                          .map(
                            (extension) => DropdownMenuItem<String>(
                              value: extension.key.trim(),
                              child: Text(extension.key.trim()),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedConfiguredKey = value;
                          if (value != null) {
                            keyController.text = value;
                          }
                        });
                      },
                    )
                  else
                    const Text('No configured extension available for this node type.'),
                  const Gap(8),
                  TextField(
                    controller: keyController,
                    decoration: const InputDecoration(labelText: 'Extension key'),
                    onChanged: (_) => setDialogState(() {
                      selectedConfiguredKey = null;
                    }),
                  ),
                  if (trimmedKey.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text('Add "$trimmedKey"'),
                    ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final finalKey = keyController.text.trim();
                if (finalKey.isEmpty) {
                  return;
                }

                JsonSchemaEditorExtensionField? field;
                for (final extension in availableConfiguredExtensions) {
                  if (extension.key.trim() == finalKey) {
                    field = extension;
                    break;
                  }
                }

                onAdd(finalKey, field);
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

class _ExtensionStateBadge extends StatelessWidget {
  const _ExtensionStateBadge({required this.isConfigured, required this.isImplemented});

  final bool isConfigured;
  final bool isImplemented;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (!isConfigured) {
      return _ChipLabel(
        label: 'not implemented',
        icon: Icons.extension,
        color: colorScheme.errorContainer,
        textColor: colorScheme.onErrorContainer,
      );
    }
    if (isImplemented) {
      return _ChipLabel(
        label: 'implemented',
        icon: Icons.check_circle,
        color: colorScheme.secondaryContainer,
        textColor: colorScheme.onSecondaryContainer,
      );
    }
    return _ChipLabel(
      label: 'not implemented',
      icon: Icons.warning_amber,
      color: colorScheme.surfaceContainerHighest,
      textColor: colorScheme.onSurfaceVariant,
    );
  }
}

class _ChipLabel extends StatelessWidget {
  const _ChipLabel({
    required this.label,
    required this.icon,
    required this.color,
    required this.textColor,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: textColor),
            const Gap(4),
            Text(label, style: TextStyle(color: textColor, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _BooleanExtensionNodeField extends StatelessWidget {
  const _BooleanExtensionNodeField({
    required this.controller,
    required this.path,
    required this.extensionKey,
    required this.extensionValue,
  });

  final JsonSchemaEditorController controller;
  final JsonSchemaPath path;
  final String extensionKey;
  final bool extensionValue;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Spacer(),
        Checkbox(
          value: extensionValue,
          onChanged: (value) {
            controller.setNodeField(path: path, key: extensionKey, value: value ?? false);
          },
        ),
        IconButton(
          tooltip: 'Remove extension',
          icon: const Icon(Icons.close),
          onPressed: () => controller.removeNodeField(path: path, key: extensionKey),
        ),
      ],
    );
  }
}

class _StringExtensionNodeField extends StatelessWidget {
  const _StringExtensionNodeField({
    required this.controller,
    required this.path,
    required this.extensionKey,
    required this.extensionValue,
  });

  final JsonSchemaEditorController controller;
  final JsonSchemaPath path;
  final String extensionKey;
  final String extensionValue;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SchemaTextField(
            value: extensionValue,
            hint: extensionKey,
            onChanged: (value) =>
                controller.setNodeField(path: path, key: extensionKey, value: value),
            onCleared: () => controller.removeNodeField(path: path, key: extensionKey),
          ),
        ),
        IconButton(
          tooltip: 'Remove extension',
          icon: const Icon(Icons.close),
          onPressed: () => controller.removeNodeField(path: path, key: extensionKey),
        ),
      ],
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
  });

  final JsonSchemaEditorController controller;
  final JsonSchemaPath path;
  final String extensionKey;
  final String extensionValue;
  final List<String> values;

  @override
  Widget build(BuildContext context) {
    final valueEntries = values.where((item) => item.trim().isNotEmpty).toList(growable: false);
    final currentValue = _normalizeStringEnumValue(
      value: extensionValue,
      allowedValues: valueEntries,
    );

    return Row(
      children: [
        Expanded(
          child: DropdownButton<String>(
            isExpanded: true,
            hint: const Text('Set value'),
            value: currentValue,
            items: <DropdownMenuItem<String>>[
              const DropdownMenuItem<String>(value: '', child: Text('Not set')),
              ...valueEntries.map(
                (entry) => DropdownMenuItem<String>(value: entry, child: Text(entry)),
              ),
            ],
            onChanged: (value) {
              if (value == null || value.isEmpty) {
                controller.removeNodeField(path: path, key: extensionKey);
                return;
              }
              controller.setNodeField(path: path, key: extensionKey, value: value);
            },
          ),
        ),
        IconButton(
          tooltip: 'Remove extension',
          icon: const Icon(Icons.close),
          onPressed: () => controller.removeNodeField(path: path, key: extensionKey),
        ),
      ],
    );
  }
}

class _NumberExtensionNodeField extends StatelessWidget {
  const _NumberExtensionNodeField({
    required this.controller,
    required this.path,
    required this.extensionKey,
    required this.extensionValue,
  });

  final JsonSchemaEditorController controller;
  final JsonSchemaPath path;
  final String extensionKey;
  final Object? extensionValue;

  @override
  Widget build(BuildContext context) {
    final value = extensionValue == null ? '' : extensionValue.toString();
    return Row(
      children: [
        Expanded(
          child: _SchemaTextField(
            value: value,
            hint: extensionKey,
            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
            onChanged: (next) => _updateDouble(
              next,
              (parsed) => controller.setNodeField(path: path, key: extensionKey, value: parsed),
              () => controller.removeNodeField(path: path, key: extensionKey),
            ),
            onCleared: () => controller.removeNodeField(path: path, key: extensionKey),
          ),
        ),
        IconButton(
          tooltip: 'Remove extension',
          icon: const Icon(Icons.close),
          onPressed: () => controller.removeNodeField(path: path, key: extensionKey),
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
  });

  final JsonSchemaEditorController controller;
  final JsonSchemaEditorFeatureOptions featureOptions;
  final JsonSchemaStringNode node;
  final JsonSchemaPath path;
  final List<JsonSchemaDiagnostic> diagnostics;
  final bool compactMode;

  @override
  Widget build(BuildContext context) {
    final localWarnings = diagnostics.where((item) => item.path == path).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (featureOptions.stringMinLength) ...[
          _SchemaTextField(
            value: node.minLength?.toString(),
            hint: 'Min length',
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
          const Gap(6),
        ],
        if (featureOptions.stringMaxLength) ...[
          _SchemaTextField(
            value: node.maxLength?.toString(),
            hint: 'Max length',
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
          const Gap(6),
        ],
        if (featureOptions.stringPattern) ...[
          _SchemaTextField(
            value: node.pattern,
            hint: 'Pattern (RegExp)',
            onChanged: (value) => controller.updateNode(
              path: path,
              updater: (JsonSchemaStringNode node) => node.copyWith(pattern: value),
            ),
            onCleared: () => controller.updateNode(
              path: path,
              updater: (JsonSchemaStringNode node) => node.copyWith(clearPattern: true),
            ),
          ),
          const Gap(6),
        ],
        if (featureOptions.stringEnum) ...[
          _SchemaTextField(
            value: _stringEnumInput(node.enumValues),
            hint: 'Enum (comma/line list)',
            maxLines: 3,
            onChanged: (value) => _updateStringList(
              value,
              (next) => controller.updateNode(
                path: path,
                updater: (JsonSchemaStringNode node) => node.copyWith(enumValues: next),
              ),
              () => controller.updateNode(
                path: path,
                updater: (JsonSchemaStringNode node) => node.copyWith(clearEnumValues: true),
              ),
            ),
          ),
          const Gap(6),
        ],
        if (localWarnings.isNotEmpty)
          ...localWarnings.map((item) => JsonSchemaWarningBadge(message: item.message)),
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
  });

  final JsonSchemaEditorController controller;
  final JsonSchemaEditorFeatureOptions featureOptions;
  final JsonSchemaNumberNode node;
  final JsonSchemaPath path;
  final List<JsonSchemaDiagnostic> diagnostics;
  final bool compactMode;

  @override
  Widget build(BuildContext context) {
    final localWarnings = diagnostics.where((item) => item.path == path).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (featureOptions.numberMinimum) ...[
          _SchemaTextField(
            value: node.minimum?.toString(),
            hint: 'Minimum',
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
          const Gap(6),
        ],
        if (featureOptions.numberMaximum) ...[
          _SchemaTextField(
            value: node.maximum?.toString(),
            hint: 'Maximum',
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
          const Gap(6),
        ],
        if (featureOptions.numberExclusiveMinimum) ...[
          CheckboxListTile(
            value: node.exclusiveMinimum ?? false,
            title: const Text('exclusiveMinimum'),
            onChanged: (value) => controller.updateNode(
              path: path,
              updater: (JsonSchemaNumberNode node) => node.copyWith(exclusiveMinimum: value),
            ),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
        if (featureOptions.numberExclusiveMaximum) ...[
          CheckboxListTile(
            value: node.exclusiveMaximum ?? false,
            title: const Text('exclusiveMaximum'),
            onChanged: (value) => controller.updateNode(
              path: path,
              updater: (JsonSchemaNumberNode node) => node.copyWith(exclusiveMaximum: value),
            ),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
        if (featureOptions.numberMultipleOf) ...[
          _SchemaTextField(
            value: node.multipleOf?.toString(),
            hint: 'multipleOf',
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
          const Gap(6),
        ],
        if (localWarnings.isNotEmpty)
          ...localWarnings.map((item) => JsonSchemaWarningBadge(message: item.message)),
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
  });

  final JsonSchemaEditorController controller;
  final JsonSchemaBooleanNode node;
  final JsonSchemaPath path;
  final List<JsonSchemaDiagnostic> diagnostics;
  final bool compactMode;

  @override
  Widget build(BuildContext context) {
    final localWarnings = diagnostics.where((item) => item.path == path).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: node.defaultValue ?? false,
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                controller.updateNode(
                  path: path,
                  updater: (JsonSchemaBooleanNode node) => node.copyWith(defaultValue: value),
                );
              },
            ),
            const Text('Default'),
            const Spacer(),
            if (node.defaultValue != null)
              IconButton(
                tooltip: 'Clear default',
                icon: const Icon(Icons.close),
                onPressed: () => controller.updateNode(
                  path: path,
                  updater: (JsonSchemaBooleanNode node) => node.copyWith(clearDefaultValue: true),
                ),
              ),
          ],
        ),
        if (node.defaultValue == null)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'default not set',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ),
        if (localWarnings.isNotEmpty)
          ...localWarnings.map((item) => JsonSchemaWarningBadge(message: item.message)),
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
  });

  final JsonSchemaEditorController controller;
  final JsonSchemaEditorFeatureOptions featureOptions;
  final JsonSchemaObjectNode node;
  final JsonSchemaPath path;
  final List<JsonSchemaDiagnostic> diagnostics;
  final bool compactMode;

  @override
  Widget build(BuildContext context) {
    final propertyEntries = node.properties.entries.toList(growable: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Properties'),
            const Spacer(),
            if (featureOptions.objectAdditionalProperties) ...[
              Checkbox(
                value: node.additionalProperties,
                onChanged: (value) => controller.updateNode(
                  path: path,
                  updater: (JsonSchemaObjectNode node) =>
                      node.copyWith(additionalProperties: value ?? true),
                ),
              ),
              const Text('Allow additional properties'),
              const Spacer(),
            ],
            const Spacer(),
            Button(
              onTap: () {
                controller.addProperty(
                  objectPath: path,
                  key: 'property',
                  node: const JsonSchemaStringNode(),
                );
              },
              type: ButtonType.secondary,
              label: 'Add property',
            ),
          ],
        ),
        const Gap(8),
        if (propertyEntries.isEmpty) const Text('No properties defined yet.'),
        ...propertyEntries.map((entry) {
          final propertyPath = path.childProperty(entry.key);
          final propertyNode = entry.value;
          final required = node.required.contains(entry.key);
          final propertyWarnings = diagnostics.where((item) => item.path == propertyPath).toList();

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _SchemaTextField(
                        value: entry.key,
                        hint: 'Property key',
                        onChanged: (value) {},
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
                      ),
                    ),
                    const Gap(6),
                    Checkbox(
                      value: required,
                      onChanged: (nextRequired) => controller.setRequired(
                        objectPath: path,
                        key: entry.key,
                        required: nextRequired ?? false,
                      ),
                    ),
                    const Text('Required'),
                    IconButton(
                      onPressed: () => controller.removeProperty(objectPath: path, key: entry.key),
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Remove property',
                    ),
                  ],
                ),
                if (propertyWarnings.isNotEmpty)
                  ...propertyWarnings.map((item) => JsonSchemaWarningBadge(message: item.message)),
                _SchemaNodeEditor(
                  controller: controller,
                  featureOptions: featureOptions,
                  node: propertyNode,
                  path: propertyPath,
                  diagnostics: diagnostics,
                  compactMode: compactMode,
                ),
              ],
            ),
          );
        }),
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
  });

  final JsonSchemaEditorController controller;
  final JsonSchemaEditorFeatureOptions featureOptions;
  final JsonSchemaArrayNode node;
  final JsonSchemaPath path;
  final List<JsonSchemaDiagnostic> diagnostics;
  final bool compactMode;

  @override
  Widget build(BuildContext context) {
    final localWarnings = diagnostics.where((item) => item.path == path).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (featureOptions.arrayMinItems) ...[
          _SchemaTextField(
            value: node.minItems?.toString(),
            hint: 'Min items',
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
          const Gap(6),
        ],
        if (featureOptions.arrayMaxItems) ...[
          _SchemaTextField(
            value: node.maxItems?.toString(),
            hint: 'Max items',
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
          const Gap(6),
        ],
        if (featureOptions.arrayUniqueItems) ...[
          CheckboxListTile(
            value: node.uniqueItems ?? false,
            title: const Text('Unique items'),
            onChanged: (value) {
              if (value == null) {
                return;
              }
              controller.updateNode(
                path: path,
                updater: (JsonSchemaArrayNode node) => node.copyWith(uniqueItems: value),
              );
            },
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
        if (localWarnings.isNotEmpty)
          ...localWarnings.map((item) => JsonSchemaWarningBadge(message: item.message)),
        const Divider(),
        const Text('Items'),
        const Gap(8),
        _SchemaNodeEditor(
          controller: controller,
          featureOptions: featureOptions,
          node: node.items,
          path: path.childItems(),
          diagnostics: diagnostics,
          compactMode: compactMode,
        ),
      ],
    );
  }
}

class _SchemaTextField extends StatefulWidget {
  const _SchemaTextField({
    required this.value,
    required this.hint,
    required this.onChanged,
    this.onSubmitted,
    this.onCleared,
    this.keyboardType,
    this.maxLines = 1,
  });

  final String? value;
  final String hint;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onCleared;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  State<_SchemaTextField> createState() => _SchemaTextFieldState();
}

class _SchemaTextFieldState extends State<_SchemaTextField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value ?? '');
  }

  @override
  void didUpdateWidget(covariant _SchemaTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != _controller.text) {
      _controller.text = widget.value ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StyledTextfield(
      controller: _controller,
      hint: widget.hint,
      keyboardType: widget.keyboardType,
      maxLines: widget.maxLines,
      onChange: (value) {
        widget.onChanged(value);
      },
      onSubmit: (value) {
        if (value.trim().isEmpty) {
          widget.onCleared?.call();
        }
        widget.onSubmitted?.call(value);
      },
    );
  }
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

void _updateStringList(
  String value,
  void Function(List<String>) onParsed,
  void Function() onClear,
) {
  final parsed = _readStringListFromText(value);
  if (parsed == null || parsed.isEmpty) {
    onClear();
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
