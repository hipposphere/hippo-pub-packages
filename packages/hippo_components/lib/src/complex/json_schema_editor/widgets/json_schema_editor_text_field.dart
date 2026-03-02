// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hippo_components/hippo_components.dart';

import 'json_schema_editor_info_icon.dart';

class JsonSchemaEditorTextField extends StatefulWidget {
  const JsonSchemaEditorTextField({
    super.key,
    required this.value,
    required this.hint,
    required this.onChanged,
    this.helpText,
    this.debounceDelay,
    this.onSubmitted,
    this.onCleared,
    this.keyboardType,
    this.maxLines = 1,
  });

  final String? value;
  final String hint;
  final String? helpText;
  final ValueChanged<String> onChanged;
  final Duration? debounceDelay;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onCleared;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  State<JsonSchemaEditorTextField> createState() => _JsonSchemaEditorTextFieldState();
}

class _JsonSchemaEditorTextFieldState extends State<JsonSchemaEditorTextField> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  Timer? _onChangeDebounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value ?? '');
    _focusNode.addListener(_handleFocusLoss);
  }

  @override
  void didUpdateWidget(covariant JsonSchemaEditorTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != _controller.text) {
      _onChangeDebounce?.cancel();
      _controller.text = widget.value ?? '';
    }
  }

  void _handleSubmit(String value) {
    _onChangeDebounce?.cancel();
    if (value.trim().isEmpty) {
      widget.onCleared?.call();
    }
    widget.onSubmitted?.call(value);
  }

  void _handleFocusLoss() {
    if (_focusNode.hasFocus) {
      return;
    }
    _handleSubmit(_controller.text);
  }

  void _handleChange(String value) {
    final debounceDelay = widget.debounceDelay;
    if (debounceDelay == null) {
      widget.onChanged(value);
      return;
    }

    _onChangeDebounce?.cancel();
    _onChangeDebounce = Timer(debounceDelay, () {
      if (!mounted) {
        return;
      }
      widget.onChanged(value);
    });
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocusLoss)
      ..dispose();
    _onChangeDebounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StyledTextfield(
      controller: _controller,
      focusNode: _focusNode,
      hint: widget.hint,
      keyboardType: widget.keyboardType,
      suffix: widget.helpText == null
          ? null
          : Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: JsonSchemaEditorInfoIcon(message: widget.helpText!),
            ),
      maxLines: widget.maxLines,
      onChange: (value) {
        _handleChange(value);
      },
      onSubmit: (value) {
        _handleSubmit(value);
      },
    );
  }
}
