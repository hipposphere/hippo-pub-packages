part of '../editor.dart';

class _StringExtensionNodeField extends StatelessWidget {
  const _StringExtensionNodeField({
    required this.controller,
    required this.path,
    required this.extensionKey,
    required this.extensionValue,
    this.minLines = 1,
    this.maxLines = 1,
    this.helpText,
  });

  final JsonSchemaEditorController controller;
  final JsonSchemaPath path;
  final String extensionKey;
  final String extensionValue;
  final int minLines;
  final int maxLines;
  final String? helpText;

  @override
  Widget build(BuildContext context) {
    return _StringCapabilityField(
      value: extensionValue,
      hint: extensionKey,
      helpText: helpText,
      minLines: minLines,
      maxLines: maxLines,
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

class _StringCapabilityField extends StatelessWidget {
  const _StringCapabilityField({
    required this.value,
    required this.hint,
    required this.onChanged,
    required this.onEmpty,
    required this.onRemove,
    this.helpText,
    this.minLines = 1,
    this.maxLines = 1,
    this.keyboardType,
  }) : assert(minLines > 0, 'minLines must be greater than 0'),
       assert(maxLines >= minLines, 'maxLines must be greater than or equal to minLines');

  final String? value;
  final String hint;
  final ValueChanged<String> onChanged;
  final VoidCallback onEmpty;
  final VoidCallback onRemove;
  final String? helpText;
  final int minLines;
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
            minLines: minLines,
            maxLines: maxLines,
            keyboardType: keyboardType,
            onChanged: onChanged,
            onCleared: onEmpty,
          ),
        ),
        const Gap(4),
        JsonSchemaEditorActionIconButton(
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
        JsonSchemaEditorActionIconButton(
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
