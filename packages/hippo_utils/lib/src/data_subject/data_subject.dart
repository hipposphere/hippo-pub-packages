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
import 'package:hippo_core/hippo_core.dart';

class SubjectTextField extends StatelessWidget {
  const SubjectTextField({
    super.key,
    required this.controller,
    required this.subject,
    this.inputDecoration,
    this.keyboardType,
    this.autocorrect = true,
    this.autofocus = false,
    this.minLines,
    this.maxLength,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final DataSubject<String> subject;
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
      controller: controller,
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
