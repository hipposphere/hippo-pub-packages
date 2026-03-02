import 'package:flutter/material.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:hippo_utils/hippo_utils.dart';
import 'package:hippo_components/src/complex/json_schema_editor/widgets/json_schema_validation_panel.dart';
import 'package:hippo_components/src/complex/json_schema_editor/widgets/json_schema_visualization_panel.dart';

class JsonSchemaEditorPage extends StatelessWidget {
  final String title;
  final JsonSchemaEditorController controller;
  const JsonSchemaEditorPage({super.key, required this.title, required this.controller});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isDesktop = width >= 1024;

        if (isDesktop) {
          return PageContainer(
            title: title,
            actions: [
              PageHeaderTextAction(icon: Icon(Icons.save_outlined), label: context.cl.actions_save),
            ],
            body: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 2, child: JsonSchemaEditor(controller: controller)),
                const VerticalDivider(),
                Expanded(
                  child: SingleChildScrollView(
                    child: _PreviewAndDiagnostics(controller: controller),
                  ),
                ),
              ],
            ),
          );
        }

        return TabbedPageContainer(
          title: title,
          actions: [
            PageHeaderTextAction(icon: Icon(Icons.save_outlined), label: context.cl.actions_save),
          ],
          tabs: const [
            Tab(text: 'Editor'),
            Tab(text: 'Vorschau'),
          ],
          tabViews: [
            JsonSchemaEditor(controller: controller),
            _PreviewAndDiagnostics(controller: controller),
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
    return DataSubjectBuilder<JsonSchema>(
      subject: controller.jsonSchemaSubject,
      builder: (context, schema) {
        return DataSubjectBuilder<List<JsonSchemaDiagnostic>>(
          subject: controller.diagnosticsSubject,
          builder: (context, diagnostics) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  JsonSchemaVisualizationPanel(controller: controller, schema: schema),
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
