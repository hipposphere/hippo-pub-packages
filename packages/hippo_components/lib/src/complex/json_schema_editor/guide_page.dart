import 'package:flutter/material.dart';
import 'package:hippo_components/src/base/utils/components_context.dart';
import 'package:hippo_utils/hippo_utils.dart';

import '../../container/page_container/page_container.dart';
import 'controller.dart';
import 'json_schema_editor_descriptions.dart';
import 'models/feature_options.dart';

class JsonSchemaEditorGuidePage extends StatelessWidget {
  const JsonSchemaEditorGuidePage({
    super.key,
    required this.controller,
    this.description,
    this.title,
  });

  final JsonSchemaEditorController controller;
  final String? description;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final resolvedTitle = title?.trim().isNotEmpty == true
        ? title!
        : context.lazyTranslate(
            en: 'JSON Schema Guide',
            de: 'JSON-Schema-Leitfaden',
            zh: 'JSON Schema 指南',
          );
    return PageContainer(
      title: resolvedTitle,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: _JsonSchemaExplainationContent(
          controller: controller,
          title: resolvedTitle,
          description: description,
        ),
      ),
    );
  }
}

class _JsonSchemaExplainationContent extends StatelessWidget {
  const _JsonSchemaExplainationContent({
    required this.controller,
    required this.title,
    this.description,
  });

  final JsonSchemaEditorController controller;
  final String title;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final resolvedDescription = _resolveExplainationDescription(context, description);
    final generalConceptEntries = _generalConceptEntries(context, controller);
    final nodeTypeEntries = _nodeTypeEntries(context);
    final capabilityEntries = _capabilityEntries(context, controller);
    final configuredExtensionEntries = _configuredExtensionEntries(context, controller);

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
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
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
          const SizedBox(height: 18),
          _ExplainationSection(
            title: context.lazyTranslate(en: 'General concept', de: 'Grundkonzept', zh: '整体概念'),
            entries: generalConceptEntries,
          ),
          const SizedBox(height: 16),
          _ExplainationSection(
            title: context.lazyTranslate(en: 'Node types', de: 'Knotentypen', zh: '节点类型'),
            entries: nodeTypeEntries,
          ),
          const SizedBox(height: 16),
          _ExplainationSection(
            title: context.lazyTranslate(
              en: 'Supported capabilities',
              de: 'Unterstützte Fähigkeiten',
              zh: '支持的能力',
            ),
            entries: capabilityEntries,
          ),
          if (configuredExtensionEntries.isNotEmpty) ...[
            const SizedBox(height: 16),
            _ExplainationSection(
              title: context.lazyTranslate(
                en: 'Configured extensions',
                de: 'Konfigurierte Erweiterungen',
                zh: '已配置扩展',
              ),
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
        const SizedBox(height: 8),
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
                const SizedBox(width: 8),
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
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: entry.badges
                    .map((badge) => _ExplainationBadge(label: badge))
                    .toList(growable: false),
              ),
            ],
            const SizedBox(height: 10),
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

String _resolveExplainationDescription(BuildContext context, String? description) {
  final trimmed = description?.trim();
  if (trimmed != null && trimmed.isNotEmpty) {
    return trimmed;
  }
  return context.lazyTranslate(
    en:
        'Use this guide to understand how the editor models a JSON Schema tree, which node '
        'types are available, and which validation or metadata capabilities are enabled.',
    de:
        'Dieser Leitfaden erklärt, wie der Editor einen JSON-Schema-Baum modelliert, welche '
        'Knotentypen verfügbar sind und welche Validierungs- oder Metadaten-Fähigkeiten aktiviert sind.',
    zh: '使用本指南了解编辑器如何建模 JSON Schema 树、有哪些节点类型可用，以及当前启用了哪些校验或元数据能力。',
  );
}

List<_ExplainationEntry> _generalConceptEntries(
  BuildContext context,
  JsonSchemaEditorController controller,
) {
  return [
    _ExplainationEntry(
      title: context.lazyTranslate(en: 'Schema tree', de: 'Schema-Baum', zh: 'Schema 树'),
      description: context.lazyTranslate(
        en:
            'The root node describes the full JSON document. Child nodes describe nested '
            'properties or array items below that root.',
        de:
            'Der Root-Knoten beschreibt das vollständige JSON-Dokument. Kindknoten beschreiben '
            'darunter verschachtelte Properties oder Array-Elemente.',
        zh: '根节点描述整个 JSON 文档，子节点描述其下的嵌套属性或数组元素。',
      ),
      icon: Icons.account_tree_rounded,
      badges: [context.lazyTranslate(en: 'Root schema', de: 'Root-Schema', zh: '根 Schema')],
    ),
    _ExplainationEntry(
      title: context.lazyTranslate(en: 'Objects and arrays', de: 'Objekte und Arrays', zh: '对象与数组'),
      description: context.lazyTranslate(
        en:
            'Object nodes add named properties and required flags. Array nodes define one item '
            'schema that applies to every element in the list.',
        de:
            'Objekt-Knoten fügen benannte Properties und Pflicht-Flags hinzu. Array-Knoten '
            'definieren ein Element-Schema, das für jedes Element der Liste gilt.',
        zh: '对象节点可以添加命名属性和必填标记，数组节点则定义一个适用于列表每个元素的元素 Schema。',
      ),
      icon: Icons.widgets_rounded,
      badges: [context.lazyTranslate(en: 'Structure', de: 'Struktur', zh: '结构')],
    ),
    _ExplainationEntry(
      title: context.lazyTranslate(en: 'Capabilities', de: 'Fähigkeiten', zh: '能力'),
      description: context.lazyTranslate(
        en:
            'Capabilities add validation rules or metadata to a node. The guide below only lists '
            'capabilities that are currently enabled for this editor configuration.',
        de:
            'Fähigkeiten ergänzen einen Knoten um Validierungsregeln oder Metadaten. Unten '
            'werden nur die Fähigkeiten gelistet, die in dieser Editor-Konfiguration aktiviert sind.',
        zh: '能力会为节点添加校验规则或元数据。下方只会列出当前编辑器配置中已启用的能力。',
      ),
      icon: Icons.tune_rounded,
      badges: [
        if (controller.extensionOptions.allowAddExtensions)
          context.lazyTranslate(
            en: 'Custom extensions allowed',
            de: 'Eigene Erweiterungen erlaubt',
            zh: '允许自定义扩展',
          ),
        if (!controller.extensionOptions.allowAddExtensions)
          context.lazyTranslate(
            en: 'Custom extensions restricted',
            de: 'Eigene Erweiterungen eingeschränkt',
            zh: '自定义扩展受限',
          ),
      ],
    ),
    _ExplainationEntry(
      title: context.lazyTranslate(
        en: 'Composition keywords',
        de: 'Kompositions-Keywords',
        zh: '组合关键字',
      ),
      description: context.lazyTranslate(
        en:
            'Keywords like const, allOf, oneOf, and \$ref let a schema pin a fixed value, combine '
            'constraints, or reference another schema definition.',
        de:
            'Keywords wie const, allOf, oneOf und \$ref erlauben feste Werte, das Kombinieren '
            'von Einschränkungen oder Verweise auf andere Schema-Definitionen.',
        zh: 'const、allOf、oneOf 和 \$ref 等关键字可用于固定值、组合约束或引用其他 Schema 定义。',
      ),
      icon: Icons.merge_type_rounded,
      badges: [context.lazyTranslate(en: 'Advanced', de: 'Erweitert', zh: '高级')],
    ),
  ];
}

List<_ExplainationEntry> _nodeTypeEntries(BuildContext context) {
  return JsonSchemaNodeType.values
      .map((type) {
        return _ExplainationEntry(
          title: jsonSchemaTypeLabel(context, type),
          description: jsonSchemaTypeHelp(context, type),
          icon: _nodeTypeIcon(type),
          badges: [type.toJsonType()],
        );
      })
      .toList(growable: false);
}

List<_ExplainationEntry> _capabilityEntries(
  BuildContext context,
  JsonSchemaEditorController controller,
) {
  final featureOptions = controller.featureOptions;
  final stringOptions = featureOptions.stringOptions;
  final numberOptions = featureOptions.numberOptions;
  final booleanOptions = featureOptions.booleanOptions;
  final arrayOptions = featureOptions.arrayOptions;
  final objectOptions = featureOptions.objectOptions;
  final allNodesBadge = context.lazyTranslate(en: 'All nodes', de: 'Alle Knoten', zh: '所有节点');
  final objectBadge = jsonSchemaTypeLabel(context, JsonSchemaNodeType.object);
  final objectPropertiesBadge = context.lazyTranslate(
    en: 'Object properties',
    de: 'Objekt-Properties',
    zh: '对象属性',
  );
  final arrayBadge = jsonSchemaTypeLabel(context, JsonSchemaNodeType.array);
  final stringBadge = jsonSchemaTypeLabel(context, JsonSchemaNodeType.string);
  final numberBadge = jsonSchemaTypeLabel(context, JsonSchemaNodeType.number);
  final integerBadge = jsonSchemaTypeLabel(context, JsonSchemaNodeType.integer);
  final booleanBadge = jsonSchemaTypeLabel(context, JsonSchemaNodeType.boolean);

  return <_ExplainationEntry>[
    _capabilityEntry(
      title: jsonSchemaKeywordLabel(context, 'title'),
      description: jsonSchemaHelpByKeyword(context, 'title')!,
      icon: Icons.title_rounded,
      badges: [allNodesBadge],
    ),
    _capabilityEntry(
      title: jsonSchemaKeywordLabel(context, 'description'),
      description: jsonSchemaHelpByKeyword(context, 'description')!,
      icon: Icons.notes_rounded,
      badges: [allNodesBadge],
    ),
    _capabilityEntry(
      title: 'const',
      description: jsonSchemaHelpByKeyword(context, 'const')!,
      icon: Icons.push_pin_rounded,
      badges: [allNodesBadge],
    ),
    _capabilityEntry(
      title: r'$ref',
      description: jsonSchemaHelpByKeyword(context, r'$ref')!,
      icon: Icons.link_rounded,
      badges: [allNodesBadge],
    ),
    _capabilityEntry(
      title: 'allOf',
      description: jsonSchemaHelpByKeyword(context, 'allOf')!,
      icon: Icons.call_merge_rounded,
      badges: [allNodesBadge],
    ),
    _capabilityEntry(
      title: 'oneOf',
      description: jsonSchemaHelpByKeyword(context, 'oneOf')!,
      icon: Icons.alt_route_rounded,
      badges: [allNodesBadge],
    ),
    _capabilityEntry(
      title: jsonSchemaKeywordLabel(context, 'properties'),
      description: jsonSchemaHelpByKeyword(context, 'properties')!,
      icon: Icons.view_list_rounded,
      badges: [objectBadge],
    ),
    _capabilityEntry(
      title: jsonSchemaKeywordLabel(context, 'required'),
      description: jsonSchemaHelpByKeyword(context, 'required')!,
      icon: Icons.star_rounded,
      badges: [objectPropertiesBadge],
    ),
    _capabilityEntry(
      title: context.lazyTranslate(en: 'Array items', de: 'Array-Elemente', zh: '数组元素'),
      description: jsonSchemaHelpByKeyword(context, 'items')!,
      icon: Icons.inventory_2_rounded,
      badges: [arrayBadge],
    ),
    if (stringOptions.minLength)
      _capabilityEntry(
        title: jsonSchemaKeywordLabel(context, 'minLength'),
        description: jsonSchemaHelpByKeyword(context, 'minLength')!,
        icon: Icons.straighten_rounded,
        badges: [stringBadge],
      ),
    if (stringOptions.maxLength)
      _capabilityEntry(
        title: jsonSchemaKeywordLabel(context, 'maxLength'),
        description: jsonSchemaHelpByKeyword(context, 'maxLength')!,
        icon: Icons.width_normal_rounded,
        badges: [stringBadge],
      ),
    if (stringOptions.pattern)
      _capabilityEntry(
        title: jsonSchemaKeywordLabel(context, 'pattern'),
        description: jsonSchemaHelpByKeyword(context, 'pattern')!,
        icon: Icons.pattern_rounded,
        badges: [stringBadge],
      ),
    if (stringOptions.enumValues)
      _capabilityEntry(
        title: jsonSchemaKeywordLabel(context, 'enum'),
        description: jsonSchemaHelpByKeyword(context, 'enum')!,
        icon: Icons.list_alt_rounded,
        badges: [stringBadge],
      ),
    if (numberOptions.minimum)
      _capabilityEntry(
        title: jsonSchemaKeywordLabel(context, 'minimum'),
        description: jsonSchemaHelpByKeyword(context, 'minimum')!,
        icon: Icons.exposure_neg_1_rounded,
        badges: [numberBadge, integerBadge],
      ),
    if (numberOptions.maximum)
      _capabilityEntry(
        title: jsonSchemaKeywordLabel(context, 'maximum'),
        description: jsonSchemaHelpByKeyword(context, 'maximum')!,
        icon: Icons.exposure_plus_1_rounded,
        badges: [numberBadge, integerBadge],
      ),
    if (numberOptions.exclusiveMinimum)
      _capabilityEntry(
        title: jsonSchemaKeywordLabel(context, 'exclusiveMinimum'),
        description: jsonSchemaHelpByKeyword(context, 'exclusiveMinimum')!,
        icon: Icons.lock_open_rounded,
        badges: [numberBadge, integerBadge],
      ),
    if (numberOptions.exclusiveMaximum)
      _capabilityEntry(
        title: jsonSchemaKeywordLabel(context, 'exclusiveMaximum'),
        description: jsonSchemaHelpByKeyword(context, 'exclusiveMaximum')!,
        icon: Icons.lock_outline_rounded,
        badges: [numberBadge, integerBadge],
      ),
    if (numberOptions.multipleOf)
      _capabilityEntry(
        title: jsonSchemaKeywordLabel(context, 'multipleOf'),
        description: jsonSchemaHelpByKeyword(context, 'multipleOf')!,
        icon: Icons.repeat_rounded,
        badges: [numberBadge, integerBadge],
      ),
    if (booleanOptions.defaultValue)
      _capabilityEntry(
        title: jsonSchemaKeywordLabel(context, 'default'),
        description: jsonSchemaHelpByKeyword(context, 'default')!,
        icon: Icons.toggle_on_rounded,
        badges: [booleanBadge],
      ),
    if (arrayOptions.minItems)
      _capabilityEntry(
        title: jsonSchemaKeywordLabel(context, 'minItems'),
        description: jsonSchemaHelpByKeyword(context, 'minItems')!,
        icon: Icons.format_list_numbered_rounded,
        badges: [arrayBadge],
      ),
    if (arrayOptions.maxItems)
      _capabilityEntry(
        title: jsonSchemaKeywordLabel(context, 'maxItems'),
        description: jsonSchemaHelpByKeyword(context, 'maxItems')!,
        icon: Icons.format_list_numbered_rtl_rounded,
        badges: [arrayBadge],
      ),
    if (arrayOptions.uniqueItems)
      _capabilityEntry(
        title: jsonSchemaKeywordLabel(context, 'uniqueItems'),
        description: jsonSchemaHelpByKeyword(context, 'uniqueItems')!,
        icon: Icons.filter_1_rounded,
        badges: [arrayBadge],
      ),
    if (objectOptions.additionalProperties)
      _capabilityEntry(
        title: jsonSchemaKeywordLabel(context, 'additionalProperties'),
        description: jsonSchemaHelpByKeyword(context, 'additionalProperties')!,
        icon: Icons.add_box_rounded,
        badges: [objectBadge],
      ),
    _capabilityEntry(
      title: jsonSchemaKeywordLabel(context, 'extensionField'),
      description: jsonSchemaHelpByKeyword(context, 'extensionField')!,
      icon: Icons.extension_rounded,
      badges: [
        if (controller.extensionOptions.allowAddExtensions)
          context.lazyTranslate(en: 'Custom keys allowed', de: 'Eigene Keys erlaubt', zh: '允许自定义键'),
        if (!controller.extensionOptions.allowAddExtensions)
          context.lazyTranslate(
            en: 'Configured keys only',
            de: 'Nur konfigurierte Keys',
            zh: '仅允许已配置键',
          ),
      ],
    ),
  ];
}

_ExplainationEntry _capabilityEntry({
  required String title,
  required String description,
  required IconData icon,
  required List<String> badges,
}) {
  return _ExplainationEntry(title: title, description: description, icon: icon, badges: badges);
}

List<_ExplainationEntry> _configuredExtensionEntries(
  BuildContext context,
  JsonSchemaEditorController controller,
) {
  final merged = <String, _ConfiguredExtensionExplaination>{};
  final extensionOptions = controller.extensionOptions;
  for (final field in extensionOptions.configurableExtensions) {
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
        label: field.resolveDisplayLabel(context),
        description:
            field.resolveDescription(context) ??
            context.lazyTranslate(
              en: 'Configured custom schema extension.',
              de: 'Konfigurierte eigene Schema-Erweiterung.',
              zh: '已配置的自定义 Schema 扩展。',
            ),
        valueType: field.valueType,
        nodeTypes: {...nextNodeTypes},
        scopes: {...nextScopes},
      );
      continue;
    }

    merged[key] = existing.copyWith(
      label: existing.label.isEmpty ? field.resolveDisplayLabel(context) : existing.label,
      description: existing.description.isEmpty
          ? (field.resolveDescription(context) ?? existing.description)
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
            _extensionValueTypeLabel(context, entry.valueType),
            _nodeTypeSummary(context, entry.nodeTypes),
            _scopeSummary(context, entry.scopes),
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

String _extensionValueTypeLabel(BuildContext context, JsonSchemaEditorExtensionFieldType type) {
  return switch (type) {
    JsonSchemaEditorExtensionFieldType.string => context.lazyTranslate(
      en: 'String value',
      de: 'String-Wert',
      zh: '字符串值',
    ),
    JsonSchemaEditorExtensionFieldType.number => context.lazyTranslate(
      en: 'Number value',
      de: 'Zahlenwert',
      zh: '数值',
    ),
    JsonSchemaEditorExtensionFieldType.boolean => context.lazyTranslate(
      en: 'Boolean value',
      de: 'Boolean Wert',
      zh: '布尔值',
    ),
    JsonSchemaEditorExtensionFieldType.stringEnum => context.lazyTranslate(
      en: 'Enum value',
      de: 'Enum-Wert',
      zh: '枚举值',
    ),
  };
}

String _nodeTypeSummary(BuildContext context, Set<JsonSchemaNodeType> types) {
  if (types.length == JsonSchemaNodeType.values.length) {
    return context.lazyTranslate(en: 'All node types', de: 'Alle Knotentypen', zh: '所有节点类型');
  }
  final labels = types.map((type) => jsonSchemaTypeLabel(context, type)).toList(growable: false)
    ..sort();
  return labels.join(' / ');
}

String _scopeSummary(BuildContext context, Set<JsonSchemaEditorExtensionFieldScope> scopes) {
  if (scopes.length == JsonSchemaEditorExtensionFieldScope.values.length) {
    return context.lazyTranslate(en: 'All scopes', de: 'Alle Bereiche', zh: '所有作用域');
  }
  final labels =
      scopes
          .map((scope) {
            return switch (scope) {
              JsonSchemaEditorExtensionFieldScope.root => context.lazyTranslate(
                en: 'Root',
                de: 'Root',
                zh: '根节点',
              ),
              JsonSchemaEditorExtensionFieldScope.objectProperty => context.lazyTranslate(
                en: 'Property',
                de: 'Property',
                zh: '属性',
              ),
              JsonSchemaEditorExtensionFieldScope.arrayItem => context.lazyTranslate(
                en: 'Array item',
                de: 'Array-Element',
                zh: '数组元素',
              ),
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
