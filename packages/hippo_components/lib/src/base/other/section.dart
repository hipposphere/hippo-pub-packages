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
import 'package:hippo_components/hippo_components.dart';
import 'package:hippo_core/hippo_core.dart';
import 'package:hippo_core_flutter/hippo_core_flutter.dart';

/// Section with a header and a card
class Section extends StatelessWidget {
  final String? headerText;
  final Widget child;
  const Section({super.key, this.headerText, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        if (headerText != null)
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 4),
            child: SectionHeader(text: headerText!),
          ),
        Card(child: child),
        SizedBox(height: 8),
      ],
    );
  }
}

class PaddedSectionHeader extends StatelessWidget {
  final String text;
  const PaddedSectionHeader({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return SectionPadding(child: SectionHeader(text: text));
  }
}

class CollapsibleHeaderController {
  final DataSubject<bool> _subject;

  CollapsibleHeaderController({bool initialState = false})
    : _subject = DataSubject.seeded(initialState);

  DataSubject<bool> get subject => _subject;

  bool get isExpanded => _subject.value;

  void toggle() {
    _subject.add(!_subject.value);
  }

  void expand() {
    _subject.add(true);
  }

  void collapse() {
    _subject.add(false);
  }

  void dispose() {
    _subject.close();
  }
}

class SectionHeaderCollapsible extends StatelessWidget {
  final String title;
  final Widget child;
  final CollapsibleHeaderController controller;

  const SectionHeaderCollapsible({
    super.key,
    required this.title,
    required this.child,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return DataSubjectBuilder<bool>(
      subject: controller.subject,
      builder: (context, isExpanded) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: controller.toggle,
              splashColor: Theme.of(context).splashColor,
              borderRadius: BorderRadius.circular(8.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                  ],
                ),
              ),
            ),
            if (isExpanded) ...[const Gap(16), child],
          ],
        );
      },
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String text;
  const SectionHeader({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600));
  }
}

class SectionHeaderWithActions extends StatelessWidget {
  final String label;
  final List<Widget> actions;

  const SectionHeaderWithActions({super.key, required this.label, required this.actions});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: .max,
      crossAxisAlignment: .center,
      children: [
        Expanded(
          child: Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
        Row(mainAxisSize: .min, mainAxisAlignment: .end, children: actions),
      ],
    );
  }
}

class SectionPadding extends StatelessWidget {
  final Widget child;
  const SectionPadding({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.only(left: 16.0, right: 16.0), child: child);
  }
}

class SectionHeaderRich extends StatelessWidget {
  final TextSpan textSpan;
  const SectionHeaderRich({super.key, required this.textSpan});

  @override
  Widget build(BuildContext context) {
    return Text.rich(textSpan, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600));
  }
}
