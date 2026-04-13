import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:hippo_utils/hippo_utils.dart';

Widget _buildTestApp(Widget child, {Locale locale = const Locale('en')}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: ComponentsLocalizations.localizationsDelegates,
    supportedLocales: ComponentsLocalizations.supportedLocales,
    theme: ThemeData(splashFactory: NoSplash.splashFactory),
    home: Scaffold(body: child),
  );
}

Finder _findOptionalTooltip(String message) {
  return find.byWidgetPredicate((widget) => widget is OptionalTooltip && widget.message == message);
}

void main() {
  testWidgets('hides visualization details by default and reveals them via the toggle', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1400, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final schema = JsonSchema.fromNode(
      const JsonSchemaObjectNode(
        title: 'Account schema',
        required: {'name'},
        extensions: {'x-group': 'public'},
        properties: {
          'name': JsonSchemaStringNode(
            title: 'Display name',
            minLength: 1,
            enumValues: ['Alice', 'Bob'],
            extensions: {'x-token': 'admin'},
          ),
          'flags': JsonSchemaArrayNode(
            title: 'Flags',
            uniqueItems: true,
            extensions: {'x-priority': 2},
            items: JsonSchemaBooleanNode(
              title: 'Flag item',
              defaultValue: true,
              extensions: {'x-enabled': false},
            ),
          ),
        },
      ),
    );

    final extensionOptions = JsonSchemaEditorExtensionOptions(
      configurableExtensions: [
        JsonSchemaEditorExtensionField(
          key: 'x-group',
          label: translateLazy(en: 'Group', de: 'Gruppe', zh: '分组'),
          description: translateLazy(
            en: 'Grouping metadata',
            de: 'Gruppierungsmetadaten',
            zh: '分组元数据',
          ),
          applicableNodeTypes: {JsonSchemaNodeType.object},
          applicableScopes: {JsonSchemaEditorExtensionFieldScope.root},
        ),
        JsonSchemaEditorExtensionField(
          key: 'x-priority',
          label: (_) => 'Priority',
          description: (_) => 'Priority ordering',
          valueType: JsonSchemaEditorExtensionFieldType.number,
          applicableNodeTypes: {JsonSchemaNodeType.array},
          applicableScopes: {JsonSchemaEditorExtensionFieldScope.objectProperty},
        ),
        JsonSchemaEditorExtensionField(
          key: 'x-enabled',
          label: (_) => 'Enabled marker',
          description: (_) => 'Boolean feature marker',
          valueType: JsonSchemaEditorExtensionFieldType.boolean,
          applicableNodeTypes: {JsonSchemaNodeType.boolean},
          applicableScopes: {JsonSchemaEditorExtensionFieldScope.arrayItem},
        ),
        JsonSchemaEditorExtensionField(
          key: 'x-token',
          label: (_) => 'Token',
          description: (_) => 'Authorization token',
          valueType: JsonSchemaEditorExtensionFieldType.stringEnum,
          enumValues: [
            JsonSchemaEditorExtensionEnumValue(
              value: 'admin',
              label: (_) => 'Administrator',
              description: (_) => 'Administrative token',
            ),
          ],
          applicableScopes: {JsonSchemaEditorExtensionFieldScope.objectProperty},
        ),
      ],
    );

    await tester.pumpWidget(
      _buildTestApp(JsonSchemaVisualization(schema: schema, extensionOptions: extensionOptions)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Account schema'), findsOneWidget);
    expect(find.text('Display name'), findsOneWidget);
    expect(find.text('Flags'), findsOneWidget);
    expect(find.text('Flag item'), findsOneWidget);
    expect(find.text('Enum Values'), findsOneWidget);
    expect(find.byKey(const ValueKey('section-count-Enum Values')), findsOneWidget);
    expect(find.text('Enum count'), findsNothing);
    expect(find.byIcon(Icons.account_tree_rounded), findsNothing);
    expect(find.text('Authorization token'), findsNothing);
    expect(find.text('Grouping metadata'), findsNothing);
    expect(find.text('Priority ordering'), findsNothing);
    expect(find.text('Boolean feature marker'), findsNothing);
    expect(find.text('configured'), findsNothing);
    expect(find.textContaining('Group: public', findRichText: true), findsOneWidget);
    expect(find.textContaining('Token: Administrator', findRichText: true), findsOneWidget);
    expect(find.textContaining('Token: admin', findRichText: true), findsNothing);
    expect(find.textContaining('Priority: 2', findRichText: true), findsOneWidget);
    expect(find.textContaining('Enabled marker: false', findRichText: true), findsOneWidget);
    expect(_findOptionalTooltip('Authorization token\n\nAdministrative token'), findsOneWidget);
    expect(_findOptionalTooltip('Grouping metadata'), findsOneWidget);
    expect(_findOptionalTooltip('Priority ordering'), findsOneWidget);
    expect(_findOptionalTooltip('Boolean feature marker'), findsOneWidget);
    expect(find.textContaining('Properties:', findRichText: true), findsNothing);
    expect(find.textContaining('Required:', findRichText: true), findsNothing);
    expect(find.textContaining('Additional props:', findRichText: true), findsNothing);
    expect(_findOptionalTooltip('2 properties'), findsNothing);
    expect(_findOptionalTooltip('1 required properties'), findsNothing);
    expect(_findOptionalTooltip('Additional properties allowed'), findsNothing);
    expect(find.text('/flags/-'), findsNothing);
    expect(find.byType(Scrollable), findsNothing);

    expect(_findOptionalTooltip('Show details'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.visibility_off_outlined));
    await tester.pumpAndSettle();

    expect(_findOptionalTooltip('2 properties'), findsOneWidget);
    expect(_findOptionalTooltip('1 required properties'), findsOneWidget);
    expect(_findOptionalTooltip('Additional properties allowed'), findsOneWidget);
    expect(find.text('/flags/-'), findsOneWidget);
  });

  testWidgets('copies the displayed JSON Pointer when the path chip is tapped', (
    WidgetTester tester,
  ) async {
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    MethodCall? clipboardMethodCall;
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        clipboardMethodCall = call;
      }
      return null;
    });
    addTearDown(() {
      messenger.setMockMethodCallHandler(SystemChannels.platform, null);
    });

    final schema = JsonSchema.fromNode(
      const JsonSchemaObjectNode(
        properties: {'flags': JsonSchemaArrayNode(items: JsonSchemaBooleanNode())},
      ),
    );

    await tester.pumpWidget(_buildTestApp(JsonSchemaVisualization(schema: schema)));
    await tester.pumpAndSettle();

    expect(_findOptionalTooltip('Show details'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.visibility_off_outlined));
    await tester.pumpAndSettle();

    await tester.tap(find.text('/flags/-'));
    await tester.pumpAndSettle();

    expect(clipboardMethodCall?.method, 'Clipboard.setData');
    expect((clipboardMethodCall?.arguments as Map<Object?, Object?>?)?['text'], '/flags/-');
  });

  testWidgets('renders object properties in configured order and hides internal order metadata', (
    WidgetTester tester,
  ) async {
    final schema = JsonSchema({
      'type': 'object',
      'properties': {
        'first': {'type': 'string', 'title': 'First'},
        'second': {'type': 'string', 'title': 'Second'},
        'third': {'type': 'string', 'title': 'Third'},
      },
      jsonSchemaObjectPropertyOrderExtensionKey: ['third', 'first', 'second'],
    });

    await tester.pumpWidget(_buildTestApp(JsonSchemaVisualization(schema: schema)));
    await tester.pumpAndSettle();

    final thirdY = tester.getTopLeft(find.text('Third')).dy;
    final firstY = tester.getTopLeft(find.text('First')).dy;
    final secondY = tester.getTopLeft(find.text('Second')).dy;

    expect(thirdY, lessThan(firstY));
    expect(firstY, lessThan(secondY));
    expect(find.text(jsonSchemaObjectPropertyOrderExtensionKey), findsNothing);
  });
}
