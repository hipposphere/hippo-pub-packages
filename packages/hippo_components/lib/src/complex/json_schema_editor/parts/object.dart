part of '../editor.dart';

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
    final propertyEntries = node.orderedPropertyEntries.toList(growable: false);
    final colorScheme = Theme.of(context).colorScheme;
    final objectOptions = featureOptions.objectOptions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (objectOptions.additionalProperties && !node.additionalProperties) ...[
          _BooleanCapabilityField(
            label: context.lazyTranslate(
              en: 'Additional props',
              de: 'Zusätzliche Props',
              zh: '额外属性',
            ),
            value: node.additionalProperties,
            helpText: jsonSchemaHelpByKeyword(context, 'additionalProperties'),
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

        Wrap(
          spacing: _editorSectionSpacing,
          runSpacing: _editorSectionSpacing,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _EditorSectionLabel(
              label: jsonSchemaKeywordLabel(context, 'properties'),
              helpText: jsonSchemaHelpByKeyword(context, 'properties'),
            ),
          ],
        ),
        const Gap(_editorSectionSpacing),

        if (propertyEntries.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.7)),
            ),
            child: Text(
              context.lazyTranslate(
                en: 'No properties defined yet.',
                de: 'Noch keine Properties definiert.',
                zh: '尚未定义任何属性。',
              ),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ),

        ...List.generate(propertyEntries.length, (index) {
          final entry = propertyEntries[index];
          final propertyPath = path.childProperty(entry.key);
          final propertyNode = entry.value;
          final required = node.required.contains(entry.key);

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: JsonSchemaPropertyCard(
              key: ValueKey('property-card-${entry.key}'),
              children: [
                JsonSchemaObjectPropertyHeader(
                  propertyKey: entry.key,
                  nodeType: propertyNode.type,
                  required: required,
                  propertyKeyHelpText: jsonSchemaHelpByKeyword(context, 'propertyKey'),
                  requiredHelpText: jsonSchemaHelpByKeyword(context, 'required'),
                  onPropertyKeyChanged: (nextKey) => controller.renameProperty(
                    objectPath: path,
                    currentKey: entry.key,
                    nextKey: nextKey,
                  ),
                  onTypeChanged: (nextType) => controller.replaceNode(
                    path: propertyPath,
                    node: _defaultNodeForTypePreservingMetadata(propertyNode, nextType),
                  ),
                  onRequiredChanged: (nextRequired) => controller.setRequired(
                    objectPath: path,
                    key: entry.key,
                    required: nextRequired,
                  ),
                  onMoveUp: index == 0
                      ? null
                      : () => controller.movePropertyUp(objectPath: path, key: entry.key),
                  onMoveDown: index == propertyEntries.length - 1
                      ? null
                      : () => controller.movePropertyDown(objectPath: path, key: entry.key),
                  onRemove: () => controller.removeProperty(objectPath: path, key: entry.key),
                ),
                Gap(16),
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
        }),
        Gap(16),
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
          label: context.lazyTranslate(
            en: 'Add property',
            de: 'Property hinzufügen',
            zh: '添加属性',
          ),
        ),
        Gap(8),
      ],
    );
  }
}
