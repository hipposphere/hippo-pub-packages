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
        title: const Text('Add capability'),
        child: Material(
          type: MaterialType.transparency,
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
        ),
      );
    },
  );

  await modal.show<void>(context);
}

List<_CapabilityOption> _availableCapabilityOptions({
  required JsonSchemaNode node,
  required JsonSchemaPath path,
  required JsonSchemaEditorController controller,
  required JsonSchemaEditorFeatureOptions featureOptions,
  required List<JsonSchemaEditorExtensionField> configuredExtensions,
}) {
  final options = <_CapabilityOption>[
    ..._nodeCapabilityOptions(
      node: node,
      path: path,
      controller: controller,
      featureOptions: featureOptions,
    ),
    ..._extensionCapabilityOptions(
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
        label: 'Custom extension',
        description: 'Add a custom schema extension key/value entry.',
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
  return switch (node) {
    JsonSchemaStringNode() =>
      (featureOptions.stringMinLength && node.minLength != null) ||
          (featureOptions.stringMaxLength && node.maxLength != null) ||
          (featureOptions.stringPattern &&
              node.pattern != null &&
              node.pattern!.trim().isNotEmpty) ||
          (featureOptions.stringEnum && node.enumValues != null),
    JsonSchemaNumberNode() =>
      (featureOptions.numberMinimum && node.minimum != null) ||
          (featureOptions.numberMaximum && node.maximum != null) ||
          (featureOptions.numberExclusiveMinimum && node.exclusiveMinimum != null) ||
          (featureOptions.numberExclusiveMaximum && node.exclusiveMaximum != null) ||
          (featureOptions.numberMultipleOf && node.multipleOf != null),
    JsonSchemaBooleanNode() => node.defaultValue != null,
    JsonSchemaObjectNode() =>
      featureOptions.objectAdditionalProperties && !node.additionalProperties,
    JsonSchemaArrayNode() =>
      (featureOptions.arrayMinItems && node.minItems != null) ||
          (featureOptions.arrayMaxItems && node.maxItems != null) ||
          (featureOptions.arrayUniqueItems && node.uniqueItems != null),
  };
}

List<_CapabilityOption> _extensionCapabilityOptions({
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
        label: key,
        description: field.normalizedDescription ?? 'Configured schema extension.',
        onSelected: (context) async {
          controller.setNodeField(path: path, key: key, value: _initialValueForField(field));
        },
      ),
    );
  }
  return options;
}

List<_CapabilityOption> _nodeCapabilityOptions({
  required JsonSchemaNode node,
  required JsonSchemaPath path,
  required JsonSchemaEditorController controller,
  required JsonSchemaEditorFeatureOptions featureOptions,
}) {
  return switch (node) {
    JsonSchemaStringNode() => [
      if (featureOptions.stringMinLength && node.minLength == null)
        _CapabilityOption(
          icon: Icons.straighten_rounded,
          label: 'Min length',
          description: _jsonSchemaHelpByKeyword['minLength']!,
          onSelected: (context) async => controller.updateNode(
            path: path,
            updater: (JsonSchemaStringNode node) => node.copyWith(minLength: 0),
          ),
        ),
      if (featureOptions.stringMaxLength && node.maxLength == null)
        _CapabilityOption(
          icon: Icons.width_normal_rounded,
          label: 'Max length',
          description: _jsonSchemaHelpByKeyword['maxLength']!,
          onSelected: (context) async => controller.updateNode(
            path: path,
            updater: (JsonSchemaStringNode node) => node.copyWith(maxLength: node.minLength ?? 1),
          ),
        ),
      if (featureOptions.stringPattern && (node.pattern == null || node.pattern!.trim().isEmpty))
        _CapabilityOption(
          icon: Icons.pattern_rounded,
          label: 'Pattern',
          description: _jsonSchemaHelpByKeyword['pattern']!,
          onSelected: (context) async => controller.updateNode(
            path: path,
            updater: (JsonSchemaStringNode node) => node.copyWith(pattern: '.*'),
          ),
        ),
      if (featureOptions.stringEnum && node.enumValues == null)
        _CapabilityOption(
          icon: Icons.list_alt_rounded,
          label: 'Enum',
          description: _jsonSchemaHelpByKeyword['enum']!,
          onSelected: (context) async => controller.updateNode(
            path: path,
            updater: (JsonSchemaStringNode node) => node.copyWith(enumValues: const ['value']),
          ),
        ),
    ],
    JsonSchemaNumberNode() => [
      if (featureOptions.numberMinimum && node.minimum == null)
        _CapabilityOption(
          icon: Icons.exposure_neg_1_rounded,
          label: 'Minimum',
          description: _jsonSchemaHelpByKeyword['minimum']!,
          onSelected: (context) async => controller.updateNode(
            path: path,
            updater: (JsonSchemaNumberNode node) => node.copyWith(minimum: 0),
          ),
        ),
      if (featureOptions.numberMaximum && node.maximum == null)
        _CapabilityOption(
          icon: Icons.exposure_plus_1_rounded,
          label: 'Maximum',
          description: _jsonSchemaHelpByKeyword['maximum']!,
          onSelected: (context) async => controller.updateNode(
            path: path,
            updater: (JsonSchemaNumberNode node) => node.copyWith(maximum: node.minimum ?? 1),
          ),
        ),
      if (featureOptions.numberExclusiveMinimum && node.exclusiveMinimum == null)
        _CapabilityOption(
          icon: Icons.chevron_left_rounded,
          label: 'Exclusive min',
          description: _jsonSchemaHelpByKeyword['exclusiveMinimum']!,
          onSelected: (context) async => controller.updateNode(
            path: path,
            updater: (JsonSchemaNumberNode node) => node.copyWith(exclusiveMinimum: false),
          ),
        ),
      if (featureOptions.numberExclusiveMaximum && node.exclusiveMaximum == null)
        _CapabilityOption(
          icon: Icons.chevron_right_rounded,
          label: 'Exclusive max',
          description: _jsonSchemaHelpByKeyword['exclusiveMaximum']!,
          onSelected: (context) async => controller.updateNode(
            path: path,
            updater: (JsonSchemaNumberNode node) => node.copyWith(exclusiveMaximum: false),
          ),
        ),
      if (featureOptions.numberMultipleOf && node.multipleOf == null)
        _CapabilityOption(
          icon: Icons.percent_rounded,
          label: 'Multiple of',
          description: _jsonSchemaHelpByKeyword['multipleOf']!,
          onSelected: (context) async => controller.updateNode(
            path: path,
            updater: (JsonSchemaNumberNode node) => node.copyWith(multipleOf: 1),
          ),
        ),
    ],
    JsonSchemaBooleanNode() => [
      if (node.defaultValue == null)
        _CapabilityOption(
          icon: Icons.toggle_on_rounded,
          label: 'Default',
          description: _jsonSchemaHelpByKeyword['default']!,
          onSelected: (context) async => controller.updateNode(
            path: path,
            updater: (JsonSchemaBooleanNode node) => node.copyWith(defaultValue: false),
          ),
        ),
    ],
    JsonSchemaObjectNode() => [
      if (featureOptions.objectAdditionalProperties && node.additionalProperties)
        _CapabilityOption(
          icon: Icons.data_object_rounded,
          label: 'Additional properties',
          description: _jsonSchemaHelpByKeyword['additionalProperties']!,
          onSelected: (context) async => controller.updateNode(
            path: path,
            updater: (JsonSchemaObjectNode node) => node.copyWith(additionalProperties: false),
          ),
        ),
    ],
    JsonSchemaArrayNode() => [
      if (featureOptions.arrayMinItems && node.minItems == null)
        _CapabilityOption(
          icon: Icons.format_list_numbered_rounded,
          label: 'Min items',
          description: _jsonSchemaHelpByKeyword['minItems']!,
          onSelected: (context) async => controller.updateNode(
            path: path,
            updater: (JsonSchemaArrayNode node) => node.copyWith(minItems: 0),
          ),
        ),
      if (featureOptions.arrayMaxItems && node.maxItems == null)
        _CapabilityOption(
          icon: Icons.format_list_numbered_rtl_rounded,
          label: 'Max items',
          description: _jsonSchemaHelpByKeyword['maxItems']!,
          onSelected: (context) async => controller.updateNode(
            path: path,
            updater: (JsonSchemaArrayNode node) => node.copyWith(maxItems: node.minItems ?? 1),
          ),
        ),
      if (featureOptions.arrayUniqueItems && node.uniqueItems == null)
        _CapabilityOption(
          icon: Icons.fingerprint_rounded,
          label: 'Unique items',
          description: _jsonSchemaHelpByKeyword['uniqueItems']!,
          onSelected: (context) async => controller.updateNode(
            path: path,
            updater: (JsonSchemaArrayNode node) => node.copyWith(uniqueItems: false),
          ),
        ),
    ],
  };
}
