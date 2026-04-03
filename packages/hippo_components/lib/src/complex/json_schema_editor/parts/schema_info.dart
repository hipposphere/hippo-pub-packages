part of '../editor.dart';

class _SchemaInfoFields extends StatelessWidget {
  const _SchemaInfoFields({required this.controller, required this.node, required this.path});

  final JsonSchemaEditorController controller;
  final JsonSchemaNode node;
  final JsonSchemaPath path;

  @override
  Widget build(BuildContext context) {
    return _EditorFieldWrap(
      children: [
        JsonSchemaEditorTextField(
          value: node.title,
          hint: 'Title',
          helpText: _jsonSchemaHelpByKeyword['title'],
          onChanged: (value) => controller.updateNode(
            path: path,
            updater: (JsonSchemaNode current) => current.copyWith(title: value.trim()),
          ),
          onCleared: () => controller.updateNode(
            path: path,
            updater: (JsonSchemaNode current) => current.copyWith(title: null),
          ),
        ),
        JsonSchemaEditorTextField(
          value: node.description,
          hint: 'Description',
          maxLines: 3,
          helpText: _jsonSchemaHelpByKeyword['description'],
          onChanged: (value) => controller.updateNode(
            path: path,
            updater: (JsonSchemaNode current) => current.copyWith(description: value),
          ),
          onCleared: () => controller.updateNode(
            path: path,
            updater: (JsonSchemaNode current) => current.copyWith(description: null),
          ),
        ),
      ],
    );
  }
}
