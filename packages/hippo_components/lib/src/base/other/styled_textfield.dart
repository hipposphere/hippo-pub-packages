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
import 'package:forui/forui.dart';

class StyledTextfield extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final Widget? label;
  final String? hint;
  final int? minLines, maxLines, maxLength;
  final bool autofocus;
  final bool enabled;
  final bool obscureText;
  final ValueChanged<String>? onChange;
  final ValueChanged<String>? onSubmit;
  final Iterable<String>? autofillHints;
  final TextInputType? keyboardType;
  final Widget? prefix;
  final Widget? suffix;
  const StyledTextfield({
    super.key,
    required this.controller,
    this.focusNode,
    this.label,
    this.hint,
    this.minLines,
    this.maxLines,
    this.maxLength,
    this.enabled = true,
    this.autofocus = false,
    this.obscureText = false,
    this.onChange,
    this.onSubmit,
    this.autofillHints,
    this.keyboardType,
    this.prefix,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return FTextField(
      control: .managed(
        controller: controller,
        onChange: onChange == null ? null : (value) => onChange!(value.text),
      ),
      focusNode: focusNode,
      autofocus: autofocus,
      label: label,
      hint: hint,
      // style: fTheme.textFieldStyle.copyWith(
      //   enabledStyle: fTheme.textFieldStyle.enabledStyle.copyWith(
      //     contentTextStyle: fTheme.textFieldStyle.enabledStyle.contentTextStyle.copyWith(
      //       color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
      //     ),
      //   ),
      // ),
      keyboardType: keyboardType,
      autofillHints: autofillHints,
      obscureText: obscureText,
      enabled: enabled,
      minLines: minLines,
      maxLines: maxLines,
      maxLength: maxLength,

      onSubmit: onSubmit,
      prefixBuilder: prefix != null ? (_, _, _) => prefix! : null,
      suffixBuilder: suffix != null ? (_, _, _) => suffix! : null,
    );
  }
}
