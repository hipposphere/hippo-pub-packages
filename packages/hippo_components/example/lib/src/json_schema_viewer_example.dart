import 'package:flutter/material.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:hippo_utils/hippo_utils.dart';
import 'package:json_schema/json_schema.dart';

class JsonSchemaViewerExamplePage extends StatefulWidget {
  const JsonSchemaViewerExamplePage({super.key});

  @override
  State<JsonSchemaViewerExamplePage> createState() => _JsonSchemaViewerExamplePageState();
}

class _JsonSchemaViewerExamplePageState extends State<JsonSchemaViewerExamplePage> {
  static final _extensionOptions = JsonSchemaEditorExtensionOptions(
    configurableExtensions: [
      JsonSchemaEditorExtensionField(
        key: 'x-source',
        description: translateLazy(
          en: 'Where this field originates in the upstream system.',
          de: 'Woher dieses Feld im Quellsystem stammt.',
          zh: '该字段在上游系统中的来源。',
        ),
      ),
      JsonSchemaEditorExtensionField(
        key: 'x-ui-hint',
        label: translateLazy(en: 'UI hint', de: 'UI-Hinweis', zh: '界面提示'),
        description: translateLazy(
          en: 'Preferred rendering hint for consuming clients.',
          de: 'Bevorzugter Darstellungs-Hinweis für konsumierende Clients.',
          zh: '供消费端使用的首选渲染提示。',
        ),
      ),
      JsonSchemaEditorExtensionField(
        key: 'x-section',
        description: (_) => 'Logical UI or domain section for grouped fields.',
        label: translateLazy(en: 'Section', de: 'Bereich', zh: '分区'),
        applicableNodeTypes: {JsonSchemaNodeType.object},
      ),
      JsonSchemaEditorExtensionField(
        key: 'x-ordering',
        description: (_) => 'Ordering or uniqueness rule expected by the consumer.',
        applicableNodeTypes: {JsonSchemaNodeType.array},
      ),
      JsonSchemaEditorExtensionField(
        key: 'x-flag',
        description: (_) => 'Feature flag or rollout marker tied to the field.',
        applicableNodeTypes: {JsonSchemaNodeType.boolean},
      ),
      JsonSchemaEditorExtensionField(
        key: 'x-unit',
        description: (_) => 'Display unit for numeric values in the UI.',
        applicableNodeTypes: {JsonSchemaNodeType.integer, JsonSchemaNodeType.number},
      ),
    ],
  );

  static final _samples = <_SchemaSample>[
    _SchemaSample(
      title: 'User Profile Payload',
      description:
          'A typical account settings schema with nested objects, required fields, extensions, and array items.',
      schema: jsonSchemaFromNode(
        const JsonSchemaObjectNode(
          title: 'User profile payload',
          description: 'Schema used by an account settings surface.',
          extensions: {'x-section': 'account'},
          properties: {
            'displayName': JsonSchemaStringNode(
              title: 'Display name',
              description: 'Visible name shown throughout the product.',
              minLength: 1,
              maxLength: 40,
              extensions: {'x-source': 'profile_service', 'x-ui-hint': 'text-input'},
            ),
            'role': JsonSchemaStringNode(
              title: 'Role',
              description: 'Access level assigned to the account.',
              enumValues: ['owner', 'admin', 'member', 'viewer'],
              extensions: {'x-ui-hint': 'segmented-control'},
            ),
            'emailNotifications': JsonSchemaBooleanNode(
              title: 'Email notifications',
              description: 'Whether digest emails are enabled for the user.',
              defaultValue: true,
              extensions: {'x-flag': 'notifications_v2'},
            ),
            'quotas': JsonSchemaObjectNode(
              title: 'Quota settings',
              description: 'Numeric limits derived from the current billing plan.',
              extensions: {'x-section': 'limits'},
              properties: {
                'projects': JsonSchemaNumberNode.integer(
                  title: 'Projects',
                  minimum: 1,
                  maximum: 50,
                  extensions: {'x-unit': 'projects', 'x-source': 'billing_service'},
                ),
                'storageGb': JsonSchemaNumberNode.number(
                  title: 'Storage',
                  minimum: 5,
                  maximum: 500,
                  multipleOf: 5,
                  extensions: {'x-unit': 'GB', 'x-source': 'billing_service'},
                ),
              },
              required: {'projects', 'storageGb'},
              additionalProperties: false,
            ),
            'connectedWorkspaces': JsonSchemaArrayNode(
              title: 'Connected workspaces',
              description: 'External workspaces linked to this account.',
              minItems: 0,
              uniqueItems: true,
              extensions: {'x-ordering': 'stable-unique', 'x-ui-hint': 'table'},
              items: JsonSchemaObjectNode(
                title: 'Workspace',
                properties: {
                  'id': JsonSchemaStringNode(
                    title: 'Workspace id',
                    minLength: 1,
                    extensions: {'x-source': 'workspace_service'},
                  ),
                  'name': JsonSchemaStringNode(title: 'Workspace name', minLength: 1),
                  'isDefault': JsonSchemaBooleanNode(
                    title: 'Default workspace',
                    defaultValue: false,
                    extensions: {'x-flag': 'workspace_defaulting'},
                  ),
                },
                required: {'id', 'name'},
                additionalProperties: false,
              ),
            ),
          },
          required: {'displayName', 'role', 'quotas'},
          additionalProperties: false,
        ),
      ),
    ),
    _SchemaSample(
      title: 'Workflow Automation',
      description:
          'A more operational schema that highlights enums, numeric constraints, nested arrays, and rollout metadata.',
      schema: jsonSchemaFromNode(
        const JsonSchemaObjectNode(
          title: 'Workflow automation',
          description: 'Schema for a configurable event-driven automation.',
          extensions: {'x-section': 'automation'},
          properties: {
            'name': JsonSchemaStringNode(
              title: 'Workflow name',
              minLength: 3,
              maxLength: 64,
              extensions: {'x-ui-hint': 'headline-input'},
            ),
            'trigger': JsonSchemaObjectNode(
              title: 'Trigger',
              description: 'Defines which event starts the workflow.',
              extensions: {'x-section': 'entrypoint'},
              properties: {
                'event': JsonSchemaStringNode(
                  title: 'Event',
                  enumValues: ['ticket.created', 'ticket.updated', 'ticket.closed'],
                  extensions: {'x-source': 'event_bus', 'x-ui-hint': 'event-picker'},
                ),
                'retryCount': JsonSchemaNumberNode.integer(
                  title: 'Retry count',
                  minimum: 0,
                  maximum: 5,
                  extensions: {'x-unit': 'attempts'},
                ),
              },
              required: {'event'},
              additionalProperties: false,
            ),
            'steps': JsonSchemaArrayNode(
              title: 'Steps',
              description: 'Ordered actions executed once the trigger matches.',
              minItems: 1,
              extensions: {'x-ordering': 'execution-order', 'x-ui-hint': 'sortable-cards'},
              items: JsonSchemaObjectNode(
                title: 'Step',
                properties: {
                  'type': JsonSchemaStringNode(
                    title: 'Step type',
                    enumValues: ['assign', 'email', 'webhook'],
                    extensions: {'x-ui-hint': 'icon-select'},
                  ),
                  'timeoutMs': JsonSchemaNumberNode.integer(
                    title: 'Timeout',
                    minimum: 100,
                    maximum: 60000,
                    multipleOf: 100,
                    extensions: {'x-unit': 'ms'},
                  ),
                  'enabled': JsonSchemaBooleanNode(
                    title: 'Enabled',
                    defaultValue: true,
                    extensions: {'x-flag': 'workflow_step_toggles'},
                  ),
                  'recipients': JsonSchemaArrayNode(
                    title: 'Recipients',
                    minItems: 1,
                    uniqueItems: true,
                    extensions: {'x-ordering': 'deduplicated'},
                    items: JsonSchemaStringNode(
                      title: 'Email recipient',
                      pattern: r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                      extensions: {'x-ui-hint': 'email-chip-input'},
                    ),
                  ),
                },
                required: {'type', 'enabled'},
                additionalProperties: false,
              ),
            ),
          },
          required: {'name', 'trigger', 'steps'},
          additionalProperties: false,
        ),
      ),
    ),
  ];

  int _selectedSampleIndex = 0;

  @override
  Widget build(BuildContext context) {
    final sample = _samples[_selectedSampleIndex];

    return PlatformPageContainer(
      title: 'JSON Schema Viewer',
      onHeaderPanStart: (_) {},
      onDoubleTap: () {},
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 1100;
          final viewer = JsonSchemaVisualization(
            schema: sample.schema,
            extensionOptions: _extensionOptions,
          );
          final source = _SchemaSourceCard(schema: sample.schema);

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              _SchemaPickerCard(
                samples: _samples,
                selectedIndex: _selectedSampleIndex,
                onSelected: (index) {
                  setState(() {
                    _selectedSampleIndex = index;
                  });
                },
              ),
              const SizedBox(height: 12),
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: viewer),
                    const SizedBox(width: 12),
                    Expanded(flex: 2, child: source),
                  ],
                )
              else ...[
                viewer,
                const SizedBox(height: 12),
                source,
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SchemaPickerCard extends StatelessWidget {
  const _SchemaPickerCard({
    required this.samples,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<_SchemaSample> samples;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sample = samples[selectedIndex];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Viewer Example',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Switch between realistic schemas to inspect structure and metadata density.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (var index = 0; index < samples.length; index++)
                  ChoiceChip(
                    label: Text(samples[index].title),
                    selected: index == selectedIndex,
                    onSelected: (selected) {
                      if (selected) {
                        onSelected(index);
                      }
                    },
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              sample.description,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _SchemaSourceCard extends StatelessWidget {
  const _SchemaSourceCard({required this.schema});

  final JsonSchema schema;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Raw JSON',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'The same schema serialized as JSON for quick inspection and copy/paste.',
              style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 420),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.6)),
              ),
              child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  child: SelectableText(
                    schema.toJsonString(pretty: true),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      height: 1.4,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SchemaSample {
  const _SchemaSample({required this.title, required this.description, required this.schema});

  final String title;
  final String description;
  final JsonSchema schema;
}
