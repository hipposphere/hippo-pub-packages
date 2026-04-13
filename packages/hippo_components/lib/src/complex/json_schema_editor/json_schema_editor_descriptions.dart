import 'package:flutter/widgets.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:hippo_utils/hippo_utils.dart';

String? jsonSchemaHelpByKeyword(BuildContext context, String keyword) {
  return switch (keyword) {
    'const' => context.lazyTranslate(
      en: 'Require this schema to match one exact JSON value.',
      de: 'Dieses Schema muss genau einem bestimmten JSON-Wert entsprechen.',
      zh: '要求此 Schema 精确匹配某一个 JSON 值。',
    ),
    'default' => context.lazyTranslate(
      en: 'Default value used when the field is not supplied.',
      de: 'Standardwert, der verwendet wird, wenn das Feld nicht gesetzt ist.',
      zh: '当字段未提供时使用的默认值。',
    ),
    'type' => context.lazyTranslate(
      en: 'Type of JSON value this node validates.',
      de: 'Typ des JSON-Werts, den dieser Knoten validiert.',
      zh: '此节点校验的 JSON 值类型。',
    ),
    'title' => context.lazyTranslate(
      en: 'Optional human-readable name for this schema node.',
      de: 'Optionaler, menschenlesbarer Name für diesen Schema-Knoten.',
      zh: '此 Schema 节点的可选可读名称。',
    ),
    'description' => context.lazyTranslate(
      en: 'Optional description shown in docs and editor tooling.',
      de: 'Optionale Beschreibung für Dokumentation und Editor-Hinweise.',
      zh: '显示在文档和编辑器中的可选说明。',
    ),
    'allOf' => context.lazyTranslate(
      en: 'Combine this schema with every schema listed here. The instance must satisfy all of them.',
      de: 'Kombiniert dieses Schema mit allen hier gelisteten Schemata. Die Instanz muss alle erfüllen.',
      zh: '将此 Schema 与此处列出的所有 Schema 组合，实例必须全部满足。',
    ),
    'oneOf' => context.lazyTranslate(
      en: 'Match exactly one schema from the listed alternatives.',
      de: 'Es muss genau eines der aufgeführten Alternativ-Schemata passen.',
      zh: '必须且只能匹配列出的备选 Schema 中的一个。',
    ),
    r'$ref' => context.lazyTranslate(
      en: 'Reference another schema by JSON Pointer, URI, or external schema location.',
      de: 'Verweist per JSON Pointer, URI oder externer Schema-Quelle auf ein anderes Schema.',
      zh: '通过 JSON Pointer、URI 或外部 Schema 位置引用另一个 Schema。',
    ),
    'minLength' => context.lazyTranslate(
      en: 'Minimum number of characters allowed in the string.',
      de: 'Mindestanzahl an Zeichen, die der String enthalten muss.',
      zh: '字符串允许的最少字符数。',
    ),
    'maxLength' => context.lazyTranslate(
      en: 'Maximum number of characters allowed in the string.',
      de: 'Maximale Anzahl an Zeichen, die der String enthalten darf.',
      zh: '字符串允许的最多字符数。',
    ),
    'pattern' => context.lazyTranslate(
      en: 'Regular expression pattern the string must match.',
      de: 'Regulärer Ausdruck, den der String erfüllen muss.',
      zh: '字符串必须匹配的正则表达式模式。',
    ),
    'enum' => context.lazyTranslate(
      en: 'Allowed set of string values. Only one of these values is valid.',
      de: 'Erlaubte Menge an String-Werten. Nur einer dieser Werte ist gültig.',
      zh: '允许的字符串取值集合，只能是其中之一。',
    ),
    'minimum' => context.lazyTranslate(
      en: 'Smallest allowed numeric value.',
      de: 'Kleinster erlaubter Zahlenwert.',
      zh: '允许的最小数值。',
    ),
    'maximum' => context.lazyTranslate(
      en: 'Largest allowed numeric value.',
      de: 'Größter erlaubter Zahlenwert.',
      zh: '允许的最大数值。',
    ),
    'exclusiveMinimum' => context.lazyTranslate(
      en: 'If true, value must be greater than minimum.',
      de: 'Wenn aktiv, muss der Wert größer als das Minimum sein.',
      zh: '若为 true，值必须大于 minimum。',
    ),
    'exclusiveMaximum' => context.lazyTranslate(
      en: 'If true, value must be less than maximum.',
      de: 'Wenn aktiv, muss der Wert kleiner als das Maximum sein.',
      zh: '若为 true，值必须小于 maximum。',
    ),
    'multipleOf' => context.lazyTranslate(
      en: 'Value must be a multiple of this number.',
      de: 'Der Wert muss ein Vielfaches dieser Zahl sein.',
      zh: '值必须是该数字的倍数。',
    ),
    'minItems' => context.lazyTranslate(
      en: 'Minimum number of items required in the array.',
      de: 'Mindestanzahl an Einträgen, die das Array enthalten muss.',
      zh: '数组要求的最少元素数量。',
    ),
    'maxItems' => context.lazyTranslate(
      en: 'Maximum number of items allowed in the array.',
      de: 'Maximale Anzahl an Einträgen, die das Array enthalten darf.',
      zh: '数组允许的最多元素数量。',
    ),
    'uniqueItems' => context.lazyTranslate(
      en: 'All items must be unique across the array.',
      de: 'Alle Einträge im Array müssen eindeutig sein.',
      zh: '数组中的所有元素都必须唯一。',
    ),
    'additionalProperties' => context.lazyTranslate(
      en: 'Allow properties not listed under "Properties" for this object.',
      de: 'Erlaubt für dieses Objekt zusätzliche Properties, die nicht unter „Properties“ gelistet sind.',
      zh: '允许该对象包含未在“Properties”中列出的额外属性。',
    ),
    'required' => context.lazyTranslate(
      en: 'Whether this property must appear in the object.',
      de: 'Gibt an, ob diese Property im Objekt vorhanden sein muss.',
      zh: '该属性是否必须出现在对象中。',
    ),
    'propertyKey' => context.lazyTranslate(
      en: 'Property identifier used as key in the object.',
      de: 'Property-Bezeichner, der als Schlüssel im Objekt verwendet wird.',
      zh: '在对象中作为键使用的属性标识。',
    ),
    'properties' => context.lazyTranslate(
      en: 'Property definitions for fields contained in the object.',
      de: 'Property-Definitionen für die im Objekt enthaltenen Felder.',
      zh: '对象中包含字段的属性定义。',
    ),
    'items' => context.lazyTranslate(
      en: 'Schema applied to each item in the array.',
      de: 'Schema, das auf jedes Element im Array angewendet wird.',
      zh: '应用于数组每个元素的 Schema。',
    ),
    'extensionField' => context.lazyTranslate(
      en: 'Additional schema metadata entries (commonly namespaced as extension keys).',
      de: 'Zusätzliche Schema-Metadaten (oft als namensraumbezogene Extension-Keys).',
      zh: '额外的 Schema 元数据项（通常以扩展键命名空间形式出现）。',
    ),
    _ => null,
  };
}

String jsonSchemaKeywordLabel(BuildContext context, String keyword) {
  return switch (keyword) {
    'title' => context.lazyTranslate(en: 'Title', de: 'Titel', zh: '标题'),
    'description' => context.lazyTranslate(en: 'Description', de: 'Beschreibung', zh: '说明'),
    'minLength' => context.lazyTranslate(en: 'Min length', de: 'Min. Länge', zh: '最小长度'),
    'maxLength' => context.lazyTranslate(en: 'Max length', de: 'Max. Länge', zh: '最大长度'),
    'pattern' => context.lazyTranslate(en: 'Pattern', de: 'Muster', zh: '模式'),
    'enum' => context.lazyTranslate(en: 'Enum', de: 'Enum', zh: '枚举'),
    'minimum' => context.lazyTranslate(en: 'Minimum', de: 'Minimum', zh: '最小值'),
    'maximum' => context.lazyTranslate(en: 'Maximum', de: 'Maximum', zh: '最大值'),
    'exclusiveMinimum' => context.lazyTranslate(
      en: 'Exclusive min',
      de: 'Exkl. Minimum',
      zh: '排除最小值',
    ),
    'exclusiveMaximum' => context.lazyTranslate(
      en: 'Exclusive max',
      de: 'Exkl. Maximum',
      zh: '排除最大值',
    ),
    'multipleOf' => context.lazyTranslate(en: 'Multiple of', de: 'Vielfaches von', zh: '倍数'),
    'default' => context.lazyTranslate(en: 'Default', de: 'Standardwert', zh: '默认值'),
    'additionalProperties' => context.lazyTranslate(
      en: 'Additional properties',
      de: 'Zusätzliche Properties',
      zh: '额外属性',
    ),
    'required' => context.lazyTranslate(en: 'Required', de: 'Pflicht', zh: '必填'),
    'propertyKey' => context.lazyTranslate(en: 'Property key', de: 'Property-Key', zh: '属性键'),
    'properties' => context.lazyTranslate(en: 'Properties', de: 'Properties', zh: '属性'),
    'items' => context.lazyTranslate(en: 'Items', de: 'Elemente', zh: '元素'),
    'minItems' => context.lazyTranslate(en: 'Min items', de: 'Min. Elemente', zh: '最少元素'),
    'maxItems' => context.lazyTranslate(en: 'Max items', de: 'Max. Elemente', zh: '最多元素'),
    'uniqueItems' => context.lazyTranslate(
      en: 'Unique items',
      de: 'Eindeutige Elemente',
      zh: '唯一元素',
    ),
    'extensionField' => context.lazyTranslate(en: 'Extensions', de: 'Erweiterungen', zh: '扩展'),
    _ => keyword,
  };
}

String jsonSchemaTypeLabel(BuildContext context, JsonSchemaNodeType type) {
  return switch (type) {
    JsonSchemaNodeType.string => context.lazyTranslate(en: 'String', de: 'String', zh: '字符串'),
    JsonSchemaNodeType.number => context.lazyTranslate(en: 'Number', de: 'Zahl', zh: '数字'),
    JsonSchemaNodeType.integer => context.lazyTranslate(en: 'Integer', de: 'Ganzzahl', zh: '整数'),
    JsonSchemaNodeType.boolean => context.lazyTranslate(en: 'Boolean', de: 'Boolean', zh: '布尔值'),
    JsonSchemaNodeType.object => context.lazyTranslate(en: 'Object', de: 'Objekt', zh: '对象'),
    JsonSchemaNodeType.array => context.lazyTranslate(en: 'Array', de: 'Array', zh: '数组'),
  };
}

String jsonSchemaTypeHelp(BuildContext context, JsonSchemaNodeType type) {
  return switch (type) {
    JsonSchemaNodeType.string => context.lazyTranslate(
      en: 'String: text value (e.g., names, labels, IDs).',
      de: 'String: Textwert, z. B. Namen, Labels oder IDs.',
      zh: '字符串：文本值，例如名称、标签或 ID。',
    ),
    JsonSchemaNodeType.integer => context.lazyTranslate(
      en: 'Integer: whole number without decimals.',
      de: 'Ganzzahl: Ganze Zahl ohne Nachkommastellen.',
      zh: '整数：不带小数的数字。',
    ),
    JsonSchemaNodeType.number => context.lazyTranslate(
      en: 'Number: numeric value, including decimals.',
      de: 'Zahl: Numerischer Wert, auch mit Nachkommastellen.',
      zh: '数字：可包含小数的数值。',
    ),
    JsonSchemaNodeType.boolean => context.lazyTranslate(
      en: 'Boolean: true/false value.',
      de: 'Boolean: true/false-Wert.',
      zh: '布尔值：true/false。',
    ),
    JsonSchemaNodeType.object => context.lazyTranslate(
      en: 'Object: map with named properties.',
      de: 'Objekt: Struktur mit benannten Properties.',
      zh: '对象：包含命名属性的映射结构。',
    ),
    JsonSchemaNodeType.array => context.lazyTranslate(
      en: 'Array: ordered list of items.',
      de: 'Array: Geordnete Liste von Elementen.',
      zh: '数组：有序元素列表。',
    ),
  };
}
