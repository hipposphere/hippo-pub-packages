part of '../editor.dart';

class _StringExtensionNodeField extends StatelessWidget {
  const _StringExtensionNodeField({
    required this.controller,
    required this.path,
    required this.extensionKey,
    required this.extensionLabel,
    required this.extensionValue,
    this.minLines = 1,
    this.maxLines = 1,
    this.helpText,
  });

  final JsonSchemaEditorController controller;
  final JsonSchemaPath path;
  final String extensionKey;
  final String extensionLabel;
  final String extensionValue;
  final int minLines;
  final int maxLines;
  final String? helpText;

  @override
  Widget build(BuildContext context) {
    return _StringCapabilityField(
      value: extensionValue,
      hint: extensionLabel,
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
    required this.extensionLabel,
    required this.extensionValue,
    required this.entries,
    this.helpText,
  });

  final JsonSchemaEditorController controller;
  final JsonSchemaPath path;
  final String extensionKey;
  final String extensionLabel;
  final String extensionValue;
  final List<JsonSchemaEditorExtensionEnumValue> entries;
  final String? helpText;

  @override
  Widget build(BuildContext context) {
    final valueEntries = entries
        .where((item) => item.normalizedValue != null)
        .toList(growable: false);
    final currentValue = _normalizeStringEnumValue(
      value: extensionValue,
      allowedValues: valueEntries.map((entry) => entry.normalizedValue!).toList(growable: false),
    );

    return _DropdownCapabilityField(
      label: extensionLabel,
      value: currentValue,
      entries: valueEntries,
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
          tooltip: context.lazyTranslate(
            en: 'Remove capability',
            de: 'Fähigkeit entfernen',
            zh: '移除能力',
          ),
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
    required this.entries,
    required this.onChanged,
    required this.onRemove,
    this.helpText,
  });

  final String label;
  final String? value;
  final List<JsonSchemaEditorExtensionEnumValue> entries;
  final ValueChanged<String?> onChanged;
  final VoidCallback onRemove;
  final String? helpText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notSetLabel = context.lazyTranslate(en: 'Not set', de: 'Nicht gesetzt', zh: '未设置');

    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: value,
            isExpanded: true,
            isDense: true,
            itemHeight: null,
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
            selectedItemBuilder: (context) => [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(notSetLabel, overflow: TextOverflow.ellipsis),
              ),
              ...entries.map(
                (entry) => Align(
                  alignment: Alignment.centerLeft,
                  child: _DropdownEntryLabel(
                    label: entry.resolveDisplayLabel(context),
                    description: entry.resolveDescription(context),
                    compact: true,
                  ),
                ),
              ),
            ],
            items: <DropdownMenuItem<String>>[
              DropdownMenuItem<String>(value: '', child: Text(notSetLabel)),
              ...entries.map((entry) {
                final value = entry.normalizedValue!;
                final displayLabel = entry.resolveDisplayLabel(context);
                final description = entry.resolveDescription(context);
                return DropdownMenuItem<String>(
                  value: value,
                  child: _DropdownEntryLabel(label: displayLabel, description: description),
                );
              }),
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
          tooltip: context.lazyTranslate(
            en: 'Remove extension',
            de: 'Erweiterung entfernen',
            zh: '移除扩展',
          ),
          icon: Icons.close,
          onPressed: onRemove,
        ),
      ],
    );
  }
}

class _DropdownEntryLabel extends StatelessWidget {
  const _DropdownEntryLabel({required this.label, this.description, this.compact = false});

  final String label;
  final String? description;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveDescription = description?.trim();
    if (effectiveDescription == null || effectiveDescription.isEmpty) {
      return Text(label, overflow: TextOverflow.ellipsis);
    }
    if (compact) {
      return RichText(
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          style: theme.textTheme.bodyMedium,
          children: [
            TextSpan(text: label),
            TextSpan(
              text: ' - $effectiveDescription',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, overflow: TextOverflow.ellipsis),
        const Gap(2),
        Text(
          effectiveDescription,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
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
    final stringOptions = featureOptions.stringOptions;
    final shortFields = <Widget>[
      if (showCapabilities && stringOptions.minLength && node.minLength != null)
        JsonSchemaEditorTextField(
          value: node.minLength?.toString(),
          hint: jsonSchemaKeywordLabel(context, 'minLength'),
          helpText: jsonSchemaHelpByKeyword(context, 'minLength'),
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
      if (showCapabilities && stringOptions.maxLength && node.maxLength != null)
        JsonSchemaEditorTextField(
          value: node.maxLength?.toString(),
          hint: jsonSchemaKeywordLabel(context, 'maxLength'),
          helpText: jsonSchemaHelpByKeyword(context, 'maxLength'),
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
            stringOptions.pattern &&
            node.pattern != null &&
            node.pattern!.trim().isNotEmpty) ...[
          JsonSchemaEditorTextField(
            value: node.pattern,
            hint: context.lazyTranslate(
              en: 'Pattern (RegExp)',
              de: 'Muster (RegExp)',
              zh: '模式（正则表达式）',
            ),
            helpText: jsonSchemaHelpByKeyword(context, 'pattern'),
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
        if (showCapabilities && stringOptions.enumValues && node.enumValues != null) ...[
          _StringCapabilityField(
            value: _stringEnumInput(node.enumValues),
            hint: context.lazyTranslate(
              en: 'Enum (comma/line list)',
              de: 'Enum (Komma-/Zeilenliste)',
              zh: '枚举（逗号或换行列表）',
            ),
            helpText: jsonSchemaHelpByKeyword(context, 'enum'),
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
