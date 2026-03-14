import 'package:flutter_test/flutter_test.dart';
import 'package:hippo_utils/hippo_utils.dart';

void main() {
  group('JsonAnnotator', () {
    test('parses JSON with Schema and applies metadata via JsonPointerMap', () {
      // 1. Setup the Map of metadata mapping paths to custom data
      final map = JsonPointerMap<String>();
      map.setString('/name', 'Name Field Metadata');
      map.setString('/tags/-', 'Tag Item Metadata');
      map.setString('/profile/age', 'Age Metadata');

      // 2. Setup a simplistic JsonSchema
      final schema = JsonSchema.fromNode(
        const JsonSchemaObjectNode(
          properties: {
            'name': JsonSchemaStringNode(),
            'tags': JsonSchemaArrayNode(items: JsonSchemaStringNode()),
            'profile': JsonSchemaObjectNode(
              properties: {
                'age': JsonSchemaNumberNode.integer(),
              },
            ),
          },
        ),
      );

      // 3. The raw JSON data
      final rawJson = {
        'name': 'John Doe',
        'tags': ['developer', 'dart'],
        'profile': {
          'age': 30,
        },
      };

      // 4. Parse
      const annotator = JsonAnnotator();
      final rootNode = annotator.parse<String>(rawJson, schema: schema, map: map);

      // 5. Assertions
      expect(rootNode.schemaNode, isA<JsonSchemaObjectNode>());
      expect(rootNode.type, AnnotatedJsonNodeType.object);
      expect(rootNode.pointer.isRoot, true);
      expect(rootNode.metadata, isNull);

      // Name Property
      final nameNode = rootNode.properties!['name']!;
      expect(nameNode.value, 'John Doe');
      expect(nameNode.type, AnnotatedJsonNodeType.value);
      expect(nameNode.schemaNode, isA<JsonSchemaStringNode>());
      expect(nameNode.pointer.toString(), '/name');
      expect(nameNode.metadata, 'Name Field Metadata');

      // Profile -> Age Property
      final profileNode = rootNode.properties!['profile']!;
      expect(profileNode.schemaNode, isA<JsonSchemaObjectNode>());
      final ageNode = profileNode.properties!['age']!;
      expect(ageNode.value, 30);
      expect(ageNode.schemaNode, isA<JsonSchemaNumberNode>());
      expect(ageNode.pointer.toString(), '/profile/age');
      expect(ageNode.metadata, 'Age Metadata');

      // Tags Array
      final tagsNode = rootNode.properties!['tags']!;
      expect(tagsNode.schemaNode, isA<JsonSchemaArrayNode>());
      expect(tagsNode.type, AnnotatedJsonNodeType.list);
      expect(tagsNode.children!.length, 2);

      // First Tag
      final tag0Node = tagsNode.children![0];
      expect(tag0Node.value, 'developer');
      expect(tag0Node.schemaNode, isA<JsonSchemaStringNode>());
      expect(tag0Node.pointer.toString(), '/tags/0');
      expect(tag0Node.metadata, 'Tag Item Metadata'); // Matched via /tags/-

      // Second Tag
      final tag1Node = tagsNode.children![1];
      expect(tag1Node.value, 'dart');
      expect(tag1Node.pointer.toString(), '/tags/1');
      expect(tag1Node.metadata, 'Tag Item Metadata');
    });

    test('handles fallback to null schema nodes for missing schemas', () {
      final map = JsonPointerMap<String>();
      // We only define 'known' in the schema, but provide 'unknown' in json
      final schema = JsonSchema.fromNode(
        const JsonSchemaObjectNode(
          properties: {
            'known': JsonSchemaStringNode(),
          },
        ),
      );

      final rawJson = {
        'known': 'value',
        'unknown': 'mystery',
      };

      const annotator = JsonAnnotator();
      final node = annotator.parse<String>(rawJson, schema: schema, map: map);

      expect(node.properties!['known']!.schemaNode, isA<JsonSchemaStringNode>());
      // Missing property falls back to emptyRoot() => JsonSchemaObjectNode because parent is ObjectNode
      expect(node.properties!['unknown']!.schemaNode, isA<JsonSchemaObjectNode>());
      expect(node.properties!['unknown']!.value, 'mystery');
    });

    test('works without schema or map', () {
      final rawJson = {
        'simple': 'data',
        'list': [1, 2, 3]
      };

      const annotator = JsonAnnotator();
      final node = annotator.parse<String>(rawJson); // No schema, no map

      expect(node.schemaNode, isNull);
      expect(node.metadata, isNull);
      
      final simpleNode = node.properties!['simple']!;
      expect(simpleNode.value, 'data');
      expect(simpleNode.schemaNode, isNull);
      expect(simpleNode.pointer.toString(), '/simple');

      final listNode = node.properties!['list']!;
      expect(listNode.type, AnnotatedJsonNodeType.list);
      expect(listNode.children!.length, 3);
      expect(listNode.children![0].value, 1);
      expect(listNode.children![0].schemaNode, isNull);
    });
  });
}
