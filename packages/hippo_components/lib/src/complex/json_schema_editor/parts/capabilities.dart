part of '../editor.dart';

class _CapabilityOption {
  const _CapabilityOption({
    required this.icon,
    required this.label,
    required this.description,
    required this.onSelected,
  });

  final IconData icon;
  final String label;
  final String description;
  final Future<void> Function(BuildContext context) onSelected;
}

Future<void> _showAddCapabilityDialog({
  required BuildContext context,
  required List<_CapabilityOption> options,
}) async {
  if (options.isEmpty) {
    return;
  }

  final sortedOptions = options.toList(growable: false)
    ..sort((left, right) => left.label.compareTo(right.label));

  final modal = AdaptiveCupertinoModal(
    barrierDismissible: true,
    builder: (dialogContext, isDesktop, scrollController) {
      final colorScheme = Theme.of(dialogContext).colorScheme;

      return CupertinoModalPageContainer(
        title: Text(
          dialogContext.lazyTranslate(en: 'Add capability', de: 'Fähigkeit hinzufügen', zh: '添加能力'),
        ),
        child: ListView.builder(
          controller: scrollController,
          padding: EdgeInsets.fromLTRB(isDesktop ? 24 : 16, 0, isDesktop ? 24 : 16, 8),
          itemCount: sortedOptions.length,
          itemBuilder: (context, index) {
            final option = sortedOptions[index];
            return Tile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              showArrowIndicator: true,
              leading: CircleAvatar(
                radius: 18,
                backgroundColor: colorScheme.secondaryContainer,
                foregroundColor: colorScheme.onSecondaryContainer,
                child: Icon(option.icon, size: 18),
              ),
              title: Text(option.label),
              subtitle: Text(option.description),
              onTap: () {
                Navigator.of(dialogContext).pop();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  option.onSelected(context);
                });
              },
            );
          },
        ),
      );
    },
  );

  await modal.show<void>(context);
}

List<_CapabilityOption> _availableCapabilityOptions({
  required BuildContext context,
  required JsonSchemaNode node,
  required JsonSchemaPath path,
  required JsonSchemaEditorController controller,
  required JsonSchemaEditorFeatureOptions featureOptions,
  required List<JsonSchemaEditorExtensionField> configuredExtensions,
}) {
  final options = <_CapabilityOption>[
    ..._nodeCapabilityOptions(
      context: context,
      node: node,
      path: path,
      controller: controller,
      featureOptions: featureOptions,
    ),
    ..._extensionCapabilityOptions(
      context: context,
      node: node,
      path: path,
      controller: controller,
      configuredExtensions: configuredExtensions,
    ),
  ];

  if (controller.extensionOptions.allowAddExtensions) {
    options.add(
      _CapabilityOption(
        icon: Icons.extension_rounded,
        label: context.lazyTranslate(en: 'Custom extension', de: 'Eigene Erweiterung', zh: '自定义扩展'),
        description: context.lazyTranslate(
          en: 'Add a custom schema extension key/value entry.',
          de: 'Fügt einen eigenen Schema-Erweiterungseintrag als Schlüssel/Wert hinzu.',
          zh: '添加一个自定义 Schema 扩展键值项。',
        ),
        onSelected: (context) => _showCustomExtensionDialog(
          context: context,
          controller: controller,
          path: path,
          existingExtensionKeys: node.extensions.keys
              .map((entry) => entry.trim())
              .where((entry) => !_isInternalSchemaExtensionKey(entry))
              .toSet(),
        ),
      ),
    );
  }

  return options;
}

bool _hasVisibleNodeCapabilities({
  required JsonSchemaNode node,
  required JsonSchemaEditorFeatureOptions featureOptions,
}) {
  final stringOptions = featureOptions.stringOptions;
  final numberOptions = featureOptions.numberOptions;
  final booleanOptions = featureOptions.booleanOptions;
  final objectOptions = featureOptions.objectOptions;
  final arrayOptions = featureOptions.arrayOptions;

  return switch (node) {
    JsonSchemaStringNode() =>
      (stringOptions.minLength && node.minLength != null) ||
          (stringOptions.maxLength && node.maxLength != null) ||
          (stringOptions.pattern && node.pattern != null && node.pattern!.trim().isNotEmpty) ||
          (stringOptions.enumValues && node.enumValues != null),
    JsonSchemaNumberNode() =>
      (numberOptions.minimum && node.minimum != null) ||
          (numberOptions.maximum && node.maximum != null) ||
          (numberOptions.exclusiveMinimum && node.exclusiveMinimum != null) ||
          (numberOptions.exclusiveMaximum && node.exclusiveMaximum != null) ||
          (numberOptions.multipleOf && node.multipleOf != null),
    JsonSchemaBooleanNode() => booleanOptions.defaultValue && node.defaultValue != null,
    JsonSchemaObjectNode() => objectOptions.additionalProperties && !node.additionalProperties,
    JsonSchemaArrayNode() =>
      (arrayOptions.minItems && node.minItems != null) ||
          (arrayOptions.maxItems && node.maxItems != null) ||
          (arrayOptions.uniqueItems && node.uniqueItems != null),
  };
}

List<_CapabilityOption> _extensionCapabilityOptions({
  required BuildContext context,
  required JsonSchemaNode node,
  required JsonSchemaPath path,
  required JsonSchemaEditorController controller,
  required List<JsonSchemaEditorExtensionField> configuredExtensions,
}) {
  final options = <_CapabilityOption>[];
  for (final field in configuredExtensions) {
    final key = field.key.trim();
    if (key.isEmpty || node.extensions.containsKey(key)) {
      continue;
    }
    options.add(
      _CapabilityOption(
        icon: Icons.extension_rounded,
        label: field.resolveDisplayLabel(context),
        description:
            field.resolveDescription(context) ??
            context.lazyTranslate(
              en: 'Configured schema extension.',
              de: 'Konfigurierte Schema-Erweiterung.',
              zh: '已配置的 Schema 扩展。',
            ),
        onSelected: (context) async {
          controller.setNodeField(path: path, key: key, value: _initialValueForField(field));
        },
      ),
    );
  }
  return options;
}

List<_CapabilityOption> _nodeCapabilityOptions({
  required BuildContext context,
  required JsonSchemaNode node,
  required JsonSchemaPath path,
  required JsonSchemaEditorController controller,
  required JsonSchemaEditorFeatureOptions featureOptions,
}) {
  final stringOptions = featureOptions.stringOptions;
  final numberOptions = featureOptions.numberOptions;
  final booleanOptions = featureOptions.booleanOptions;
  final objectOptions = featureOptions.objectOptions;
  final arrayOptions = featureOptions.arrayOptions;

  return switch (node) {
    JsonSchemaStringNode() => [
      if (stringOptions.minLength && node.minLength == null)
        _CapabilityOption(
          icon: Icons.straighten_rounded,
          label: jsonSchemaKeywordLabel(context, 'minLength'),
          description: jsonSchemaHelpByKeyword(context, 'minLength')!,
          onSelected: (context) async => controller.updateNode(
            path: path,
            updater: (JsonSchemaStringNode node) => node.copyWith(minLength: 0),
          ),
        ),
      if (stringOptions.maxLength && node.maxLength == null)
        _CapabilityOption(
          icon: Icons.width_normal_rounded,
          label: jsonSchemaKeywordLabel(context, 'maxLength'),
          description: jsonSchemaHelpByKeyword(context, 'maxLength')!,
          onSelected: (context) async => controller.updateNode(
            path: path,
            updater: (JsonSchemaStringNode node) => node.copyWith(maxLength: node.minLength ?? 1),
          ),
        ),
      if (stringOptions.pattern && (node.pattern == null || node.pattern!.trim().isEmpty))
        _CapabilityOption(
          icon: Icons.pattern_rounded,
          label: jsonSchemaKeywordLabel(context, 'pattern'),
          description: jsonSchemaHelpByKeyword(context, 'pattern')!,
          onSelected: (context) async => controller.updateNode(
            path: path,
            updater: (JsonSchemaStringNode node) => node.copyWith(pattern: '.*'),
          ),
        ),
      if (stringOptions.enumValues && node.enumValues == null)
        _CapabilityOption(
          icon: Icons.list_alt_rounded,
          label: jsonSchemaKeywordLabel(context, 'enum'),
          description: jsonSchemaHelpByKeyword(context, 'enum')!,
          onSelected: (context) async => controller.updateNode(
            path: path,
            updater: (JsonSchemaStringNode node) => node.copyWith(enumValues: const ['value']),
          ),
        ),
    ],
    JsonSchemaNumberNode() => [
      if (numberOptions.minimum && node.minimum == null)
        _CapabilityOption(
          icon: Icons.exposure_neg_1_rounded,
          label: jsonSchemaKeywordLabel(context, 'minimum'),
          description: jsonSchemaHelpByKeyword(context, 'minimum')!,
          onSelected: (context) async => controller.updateNode(
            path: path,
            updater: (JsonSchemaNumberNode node) => node.copyWith(minimum: 0),
          ),
        ),
      if (numberOptions.maximum && node.maximum == null)
        _CapabilityOption(
          icon: Icons.exposure_plus_1_rounded,
          label: jsonSchemaKeywordLabel(context, 'maximum'),
          description: jsonSchemaHelpByKeyword(context, 'maximum')!,
          onSelected: (context) async => controller.updateNode(
            path: path,
            updater: (JsonSchemaNumberNode node) => node.copyWith(maximum: node.minimum ?? 1),
          ),
        ),
      if (numberOptions.exclusiveMinimum && node.exclusiveMinimum == null)
        _CapabilityOption(
          icon: Icons.chevron_left_rounded,
          label: jsonSchemaKeywordLabel(context, 'exclusiveMinimum'),
          description: jsonSchemaHelpByKeyword(context, 'exclusiveMinimum')!,
          onSelected: (context) async => controller.updateNode(
            path: path,
            updater: (JsonSchemaNumberNode node) => node.copyWith(exclusiveMinimum: false),
          ),
        ),
      if (numberOptions.exclusiveMaximum && node.exclusiveMaximum == null)
        _CapabilityOption(
          icon: Icons.chevron_right_rounded,
          label: jsonSchemaKeywordLabel(context, 'exclusiveMaximum'),
          description: jsonSchemaHelpByKeyword(context, 'exclusiveMaximum')!,
          onSelected: (context) async => controller.updateNode(
            path: path,
            updater: (JsonSchemaNumberNode node) => node.copyWith(exclusiveMaximum: false),
          ),
        ),
      if (numberOptions.multipleOf && node.multipleOf == null)
        _CapabilityOption(
          icon: Icons.percent_rounded,
          label: jsonSchemaKeywordLabel(context, 'multipleOf'),
          description: jsonSchemaHelpByKeyword(context, 'multipleOf')!,
          onSelected: (context) async => controller.updateNode(
            path: path,
            updater: (JsonSchemaNumberNode node) => node.copyWith(multipleOf: 1),
          ),
        ),
    ],
    JsonSchemaBooleanNode() => [
      if (booleanOptions.defaultValue && node.defaultValue == null)
        _CapabilityOption(
          icon: Icons.toggle_on_rounded,
          label: jsonSchemaKeywordLabel(context, 'default'),
          description: jsonSchemaHelpByKeyword(context, 'default')!,
          onSelected: (context) async => controller.updateNode(
            path: path,
            updater: (JsonSchemaBooleanNode node) => node.copyWith(defaultValue: false),
          ),
        ),
    ],
    JsonSchemaObjectNode() => [
      if (objectOptions.additionalProperties && node.additionalProperties)
        _CapabilityOption(
          icon: Icons.data_object_rounded,
          label: jsonSchemaKeywordLabel(context, 'additionalProperties'),
          description: jsonSchemaHelpByKeyword(context, 'additionalProperties')!,
          onSelected: (context) async => controller.updateNode(
            path: path,
            updater: (JsonSchemaObjectNode node) => node.copyWith(additionalProperties: false),
          ),
        ),
    ],
    JsonSchemaArrayNode() => [
      if (arrayOptions.minItems && node.minItems == null)
        _CapabilityOption(
          icon: Icons.format_list_numbered_rounded,
          label: jsonSchemaKeywordLabel(context, 'minItems'),
          description: jsonSchemaHelpByKeyword(context, 'minItems')!,
          onSelected: (context) async => controller.updateNode(
            path: path,
            updater: (JsonSchemaArrayNode node) => node.copyWith(minItems: 0),
          ),
        ),
      if (arrayOptions.maxItems && node.maxItems == null)
        _CapabilityOption(
          icon: Icons.format_list_numbered_rtl_rounded,
          label: jsonSchemaKeywordLabel(context, 'maxItems'),
          description: jsonSchemaHelpByKeyword(context, 'maxItems')!,
          onSelected: (context) async => controller.updateNode(
            path: path,
            updater: (JsonSchemaArrayNode node) => node.copyWith(maxItems: node.minItems ?? 1),
          ),
        ),
      if (arrayOptions.uniqueItems && node.uniqueItems == null)
        _CapabilityOption(
          icon: Icons.fingerprint_rounded,
          label: jsonSchemaKeywordLabel(context, 'uniqueItems'),
          description: jsonSchemaHelpByKeyword(context, 'uniqueItems')!,
          onSelected: (context) async => controller.updateNode(
            path: path,
            updater: (JsonSchemaArrayNode node) => node.copyWith(uniqueItems: false),
          ),
        ),
    ],
  };
}
