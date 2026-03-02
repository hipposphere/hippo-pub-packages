import 'package:flutter/material.dart';
import 'package:hippo_components/hippo_components.dart';

class JsonSchemaEditorExample extends StatelessWidget {
  const JsonSchemaEditorExample({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = JsonSchemaEditorController();
    return PageContainer(
      title: 'JSON Schema Editor',
      body: JsonSchemaEditor(controller: controller),
    );
  }
}
