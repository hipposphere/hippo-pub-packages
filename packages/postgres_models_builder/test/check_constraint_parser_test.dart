import 'package:postgres_models_builder/src/postgres_reader/check_constraint_parser.dart';
import 'package:test/test.dart';

void main() {
  group('parseEnumValuesFromCheckConstraint', () {
    test('parses values from IN-list checks', () {
      final result = parseEnumValuesFromCheckConstraint(
        "CHECK ((action_type IN ('insert_text', 'replace_text', 'prompt_user')))",
      );

      expect(result, equals(['insert_text', 'replace_text', 'prompt_user']));
    });

    test('parses values from ANY-ARRAY checks', () {
      final result = parseEnumValuesFromCheckConstraint(
        "CHECK (((action_type)::text = ANY (ARRAY['insert_text'::text, 'replace_text'::text, 'prompt_user'::text])))",
      );

      expect(result, equals(['insert_text', 'replace_text', 'prompt_user']));
    });

    test('unescapes and de-duplicates values', () {
      final result = parseEnumValuesFromCheckConstraint(
        "CHECK ((person_name IN ('bob''s', 'alice', 'alice')))",
      );

      expect(result, equals(["bob's", 'alice']));
    });

    test('returns null for non-enum checks', () {
      final result = parseEnumValuesFromCheckConstraint('CHECK ((char_length(action_type) > 0))');

      expect(result, isNull);
    });

    test('returns null for NOT IN checks', () {
      final result = parseEnumValuesFromCheckConstraint(
        "CHECK ((action_type NOT IN ('insert_text', 'replace_text')))",
      );

      expect(result, isNull);
    });
  });
}
