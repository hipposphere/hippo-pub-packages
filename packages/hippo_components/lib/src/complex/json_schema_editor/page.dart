import 'package:flutter/material.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:hippo_components/src/complex/json_schema_editor/widgets/json_schema_validation_panel.dart';
import 'package:hippo_components/src/complex/json_schema_visualization/json_schema_visualization_panel.dart';
import 'package:hippo_core_flutter/hippo_core_flutter.dart';
import 'package:hippo_utils/hippo_utils.dart';

class JsonSchemaEditorPage extends StatelessWidget {
  final String title;
  final JsonSchemaEditorController controller;
  final Future<bool> Function(BuildContext context, JsonSchema schema) onSave;
  final String? explanationDescription;

  const JsonSchemaEditorPage({
    super.key,
    required this.title,
    required this.controller,
    required this.onSave,
    this.explanationDescription,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isDesktop = width >= 1000;

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
                Expanded(
                  flex: 2,
                  child: JsonSchemaEditor(
                    controller: controller,
                    guideDescription: explanationDescription,
                  ),
                ),
                const VerticalDivider(thickness: 0.5, width: 0.5),
                Expanded(child: _PreviewAndDiagnostics(controller: controller)),
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
          tabs: [
            Tab(
              text: context.lazyTranslate(en: 'Editor', de: 'Editor', zh: '编辑器'),
            ),
            Tab(
              text: context.lazyTranslate(en: 'Preview', de: 'Vorschau', zh: '预览'),
            ),
          ],
          tabViews: [
            JsonSchemaEditor(controller: controller, guideDescription: explanationDescription),
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
    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: DataSubjectBuilder<JsonSchemaNode>(
        subject: controller.schemaSubject,
        builder: (context, schemaNode) {
          return DataSubjectBuilder<List<JsonSchemaDiagnostic>>(
            subject: controller.diagnosticsSubject,
            builder: (context, diagnostics) {
              return Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    JsonSchemaValidationPanel(diagnostics: diagnostics),
                    const Gap(16),
                    JsonSchemaVisualizationPanel(
                      controller: controller,
                      schema: JsonSchema.fromNode(schemaNode),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
