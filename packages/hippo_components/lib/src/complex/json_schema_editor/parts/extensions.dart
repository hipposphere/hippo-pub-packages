part of '../editor.dart';

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
    final keywordHelpText = jsonSchemaHelpByKeyword(context, extensionKey);
    final helpText = extensionField?.normalizedDescription ?? keywordHelpText;
    final extensionLabel = extensionField?.displayLabel ?? extensionKey;

    switch (extensionKey) {
      case 'const':
        return Padding(
          padding: const EdgeInsets.only(bottom: _editorSectionSpacing),
          child: _JsonValueExtensionNodeField(
            controller: controller,
            path: path,
            extensionKey: extensionKey,
            extensionLabel: extensionLabel,
            extensionValue: extensionValue,
            helpText: helpText,
          ),
        );
      case 'allOf':
      case 'oneOf':
        return Padding(
          padding: const EdgeInsets.only(bottom: _editorSectionSpacing),
          child: _JsonArrayExtensionNodeField(
            controller: controller,
            path: path,
            extensionKey: extensionKey,
            extensionLabel: extensionLabel,
            extensionValue: extensionValue,
            helpText: helpText,
          ),
        );
      case r'$ref':
        return Padding(
          padding: const EdgeInsets.only(bottom: _editorSectionSpacing),
          child: _StringExtensionNodeField(
            controller: controller,
            path: path,
            extensionKey: extensionKey,
            extensionLabel: extensionLabel,
            extensionValue: _extensionValueAsString(extensionValue),
            helpText: helpText,
          ),
        );
    }

    final fieldType = _resolveExtensionFieldType(
      extensionValue: extensionValue,
      configuredField: extensionField,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: _editorSectionSpacing),
      child: switch (fieldType) {
        JsonSchemaEditorExtensionFieldType.string => _StringExtensionNodeField(
          controller: controller,
          path: path,
          extensionKey: extensionKey,
          extensionLabel: extensionLabel,
          extensionValue: _extensionValueAsString(extensionValue),
          minLines: extensionField?.minLines ?? 1,
          maxLines: extensionField?.maxLines ?? 1,
          helpText: helpText,
        ),
        JsonSchemaEditorExtensionFieldType.stringEnum => _StringEnumExtensionNodeField(
          controller: controller,
          path: path,
          extensionKey: extensionKey,
          extensionLabel: extensionLabel,
          extensionValue: _extensionValueAsString(extensionValue),
          values: extensionField?.availableEnumValues ?? const [],
          helpText: helpText,
        ),
        JsonSchemaEditorExtensionFieldType.number => _NumberExtensionNodeField(
          controller: controller,
          path: path,
          extensionKey: extensionKey,
          extensionLabel: extensionLabel,
          extensionValue: extensionValue,
          helpText: helpText,
        ),
        JsonSchemaEditorExtensionFieldType.boolean => _BooleanExtensionNodeField(
          controller: controller,
          path: path,
          extensionKey: extensionKey,
          extensionLabel: extensionLabel,
          extensionValue: extensionValue is bool ? (extensionValue as bool) : false,
          helpText: helpText,
        ),
      },
    );
  }
}

class _JsonValueExtensionNodeField extends StatelessWidget {
  const _JsonValueExtensionNodeField({
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
    return _StringCapabilityField(
      value: _jsonValueAsInput(extensionValue),
      hint: context.lazyTranslate(
        en: '$extensionLabel (JSON)',
        de: '$extensionLabel (JSON)',
        zh: '$extensionLabel（JSON）',
      ),
      helpText: helpText,
      maxLines: extensionValue is Map || extensionValue is List ? 8 : 4,
      onChanged: (next) => _updateJsonValue(
        next,
        (parsed) => controller.setNodeField(path: path, key: extensionKey, value: parsed),
        () => controller.removeNodeField(path: path, key: extensionKey),
      ),
      onEmpty: () => controller.removeNodeField(path: path, key: extensionKey),
      onRemove: () => controller.removeNodeField(path: path, key: extensionKey),
    );
  }
}

class _JsonArrayExtensionNodeField extends StatelessWidget {
  const _JsonArrayExtensionNodeField({
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
    final value = extensionValue is List ? extensionValue : const <Object?>[];
    return _StringCapabilityField(
      value: _jsonValueAsInput(value),
      hint: context.lazyTranslate(
        en: '$extensionLabel (JSON array)',
        de: '$extensionLabel (JSON-Array)',
        zh: '$extensionLabel（JSON 数组）',
      ),
      helpText: helpText,
      maxLines: 10,
      onChanged: (next) => _updateJsonArray(
        next,
        (parsed) => controller.setNodeField(path: path, key: extensionKey, value: parsed),
        () => controller.removeNodeField(path: path, key: extensionKey),
      ),
      onEmpty: () => controller.removeNodeField(path: path, key: extensionKey),
      onRemove: () => controller.removeNodeField(path: path, key: extensionKey),
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
        title: Text(
          dialogContext.lazyTranslate(
            en: 'Add custom extension',
            de: 'Eigene Erweiterung hinzufügen',
            zh: '添加自定义扩展',
          ),
        ),
        content: TextField(
          controller: keyController,
          decoration: InputDecoration(
            labelText: dialogContext.lazyTranslate(
              en: 'Extension key',
              de: 'Erweiterungs-Key',
              zh: '扩展键',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              dialogContext.lazyTranslate( en: 'Cancel', de: 'Abbrechen', zh: '取消'),
            ),
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
            child: Text(dialogContext.lazyTranslate( en: 'Add', de: 'Hinzufügen', zh: '添加')),
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
