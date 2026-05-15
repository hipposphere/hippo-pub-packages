import 'package:flutter/material.dart';
import 'package:hippo_core_flutter/hippo_core_flutter.dart' show Gap;

import '../../base/utils/components_context.dart';
import '../../container/page_container/page_container.dart';
import '../../container/page_container/widgets/page_header.dart';
import 'controller.dart';
import 'widgets/json_schema_validation_panel.dart';

class JsonSchemaEditorImportPage extends StatefulWidget {
  const JsonSchemaEditorImportPage({
    super.key,
    required this.controller,
    this.title,
    this.initialJson,
  });

  final JsonSchemaEditorController controller;
  final String? title;
  final String? initialJson;

  @override
  State<JsonSchemaEditorImportPage> createState() => _JsonSchemaEditorImportPageState();
}

class _JsonSchemaEditorImportPageState extends State<JsonSchemaEditorImportPage> {
  late final TextEditingController _jsonController;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _jsonController = TextEditingController(text: widget.initialJson ?? '');
  }

  @override
  void dispose() {
    _jsonController.dispose();
    super.dispose();
  }

  void _clearErrorOnChange(String value) {
    if (_errorText == null) {
      return;
    }
    setState(() {
      _errorText = null;
    });
  }

  void _importSchema() {
    try {
      widget.controller.importJsonString(_jsonController.text);
      Navigator.of(context).pop();
    } on FormatException catch (error) {
      setState(() {
        _errorText = error.message.trim().isEmpty
            ? context.lazyTranslate(
                en: 'JSON schema could not be parsed.',
                de: 'Das JSON-Schema konnte nicht gelesen werden.',
                zh: '无法解析 JSON Schema。',
              )
            : error.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PageContainer(
      title:
          widget.title ??
          context.lazyTranslate(
            en: 'Import JSON Schema',
            de: 'JSON-Schema importieren',
            zh: '导入 JSON Schema',
          ),
      actions: [
        PageHeaderTextAction(
          key: const ValueKey('json-schema-import-action'),
          onTap: _importSchema,
          icon: const Icon(Icons.file_upload_outlined),
          label: context.cl.actions_import,
        ),
      ],
      body: Padding(
        key: const ValueKey('json-schema-import-page'),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_errorText != null) ...[JsonSchemaWarningBadge(message: _errorText!), const Gap(8)],
            Expanded(
              child: TextField(
                key: const ValueKey('json-schema-import-json-field'),
                controller: _jsonController,
                autofocus: true,
                expands: true,
                minLines: null,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textAlignVertical: TextAlignVertical.top,
                style: theme.textTheme.bodyMedium?.copyWith(fontFamily: 'monospace', height: 1.35),
                decoration: InputDecoration(
                  labelText: context.lazyTranslate(
                    en: 'JSON schema',
                    de: 'JSON-Schema',
                    zh: 'JSON Schema',
                  ),
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: colorScheme.surfaceContainerLowest,
                  contentPadding: const EdgeInsets.all(14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.7),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.7),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.primary, width: 1.2),
                  ),
                ),
                onChanged: _clearErrorOnChange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
