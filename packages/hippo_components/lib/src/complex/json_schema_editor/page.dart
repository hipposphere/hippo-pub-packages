import 'package:flutter/material.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:hippo_components/src/complex/json_schema_editor/json_schema_editor_descriptions.dart';
import 'package:hippo_components/src/complex/json_schema_editor/widgets/json_schema_validation_panel.dart';
import 'package:hippo_components/src/complex/json_schema_visualization/json_schema_visualization_panel.dart';
import 'package:hippo_utils/hippo_utils.dart';

class JsonSchemaEditorPage extends StatelessWidget {
  final String title;
  final JsonSchemaEditorController controller;
  final Future<bool> Function(BuildContext context, JsonSchema schema) onSave;
  final String? explanationDescription;
  const JsonSchemaEditorPage({
    super.key,
    required this.title,
    required this.controller,
    required this.onSave,
    this.explanationDescription,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isDesktop = width >= 1000;

        if (isDesktop) {
          return PageContainer(
            title: title,
            actions: [
              PageHeaderTextAction(
                onTap: () {
                  onSave(context, controller.toJsonSchema());
                },
                icon: const Icon(Icons.save_outlined),
                label: context.cl.actions_save,
              ),
            ],
            body: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 2, child: JsonSchemaEditor(controller: controller)),
                const VerticalDivider(thickness: 0.5, width: 0.5),
                Expanded(
                  child: _PreviewAndDiagnostics(
                    controller: controller,
                    explanationDescription: explanationDescription,
                  ),
                ),
              ],
            ),
          );
        }

        return TabbedPageContainer(
          title: title,
          actions: [
            PageHeaderTextAction(
              onTap: () {
                onSave(context, controller.toJsonSchema());
              },
              icon: const Icon(Icons.save_outlined),
              label: context.cl.actions_save,
            ),
          ],
          tabs: const [
            Tab(text: 'Editor'),
            Tab(text: 'Vorschau'),
            Tab(text: 'Guide'),
          ],
          tabViews: [
            JsonSchemaEditor(controller: controller),
            _PreviewAndDiagnostics(
              controller: controller,
              explanationDescription: explanationDescription,
            ),
            _JsonSchemaExplainationTab(controller: controller, description: explanationDescription),
          ],
        );
      },
    );
  }
}

class _PreviewAndDiagnostics extends StatelessWidget {
  const _PreviewAndDiagnostics({required this.controller, this.explanationDescription});

  final JsonSchemaEditorController controller;
  final String? explanationDescription;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: DataSubjectBuilder<JsonSchemaNode>(
        subject: controller.schemaSubject,
        builder: (context, schemaNode) {
          return DataSubjectBuilder<List<JsonSchemaDiagnostic>>(
            subject: controller.diagnosticsSubject,
            builder: (context, diagnostics) {
              return Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    JsonSchemaValidationPanel(diagnostics: diagnostics),
                    const Gap(16),
                    JsonSchemaVisualizationPanel(
                      controller: controller,
                      schema: JsonSchema.fromNode(schemaNode),
                    ),
                    const Gap(16),
                    _JsonSchemaExplainationPage(
                      controller: controller,
                      description: explanationDescription,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _JsonSchemaExplainationTab extends StatelessWidget {
  const _JsonSchemaExplainationTab({required this.controller, this.description});

  final JsonSchemaEditorController controller;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: _JsonSchemaExplainationPage(controller: controller, description: description),
    );
  }
}

class _JsonSchemaExplainationPage extends StatelessWidget {
  const _JsonSchemaExplainationPage({required this.controller, this.description});

  final JsonSchemaEditorController controller;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final resolvedDescription = _resolveExplainationDescription(description);
    final generalConceptEntries = _generalConceptEntries(controller);
    final nodeTypeEntries = _nodeTypeEntries();
    final capabilityEntries = _capabilityEntries(controller);
    final configuredExtensionEntries = _configuredExtensionEntries(controller);

    return Container(
      key: const ValueKey('json-schema-explaination-page'),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.menu_book_rounded,
                  color: colorScheme.onPrimaryContainer,
                  size: 18,
                ),
              ),
              const Gap(10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'JSON Schema Guide',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const Gap(4),
                    Text(
                      resolvedDescription,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(18),
          _ExplainationSection(title: 'General concept', entries: generalConceptEntries),
          const Gap(16),
          _ExplainationSection(title: 'Node types', entries: nodeTypeEntries),
          const Gap(16),
          _ExplainationSection(title: 'Supported capabilities', entries: capabilityEntries),
          if (configuredExtensionEntries.isNotEmpty) ...[
            const Gap(16),
            _ExplainationSection(
              title: 'Configured extensions',
              entries: configuredExtensionEntries,
            ),
          ],
        ],
      ),
    );
  }
}

class _ExplainationSection extends StatelessWidget {
  const _ExplainationSection({required this.title, required this.entries});

  final String title;
  final List<_ExplainationEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const Gap(8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: entries.map(_ExplainationEntryCard.new).toList(growable: false),
        ),
      ],
    );
  }
}

class _ExplainationEntry {
  const _ExplainationEntry({
    required this.title,
    required this.description,
    required this.icon,
    this.badges = const [],
  });

  final String title;
  final String description;
  final IconData icon;
  final List<String> badges;
}

class _ExplainationEntryCard extends StatelessWidget {
  const _ExplainationEntryCard(this.entry);

  final _ExplainationEntry entry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 220, maxWidth: 320),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.45)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(entry.icon, size: 15, color: colorScheme.onSecondaryContainer),
                ),
                const Gap(8),
                Expanded(
                  child: Text(
                    entry.title,
                    style: Theme.of(
                      context,
                    ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            if (entry.badges.isNotEmpty) ...[
              const Gap(10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: entry.badges
                    .map((badge) => _ExplainationBadge(label: badge))
                    .toList(growable: false),
              ),
            ],
            const Gap(10),
            Text(
              entry.description,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant, height: 1.35),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExplainationBadge extends StatelessWidget {
  const _ExplainationBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

String _resolveExplainationDescription(String? description) {
  final trimmed = description?.trim();
  if (trimmed != null && trimmed.isNotEmpty) {
    return trimmed;
  }
  return 'Use this guide to understand how the editor models a JSON Schema tree, which node '
      'types are available, and which validation or metadata capabilities are enabled.';
}

List<_ExplainationEntry> _generalConceptEntries(JsonSchemaEditorController controller) {
  return [
    const _ExplainationEntry(
      title: 'Schema tree',
      description:
          'The root node describes the full JSON document. Child nodes describe nested '
          'properties or array items below that root.',
      icon: Icons.account_tree_rounded,
      badges: ['Root schema'],
    ),
    const _ExplainationEntry(
      title: 'Objects and arrays',
      description:
          'Object nodes add named properties and required flags. Array nodes define one item '
          'schema that applies to every element in the list.',
      icon: Icons.widgets_rounded,
      badges: ['Structure'],
    ),
    _ExplainationEntry(
      title: 'Capabilities',
      description:
          'Capabilities add validation rules or metadata to a node. The guide below only lists '
          'capabilities that are currently enabled for this editor configuration.',
      icon: Icons.tune_rounded,
      badges: [
        if (controller.extensionOptions.allowAddExtensions) 'Custom extensions allowed',
        if (!controller.extensionOptions.allowAddExtensions) 'Custom extensions restricted',
      ],
    ),
    const _ExplainationEntry(
      title: 'Composition keywords',
      description:
          'Keywords like const, allOf, oneOf, and \$ref let a schema pin a fixed value, combine '
          'constraints, or reference another schema definition.',
      icon: Icons.merge_type_rounded,
      badges: ['Advanced'],
    ),
  ];
}

List<_ExplainationEntry> _nodeTypeEntries() {
  return JsonSchemaNodeType.values
      .map((type) {
        return _ExplainationEntry(
          title: jsonSchemaTypeLabel(type),
          description: jsonSchemaTypeHelp(type),
          icon: _nodeTypeIcon(type),
          badges: [type.toJsonType()],
        );
      })
      .toList(growable: false);
}

List<_ExplainationEntry> _capabilityEntries(JsonSchemaEditorController controller) {
  final featureOptions = controller.featureOptions;
  final stringOptions = featureOptions.stringOptions;
  final numberOptions = featureOptions.numberOptions;
  final booleanOptions = featureOptions.booleanOptions;
  final arrayOptions = featureOptions.arrayOptions;
  final objectOptions = featureOptions.objectOptions;
  final entries = <_ExplainationEntry>[
    _capabilityEntry(
      title: 'Title',
      description: jsonSchemaHelpByKeyword['title']!,
      icon: Icons.title_rounded,
      badges: const ['All nodes'],
    ),
    _capabilityEntry(
      title: 'Description',
      description: jsonSchemaHelpByKeyword['description']!,
      icon: Icons.notes_rounded,
      badges: const ['All nodes'],
    ),
    _capabilityEntry(
      title: 'const',
      description: jsonSchemaHelpByKeyword['const']!,
      icon: Icons.push_pin_rounded,
      badges: const ['All nodes'],
    ),
    _capabilityEntry(
      title: r'$ref',
      description: jsonSchemaHelpByKeyword[r'$ref']!,
      icon: Icons.link_rounded,
      badges: const ['All nodes'],
    ),
    _capabilityEntry(
      title: 'allOf',
      description: jsonSchemaHelpByKeyword['allOf']!,
      icon: Icons.call_merge_rounded,
      badges: const ['All nodes'],
    ),
    _capabilityEntry(
      title: 'oneOf',
      description: jsonSchemaHelpByKeyword['oneOf']!,
      icon: Icons.alt_route_rounded,
      badges: const ['All nodes'],
    ),
    _capabilityEntry(
      title: 'Properties',
      description: jsonSchemaHelpByKeyword['properties']!,
      icon: Icons.view_list_rounded,
      badges: const ['Object'],
    ),
    _capabilityEntry(
      title: 'Required',
      description: jsonSchemaHelpByKeyword['required']!,
      icon: Icons.star_rounded,
      badges: const ['Object properties'],
    ),
    _capabilityEntry(
      title: 'Array items',
      description: jsonSchemaHelpByKeyword['items']!,
      icon: Icons.inventory_2_rounded,
      badges: const ['Array'],
    ),
    if (stringOptions.minLength)
      _capabilityEntry(
        title: 'Min length',
        description: jsonSchemaHelpByKeyword['minLength']!,
        icon: Icons.straighten_rounded,
        badges: const ['String'],
      ),
    if (stringOptions.maxLength)
      _capabilityEntry(
        title: 'Max length',
        description: jsonSchemaHelpByKeyword['maxLength']!,
        icon: Icons.width_normal_rounded,
        badges: const ['String'],
      ),
    if (stringOptions.pattern)
      _capabilityEntry(
        title: 'Pattern',
        description: jsonSchemaHelpByKeyword['pattern']!,
        icon: Icons.pattern_rounded,
        badges: const ['String'],
      ),
    if (stringOptions.enumValues)
      _capabilityEntry(
        title: 'Enum',
        description: jsonSchemaHelpByKeyword['enum']!,
        icon: Icons.list_alt_rounded,
        badges: const ['String'],
      ),
    if (numberOptions.minimum)
      _capabilityEntry(
        title: 'Minimum',
        description: jsonSchemaHelpByKeyword['minimum']!,
        icon: Icons.exposure_neg_1_rounded,
        badges: const ['Number', 'Integer'],
      ),
    if (numberOptions.maximum)
      _capabilityEntry(
        title: 'Maximum',
        description: jsonSchemaHelpByKeyword['maximum']!,
        icon: Icons.exposure_plus_1_rounded,
        badges: const ['Number', 'Integer'],
      ),
    if (numberOptions.exclusiveMinimum)
      _capabilityEntry(
        title: 'Exclusive min',
        description: jsonSchemaHelpByKeyword['exclusiveMinimum']!,
        icon: Icons.lock_open_rounded,
        badges: const ['Number', 'Integer'],
      ),
    if (numberOptions.exclusiveMaximum)
      _capabilityEntry(
        title: 'Exclusive max',
        description: jsonSchemaHelpByKeyword['exclusiveMaximum']!,
        icon: Icons.lock_outline_rounded,
        badges: const ['Number', 'Integer'],
      ),
    if (numberOptions.multipleOf)
      _capabilityEntry(
        title: 'Multiple of',
        description: jsonSchemaHelpByKeyword['multipleOf']!,
        icon: Icons.repeat_rounded,
        badges: const ['Number', 'Integer'],
      ),
    if (booleanOptions.defaultValue)
      _capabilityEntry(
        title: 'Default',
        description: jsonSchemaHelpByKeyword['default']!,
        icon: Icons.toggle_on_rounded,
        badges: const ['Boolean'],
      ),
    if (arrayOptions.minItems)
      _capabilityEntry(
        title: 'Min items',
        description: jsonSchemaHelpByKeyword['minItems']!,
        icon: Icons.format_list_numbered_rounded,
        badges: const ['Array'],
      ),
    if (arrayOptions.maxItems)
      _capabilityEntry(
        title: 'Max items',
        description: jsonSchemaHelpByKeyword['maxItems']!,
        icon: Icons.format_list_numbered_rtl_rounded,
        badges: const ['Array'],
      ),
    if (arrayOptions.uniqueItems)
      _capabilityEntry(
        title: 'Unique items',
        description: jsonSchemaHelpByKeyword['uniqueItems']!,
        icon: Icons.filter_1_rounded,
        badges: const ['Array'],
      ),
    if (objectOptions.additionalProperties)
      _capabilityEntry(
        title: 'Additional properties',
        description: jsonSchemaHelpByKeyword['additionalProperties']!,
        icon: Icons.add_box_rounded,
        badges: const ['Object'],
      ),
    _capabilityEntry(
      title: 'Extensions',
      description: jsonSchemaHelpByKeyword['extensionField']!,
      icon: Icons.extension_rounded,
      badges: [
        if (controller.extensionOptions.allowAddExtensions) 'Custom keys allowed',
        if (!controller.extensionOptions.allowAddExtensions) 'Configured keys only',
      ],
    ),
  ];

  return entries;
}

_ExplainationEntry _capabilityEntry({
  required String title,
  required String description,
  required IconData icon,
  required List<String> badges,
}) {
  return _ExplainationEntry(title: title, description: description, icon: icon, badges: badges);
}

List<_ExplainationEntry> _configuredExtensionEntries(JsonSchemaEditorController controller) {
  final merged = <String, _ConfiguredExtensionExplaination>{};
  final extensionOptions = controller.extensionOptions;
  final rawFields = <JsonSchemaEditorExtensionField>[
    ...extensionOptions.configurableExtensionsForAllNodeTypes,
    for (final fields in extensionOptions.configurableExtensions.values) ...fields,
  ];

  for (final field in rawFields) {
    final key = field.key.trim();
    if (key.isEmpty) {
      continue;
    }
    final existing = merged[key];
    final nextNodeTypes = field.applicableNodeTypes.isEmpty
        ? JsonSchemaNodeType.values.toSet()
        : field.applicableNodeTypes;
    final nextScopes = field.applicableScopes.isEmpty
        ? JsonSchemaEditorExtensionFieldScope.values.toSet()
        : field.applicableScopes;

    if (existing == null) {
      merged[key] = _ConfiguredExtensionExplaination(
        key: key,
        label: field.displayLabel,
        description: field.normalizedDescription ?? 'Configured custom schema extension.',
        valueType: field.valueType,
        nodeTypes: {...nextNodeTypes},
        scopes: {...nextScopes},
      );
      continue;
    }

    merged[key] = existing.copyWith(
      label: existing.label.isEmpty ? field.displayLabel : existing.label,
      description: existing.description.isEmpty
          ? (field.normalizedDescription ?? existing.description)
          : existing.description,
      nodeTypes: {...existing.nodeTypes, ...nextNodeTypes},
      scopes: {...existing.scopes, ...nextScopes},
    );
  }

  return merged.values
      .map((entry) {
        return _ExplainationEntry(
          title: entry.label,
          description: entry.description,
          icon: Icons.extension_rounded,
          badges: [
            entry.key,
            _extensionValueTypeLabel(entry.valueType),
            _nodeTypeSummary(entry.nodeTypes),
            _scopeSummary(entry.scopes),
          ],
        );
      })
      .toList(growable: false)
    ..sort((left, right) => left.title.compareTo(right.title));
}

class _ConfiguredExtensionExplaination {
  const _ConfiguredExtensionExplaination({
    required this.key,
    required this.label,
    required this.description,
    required this.valueType,
    required this.nodeTypes,
    required this.scopes,
  });

  final String key;
  final String label;
  final String description;
  final JsonSchemaEditorExtensionFieldType valueType;
  final Set<JsonSchemaNodeType> nodeTypes;
  final Set<JsonSchemaEditorExtensionFieldScope> scopes;

  _ConfiguredExtensionExplaination copyWith({
    String? label,
    String? description,
    Set<JsonSchemaNodeType>? nodeTypes,
    Set<JsonSchemaEditorExtensionFieldScope>? scopes,
  }) {
    return _ConfiguredExtensionExplaination(
      key: key,
      label: label ?? this.label,
      description: description ?? this.description,
      valueType: valueType,
      nodeTypes: nodeTypes ?? this.nodeTypes,
      scopes: scopes ?? this.scopes,
    );
  }
}

String _extensionValueTypeLabel(JsonSchemaEditorExtensionFieldType type) {
  return switch (type) {
    JsonSchemaEditorExtensionFieldType.string => 'String value',
    JsonSchemaEditorExtensionFieldType.number => 'Number value',
    JsonSchemaEditorExtensionFieldType.boolean => 'Boolean value',
    JsonSchemaEditorExtensionFieldType.stringEnum => 'Enum value',
  };
}

String _nodeTypeSummary(Set<JsonSchemaNodeType> types) {
  if (types.length == JsonSchemaNodeType.values.length) {
    return 'All node types';
  }
  final labels = types.map(jsonSchemaTypeLabel).toList(growable: false)..sort();
  return labels.join(' / ');
}

String _scopeSummary(Set<JsonSchemaEditorExtensionFieldScope> scopes) {
  if (scopes.length == JsonSchemaEditorExtensionFieldScope.values.length) {
    return 'All scopes';
  }
  final labels =
      scopes
          .map((scope) {
            return switch (scope) {
              JsonSchemaEditorExtensionFieldScope.root => 'Root',
              JsonSchemaEditorExtensionFieldScope.objectProperty => 'Property',
              JsonSchemaEditorExtensionFieldScope.arrayItem => 'Array item',
            };
          })
          .toList(growable: false)
        ..sort();
  return labels.join(' / ');
}

IconData _nodeTypeIcon(JsonSchemaNodeType type) {
  return switch (type) {
    JsonSchemaNodeType.string => Icons.text_fields_rounded,
    JsonSchemaNodeType.number => Icons.pin_rounded,
    JsonSchemaNodeType.integer => Icons.looks_one_rounded,
    JsonSchemaNodeType.boolean => Icons.toggle_on_rounded,
    JsonSchemaNodeType.object => Icons.data_object_rounded,
    JsonSchemaNodeType.array => Icons.view_array_rounded,
  };
}
