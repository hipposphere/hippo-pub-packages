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

@immutable
class JsonSchemaEditorFeatureOptions {
  const JsonSchemaEditorFeatureOptions({
    this.stringMinLength = true,
    this.stringMaxLength = true,
    this.stringPattern = true,
    this.stringEnum = true,
    this.numberMinimum = true,
    this.numberMaximum = true,
    this.numberExclusiveMinimum = true,
    this.numberExclusiveMaximum = true,
    this.numberMultipleOf = true,
    this.arrayMinItems = true,
    this.arrayMaxItems = true,
    this.arrayUniqueItems = true,
    this.objectAdditionalProperties = true,
  });

  static const JsonSchemaEditorFeatureOptions allEnabled = JsonSchemaEditorFeatureOptions();

  final bool stringMinLength;
  final bool stringMaxLength;
  final bool stringPattern;
  final bool stringEnum;
  final bool numberMinimum;
  final bool numberMaximum;
  final bool numberExclusiveMinimum;
  final bool numberExclusiveMaximum;
  final bool numberMultipleOf;
  final bool arrayMinItems;
  final bool arrayMaxItems;
  final bool arrayUniqueItems;
  final bool objectAdditionalProperties;

  bool get hasAnyStringConstraint =>
      stringMinLength || stringMaxLength || stringPattern || stringEnum;

  JsonSchemaEditorFeatureOptions copyWith({
    bool? stringMinLength,
    bool? stringMaxLength,
    bool? stringPattern,
    bool? stringEnum,
    bool? numberMinimum,
    bool? numberMaximum,
    bool? numberExclusiveMinimum,
    bool? numberExclusiveMaximum,
    bool? numberMultipleOf,
    bool? arrayMinItems,
    bool? arrayMaxItems,
    bool? arrayUniqueItems,
    bool? objectAdditionalProperties,
  }) {
    return JsonSchemaEditorFeatureOptions(
      stringMinLength: stringMinLength ?? this.stringMinLength,
      stringMaxLength: stringMaxLength ?? this.stringMaxLength,
      stringPattern: stringPattern ?? this.stringPattern,
      stringEnum: stringEnum ?? this.stringEnum,
      numberMinimum: numberMinimum ?? this.numberMinimum,
      numberMaximum: numberMaximum ?? this.numberMaximum,
      numberExclusiveMinimum: numberExclusiveMinimum ?? this.numberExclusiveMinimum,
      numberExclusiveMaximum: numberExclusiveMaximum ?? this.numberExclusiveMaximum,
      numberMultipleOf: numberMultipleOf ?? this.numberMultipleOf,
      arrayMinItems: arrayMinItems ?? this.arrayMinItems,
      arrayMaxItems: arrayMaxItems ?? this.arrayMaxItems,
      arrayUniqueItems: arrayUniqueItems ?? this.arrayUniqueItems,
      objectAdditionalProperties: objectAdditionalProperties ?? this.objectAdditionalProperties,
    );
  }
}
