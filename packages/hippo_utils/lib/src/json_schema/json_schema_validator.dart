/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/

import 'package:flutter/foundation.dart';

import 'json_schema_nodes.dart';
import 'json_schema_path.dart';

enum JsonSchemaDiagnosticSeverity { warning, error }

@immutable
class JsonSchemaDiagnostic {
  const JsonSchemaDiagnostic({
    required this.path,
    required this.message,
    required this.severity,
  });

  final JsonSchemaPath path;
  final String message;
  final JsonSchemaDiagnosticSeverity severity;

  Map<String, dynamic> toJson() {
    return {
      'path': path.toString(),
      'message': message,
      'severity': severity.name,
    };
  }
}

List<JsonSchemaDiagnostic> validateSchema(JsonSchemaNode schema) {
  final diagnostics = <JsonSchemaDiagnostic>[];
  _validateNode(
    node: schema,
    path: const JsonSchemaPath.root(),
    diagnostics: diagnostics,
  );
  return diagnostics;
}

void _validateNode({
  required JsonSchemaNode node,
  required JsonSchemaPath path,
  required List<JsonSchemaDiagnostic> diagnostics,
}) {
  switch (node) {
    case JsonSchemaStringNode():
      _validateStringNode(
        node: node,
        path: path,
        diagnostics: diagnostics,
      );
    case JsonSchemaNumberNode():
      _validateNumberNode(
        node: node,
        path: path,
        diagnostics: diagnostics,
      );
    case JsonSchemaBooleanNode():
      _validateBooleanNode(node: node, path: path, diagnostics: diagnostics);
    case JsonSchemaObjectNode():
      _validateObjectNode(
        node: node,
        path: path,
        diagnostics: diagnostics,
      );
    case JsonSchemaArrayNode():
      _validateArrayNode(
        node: node,
        path: path,
        diagnostics: diagnostics,
      );
  }
}

void _validateBooleanNode({
  required JsonSchemaBooleanNode node,
  required JsonSchemaPath path,
  required List<JsonSchemaDiagnostic> diagnostics,
}) {
  if (node.defaultValue == null) {
    return;
  }

  // No validation warnings for boolean defaults in this initial version.
}

void _validateStringNode({
  required JsonSchemaStringNode node,
  required JsonSchemaPath path,
  required List<JsonSchemaDiagnostic> diagnostics,
}) {
  if (node.minLength != null && node.minLength! < 0) {
    diagnostics.add(
      JsonSchemaDiagnostic(
        path: path,
        message: 'minLength must be greater or equal to 0.',
        severity: JsonSchemaDiagnosticSeverity.warning,
      ),
    );
  }
  if (node.maxLength != null && node.maxLength! < 0) {
    diagnostics.add(
      JsonSchemaDiagnostic(
        path: path,
        message: 'maxLength must be greater or equal to 0.',
        severity: JsonSchemaDiagnosticSeverity.warning,
      ),
    );
  }
  if (node.minLength != null && node.maxLength != null && node.minLength! > node.maxLength!) {
    diagnostics.add(
      JsonSchemaDiagnostic(
        path: path,
        message: 'minLength must not be greater than maxLength.',
        severity: JsonSchemaDiagnosticSeverity.warning,
      ),
    );
  }
  if (node.pattern != null && node.pattern!.trim().isNotEmpty) {
    try {
      RegExp(node.pattern!);
    } on FormatException catch (_) {
      diagnostics.add(
        JsonSchemaDiagnostic(
          path: path,
          message: 'pattern is not a valid regular expression.',
          severity: JsonSchemaDiagnosticSeverity.warning,
        ),
      );
    }
  }

  final enumValues = node.enumValues;
  if (enumValues != null) {
    if (enumValues.isEmpty) {
      diagnostics.add(
        JsonSchemaDiagnostic(
          path: path,
          message: 'enum list should not be empty.',
          severity: JsonSchemaDiagnosticSeverity.warning,
        ),
      );
    } else {
      final seen = <String>{};
      for (final value in enumValues) {
        if (!seen.add(value)) {
          diagnostics.add(
            JsonSchemaDiagnostic(
              path: path,
              message: 'enum contains duplicate value: "$value".',
              severity: JsonSchemaDiagnosticSeverity.warning,
            ),
          );
        }
      }
    }
  }
}

void _validateNumberNode({
  required JsonSchemaNumberNode node,
  required JsonSchemaPath path,
  required List<JsonSchemaDiagnostic> diagnostics,
}) {
  if (node.minimum != null && node.maximum != null && node.minimum! > node.maximum!) {
    diagnostics.add(
      JsonSchemaDiagnostic(
        path: path,
        message: 'minimum must not be greater than maximum.',
        severity: JsonSchemaDiagnosticSeverity.warning,
      ),
    );
  }
  if (node.multipleOf != null && node.multipleOf! <= 0) {
    diagnostics.add(
      JsonSchemaDiagnostic(
        path: path,
        message: 'multipleOf must be greater than 0.',
        severity: JsonSchemaDiagnosticSeverity.warning,
      ),
    );
  }
}

void _validateObjectNode({
  required JsonSchemaObjectNode node,
  required JsonSchemaPath path,
  required List<JsonSchemaDiagnostic> diagnostics,
}) {
  for (final requiredKey in node.required) {
    if (!node.properties.containsKey(requiredKey)) {
      diagnostics.add(
        JsonSchemaDiagnostic(
          path: path.childProperty(requiredKey),
          message: 'Required property "$requiredKey" does not exist.',
          severity: JsonSchemaDiagnosticSeverity.warning,
        ),
      );
    }
  }

  for (final entry in node.properties.entries) {
    _validateNode(
      node: entry.value,
      path: path.childProperty(entry.key),
      diagnostics: diagnostics,
    );
  }
}

void _validateArrayNode({
  required JsonSchemaArrayNode node,
  required JsonSchemaPath path,
  required List<JsonSchemaDiagnostic> diagnostics,
}) {
  if (node.minItems != null && node.minItems! < 0) {
    diagnostics.add(
      JsonSchemaDiagnostic(
        path: path,
        message: 'minItems must be greater or equal to 0.',
        severity: JsonSchemaDiagnosticSeverity.warning,
      ),
    );
  }
  if (node.maxItems != null && node.maxItems! < 0) {
    diagnostics.add(
      JsonSchemaDiagnostic(
        path: path,
        message: 'maxItems must be greater or equal to 0.',
        severity: JsonSchemaDiagnosticSeverity.warning,
      ),
    );
  }
  if (node.minItems != null && node.maxItems != null && node.minItems! > node.maxItems!) {
    diagnostics.add(
      JsonSchemaDiagnostic(
        path: path,
        message: 'minItems must not be greater than maxItems.',
        severity: JsonSchemaDiagnosticSeverity.warning,
      ),
    );
  }

  _validateNode(
    node: node.items,
    path: path.childItems(),
    diagnostics: diagnostics,
  );
}
