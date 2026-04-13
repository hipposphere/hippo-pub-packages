part of '../editor.dart';

class _NumberExtensionNodeField extends StatelessWidget {
  const _NumberExtensionNodeField({
    required this.controller,
    required this.path,
    required this.extensionKey,
    required this.extensionLabel,
    required this.extensionValue,
    this.helpText,
  });

  final JsonSchemaEditorController controller;
  final JsonSchemaPath path;
  final String extensionKey;
  final String extensionLabel;
  final Object? extensionValue;
  final String? helpText;

  @override
  Widget build(BuildContext context) {
    final value = extensionValue == null ? '' : extensionValue.toString();
    return _StringCapabilityField(
      value: value,
      hint: extensionLabel,
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
    final numberOptions = featureOptions.numberOptions;
    final shortFields = <Widget>[
      if (showCapabilities && numberOptions.minimum && node.minimum != null)
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
      if (showCapabilities && numberOptions.maximum && node.maximum != null)
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
      if (showCapabilities && numberOptions.multipleOf && node.multipleOf != null)
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
            numberOptions.exclusiveMinimum &&
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
            numberOptions.exclusiveMaximum &&
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
