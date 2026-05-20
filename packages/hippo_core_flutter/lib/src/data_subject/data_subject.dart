/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:hippo_core/hippo_core.dart';
import 'package:rxdart/rxdart.dart';

class StatefulDataSubjectBuilder<T> extends StatefulWidget {
  const StatefulDataSubjectBuilder({
    super.key,
    required this.subject,
    required this.builder,
    this.emptyBuilder,
    this.errorBuilder,
  });

  final DataSubject<T> subject;
  final Widget Function(BuildContext context, T data) builder;
  final Widget Function(BuildContext context)? emptyBuilder;
  final Widget Function(BuildContext context, Object? error)? errorBuilder;

  @override
  State<StatefulDataSubjectBuilder<T>> createState() => _StatefulDataSubjectBuilderState<T>();
}

class _StatefulDataSubjectBuilderState<T> extends State<StatefulDataSubjectBuilder<T>> {
  late T? data = _readSubjectValue();
  Object? error;

  StreamSubscription<T>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = widget.subject.stream.listen(
      (event) {
        if (data == event) {
          return;
        }
        if (mounted) {
          setState(() {
            data = event;
            error = null;
          });
        } else {
          data = event;
          error = null;
        }
      },
      onError: (Object e) {
        if (mounted) {
          setState(() {
            error = e;
          });
        } else {
          error = e;
        }
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentData = data;
    if (currentData != null) {
      return widget.builder(context, currentData);
    }
    final currentError = error;
    if (currentError != null && widget.errorBuilder != null) {
      return widget.errorBuilder!(context, currentError);
    }
    return widget.emptyBuilder != null
        ? widget.emptyBuilder!(context)
        : widget.builder(context, currentData as T);
  }

  T? _readSubjectValue() {
    try {
      return widget.subject.value;
    } on ValueStreamError {
      return null;
    }
  }
}

class DataSubjectBuilder<T> extends StatelessWidget {
  const DataSubjectBuilder({
    super.key,
    required this.subject,
    required this.builder,
    this.emptyBuilder,
    this.errorBuilder,
  });

  final DataSubject<T> subject;
  final Widget Function(BuildContext context, T data) builder;
  final Widget Function(BuildContext context)? emptyBuilder;
  final Widget Function(BuildContext context, Object? error)? errorBuilder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      stream: subject.stream,
      initialData: _readSubjectValue(),
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data != null) {
          return builder(context, data);
        }
        if (snapshot.error != null && errorBuilder != null) {
          return errorBuilder!(context, snapshot.error);
        }
        return emptyBuilder != null ? emptyBuilder!(context) : builder(context, data as T);
      },
    );
  }

  T? _readSubjectValue() {
    try {
      return subject.value;
    } on ValueStreamError {
      return null;
    }
  }
}

class CombinedDataSubjectBuilder<T1, T2> extends StatelessWidget {
  const CombinedDataSubjectBuilder({
    super.key,
    required this.subject1,
    required this.subject2,
    required this.builder,
    this.emptyBuilder,
  });

  final DataSubject<T1> subject1;
  final DataSubject<T2> subject2;
  final Widget Function(BuildContext context, T1 data1, T2 data2) builder;
  final Widget Function(BuildContext context)? emptyBuilder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<dynamic>(
      stream: Rx.combineLatest2(subject1.stream, subject2.stream, (data1, data2) => [data1, data2]),
      initialData: [subject1.value, subject2.value],
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data != null) {
          final data1 = data[0] as T1;
          final data2 = data[1] as T2;
          return builder(context, data1, data2);
        }
        return emptyBuilder != null ? emptyBuilder!(context) : const SizedBox.shrink();
      },
    );
  }
}

class Combine3DataSubjectBuilder<T1, T2, T3> extends StatelessWidget {
  const Combine3DataSubjectBuilder({
    super.key,
    required this.subject1,
    required this.subject2,
    required this.subject3,
    required this.builder,
    this.emptyBuilder,
  });

  final DataSubject<T1> subject1;
  final DataSubject<T2> subject2;
  final DataSubject<T3> subject3;
  final Widget Function(BuildContext context, T1 data1, T2 data2, T3 data3) builder;
  final Widget Function(BuildContext context)? emptyBuilder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<dynamic>>(
      stream: CombineLatestStream<dynamic, List<dynamic>>([
        subject1.stream,
        subject2.stream,
        subject3.stream,
      ], (values) => values),
      initialData: [
        _readSubjectValue(subject1),
        _readSubjectValue(subject2),
        _readSubjectValue(subject3),
      ],
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data != null && data[0] != null && data[1] != null && data[2] != null) {
          return builder(context, data[0] as T1, data[1] as T2, data[2] as T3);
        }
        return emptyBuilder != null ? emptyBuilder!(context) : const SizedBox.shrink();
      },
    );
  }
}

class Combine4DataSubjectBuilder<T1, T2, T3, T4> extends StatelessWidget {
  const Combine4DataSubjectBuilder({
    super.key,
    required this.subject1,
    required this.subject2,
    required this.subject3,
    required this.subject4,
    required this.builder,
    this.emptyBuilder,
  });

  final DataSubject<T1> subject1;
  final DataSubject<T2> subject2;
  final DataSubject<T3> subject3;
  final DataSubject<T4> subject4;
  final Widget Function(BuildContext context, T1 data1, T2 data2, T3 data3, T4 data4) builder;
  final Widget Function(BuildContext context)? emptyBuilder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<dynamic>>(
      stream: CombineLatestStream<dynamic, List<dynamic>>([
        subject1.stream,
        subject2.stream,
        subject3.stream,
        subject4.stream,
      ], (values) => values),
      initialData: [
        _readSubjectValue(subject1),
        _readSubjectValue(subject2),
        _readSubjectValue(subject3),
        _readSubjectValue(subject4),
      ],
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data != null &&
            data[0] != null &&
            data[1] != null &&
            data[2] != null &&
            data[3] != null) {
          return builder(context, data[0] as T1, data[1] as T2, data[2] as T3, data[3] as T4);
        }
        return emptyBuilder != null ? emptyBuilder!(context) : const SizedBox.shrink();
      },
    );
  }
}

class TextEditingDataSubject extends DataSubject<String> {
  TextEditingDataSubject.empty() : textEditingController = TextEditingController(), super.empty();

  TextEditingDataSubject.seeded(super.seedValue)
    : textEditingController = TextEditingController(text: seedValue),
      super.seeded();

  final TextEditingController textEditingController;
  final errorSubject = DataSubject<String?>.seeded(null);

  void setText(String text) {
    textEditingController.text = text;
    add(text);
  }
}

T? _readSubjectValue<T>(DataSubject<T> subject) {
  try {
    return subject.value;
  } on ValueStreamError {
    return null;
  }
}
