import 'package:flutter/material.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:hippo_components/src/complex/json_schema_editor/widgets/json_schema_validation_panel.dart';
import 'package:hippo_components/src/complex/json_schema_visualization/json_schema_visualization_panel.dart';
import 'package:hippo_utils/hippo_utils.dart';

class JsonSchemaEditorPage extends StatelessWidget {
  final String title;
  final JsonSchemaEditorController controller;
  final Future<bool> Function(BuildContext context, JsonSchema schema) onSave;
  const JsonSchemaEditorPage({
    super.key,
    required this.title,
    required this.controller,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isDesktop = width >= 1024;
        final previewContent = SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: _PreviewAndDiagnostics(controller: controller),
        );

        if (isDesktop) {
          return PageContainer(
            title: title,
            actions: [
              PageHeaderTextAction(
                onTap: () {
                  onSave(context, controller.toJsonSchema());
                },
                icon: const Icon(Icons.save_outlined),
                label: context.cl.actions_save,
              ),
            ],
            body: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 2, child: JsonSchemaEditor(controller: controller)),
                const VerticalDivider(thickness: 0.5, width: 0.5),
                Expanded(child: previewContent),
              ],
            ),
          );
        }

        return TabbedPageContainer(
          title: title,
          actions: [
            PageHeaderTextAction(
              onTap: () {
                onSave(context, controller.toJsonSchema());
              },
              icon: const Icon(Icons.save_outlined),
              label: context.cl.actions_save,
            ),
          ],
          tabs: const [
            Tab(text: 'Editor'),
            Tab(text: 'Vorschau'),
          ],
          tabViews: [
            JsonSchemaEditor(controller: controller),
            previewContent,
          ],
        );
      },
    );
  }
}

class _PreviewAndDiagnostics extends StatelessWidget {
  const _PreviewAndDiagnostics({required this.controller});

  final JsonSchemaEditorController controller;

  @override
  Widget build(BuildContext context) {
    return DataSubjectBuilder<JsonSchemaNode>(
      subject: controller.schemaSubject,
      builder: (context, schemaNode) {
        return DataSubjectBuilder<List<JsonSchemaDiagnostic>>(
          subject: controller.diagnosticsSubject,
          builder: (context, diagnostics) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  JsonSchemaVisualizationPanel(
                    controller: controller,
                    schema: JsonSchema.fromNode(schemaNode),
                  ),
                  const SizedBox(height: 16),
                  JsonSchemaValidationPanel(diagnostics: diagnostics),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
