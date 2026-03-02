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
        CheckboxListTile(
          value: node.defaultValue ?? false,
          title: const Text('Default'),
          onChanged: (value) {
            if (value == null) {
              return;
            }
            controller.updateNode(
              path: path,
              updater: (JsonSchemaBooleanNode node) => node.copyWith(defaultValue: value),
            );
          },
          controlAffinity: ListTileControlAffinity.leading,
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
