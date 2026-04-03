part of '../editor.dart';

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
