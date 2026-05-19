/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
import 'package:flutter/material.dart';
import 'package:hippo_core_flutter/hippo_core_flutter.dart';

class SubjectTextField extends StatelessWidget {
  const SubjectTextField({
    super.key,
    required this.subject,
    this.inputDecoration,
    this.keyboardType,
    this.autocorrect = true,
    this.autofocus = false,
    this.minLines,
    this.maxLength,
    this.maxLines = 1,
  });

  final TextEditingDataSubject subject;
  final InputDecoration? inputDecoration;
  final TextInputType? keyboardType;
  final bool autocorrect;
  final bool autofocus;
  final int? minLines;
  final int? maxLength;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: subject.textEditingController,
      decoration: inputDecoration,
      keyboardType: keyboardType,
      autocorrect: autocorrect,
      autofocus: autofocus,
      minLines: minLines,
      maxLength: maxLength,
      maxLines: maxLines,
      onChanged: subject.add,
    );
  }
}
