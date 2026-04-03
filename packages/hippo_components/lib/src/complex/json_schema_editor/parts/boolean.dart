part of '../editor.dart';

class _BooleanExtensionNodeField extends StatelessWidget {
  const _BooleanExtensionNodeField({
    required this.controller,
    required this.path,
    required this.extensionKey,
    required this.extensionValue,
    this.helpText,
  });

  final JsonSchemaEditorController controller;
  final JsonSchemaPath path;
  final String extensionKey;
  final bool extensionValue;
  final String? helpText;

  @override
  Widget build(BuildContext context) {
    return _BooleanCapabilityField(
      label: extensionKey,
      value: extensionValue,
      helpText: helpText,
      onChanged: (value) {
        controller.setNodeField(path: path, key: extensionKey, value: value);
      },
      onCleared: () => controller.removeNodeField(path: path, key: extensionKey),
    );
  }
}

class _BooleanCapabilityField extends StatelessWidget {
  const _BooleanCapabilityField({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.onCleared,
    this.helpText,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final VoidCallback onCleared;
  final String? helpText;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CompactBooleanOption(label: label, value: value, helpText: helpText, onChanged: onChanged),
        const Spacer(),
        _EditorActionIconButton(
          tooltip: 'Remove capability',
          icon: Icons.close,
          onPressed: onCleared,
        ),
      ],
    );
  }
}

class _BooleanNodeEditor extends StatelessWidget {
  const _BooleanNodeEditor({
    required this.controller,
    required this.node,
    required this.path,
    required this.diagnostics,
    required this.compactMode,
    this.showCapabilities = true,
    this.showStructure = true,
  });

  final JsonSchemaEditorController controller;
  final JsonSchemaBooleanNode node;
  final JsonSchemaPath path;
  final List<JsonSchemaDiagnostic> diagnostics;
  final bool compactMode;
  final bool showCapabilities;
  final bool showStructure;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showCapabilities && node.defaultValue != null)
          _BooleanCapabilityField(
            label: 'Default true',
            value: node.defaultValue!,
            helpText: _jsonSchemaHelpByKeyword['default'],
            onChanged: (value) => controller.updateNode(
              path: path,
              updater: (JsonSchemaBooleanNode node) => node.copyWith(defaultValue: value),
            ),
            onCleared: () => controller.updateNode(
              path: path,
              updater: (JsonSchemaBooleanNode node) => node.copyWith(clearDefaultValue: true),
            ),
          ),
        if (showStructure) const SizedBox.shrink(),
      ],
    );
  }
}
