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

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class DataSubject<T> {
  final BehaviorSubject<T> _subject = BehaviorSubject<T>();

  DataSubject.empty();

  DataSubject.seeded(T seedValue) {
    _subject.add(seedValue);
  }

  DataSubject.fromStream(Stream<T> stream) {
    _subject.addStream(stream);
  }

  BehaviorSubject<T> get subject => _subject;
  Stream<T> get stream => _subject.stream;
  T get value => _subject.value;

  void add(T data) {
    _subject.add(data);
  }

  void addError(dynamic error) {
    _subject.addError(error);
  }

  Future<void> addStream(Stream<T> stream) async {
    await _subject.addStream(stream);
  }

  void close() {
    _subject.close();
  }

  bool get isClosed => _subject.isClosed;

  StreamSubscription<T> listen(
    void Function(T data) onData, {
    Function? onError,
    void Function()? onDone,
    bool cancelOnError = false,
  }) {
    return _subject.listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}

class StatefulDataSubjectBuilder<T> extends StatefulWidget {
  final DataSubject<T> subject;
  final Widget Function(BuildContext context, T data) builder;
  final Widget Function(BuildContext context)? emptyBuilder;
  final Widget Function(BuildContext context, dynamic error)? errorBuilder;
  const StatefulDataSubjectBuilder({
    super.key,
    required this.subject,
    required this.builder,
    this.emptyBuilder,
    this.errorBuilder,
  });

  @override
  State<StatefulDataSubjectBuilder<T>> createState() => _StatefulDataSubjectBuilderState<T>();
}

class _StatefulDataSubjectBuilderState<T> extends State<StatefulDataSubjectBuilder<T>> {
  T? data;
  dynamic error;

  StreamSubscription<T>? _subscription;

  @override
  void initState() {
    super.initState();
    data = widget.subject.value;
    _subscription = widget.subject.stream.listen((event) {
      if (data == event) return;
      if (mounted) {
        setState(() {
          data = event;
        });
      } else {
        data = event;
      }
    });
    _subscription!.onError((e) {
      if (mounted) {
        setState(() {
          error = e;
        });
      } else {
        data = e;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _subscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (data != null) {
      return widget.builder(context, data as T);
    } else {
      if (error != null && widget.errorBuilder != null) {
        return widget.errorBuilder!(context, error);
      }
      return widget.emptyBuilder != null
          ? widget.emptyBuilder!(context)
          : widget.builder(context, data as T);
    }
  }
}

class DataSubjectBuilder<T> extends StatelessWidget {
  final DataSubject<T> subject;
  final Widget Function(BuildContext context, T data) builder;
  final Widget Function(BuildContext context)? emptyBuilder;
  final Widget Function(BuildContext context, dynamic error)? errorBuilder;
  const DataSubjectBuilder({
    super.key,
    required this.subject,
    required this.builder,
    this.emptyBuilder,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      stream: subject.stream,
      initialData: subject.value,
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data != null) {
          return builder(context, data);
        } else {
          if (snapshot.error != null && errorBuilder != null) {
            return errorBuilder!(context, snapshot.error);
          }
          return emptyBuilder != null ? emptyBuilder!(context) : builder(context, data as T);
        }
      },
    );
  }
}

class CombinedDataSubjectBuilder<T1, T2> extends StatelessWidget {
  final DataSubject<T1> subject1;
  final DataSubject<T2> subject2;
  final Widget Function(BuildContext context, T1 data1, T2 data2) builder;
  final Widget Function(BuildContext context)? emptyBuilder;
  const CombinedDataSubjectBuilder({
    super.key,
    required this.subject1,
    required this.subject2,
    required this.builder,
    this.emptyBuilder,
  });

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
        } else {
          return emptyBuilder != null ? emptyBuilder!(context) : const SizedBox.shrink();
        }
      },
    );
  }
}

class Combine3DataSubjectBuilder<T1, T2, T3> extends StatelessWidget {
  final DataSubject<T1> subject1;
  final DataSubject<T2> subject2;
  final DataSubject<T3> subject3;
  final Widget Function(BuildContext context, T1 data1, T2 data2, T3 data3) builder;
  final Widget Function(BuildContext context)? emptyBuilder;
  const Combine3DataSubjectBuilder({
    super.key,
    required this.subject1,
    required this.subject2,
    required this.subject3,
    required this.builder,
    this.emptyBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<dynamic>(
      stream: CombineLatestStream<dynamic, dynamic>([
        subject1.stream,
        subject2.stream,
        subject3.stream,
      ], (values) => values),
      initialData: [subject1.value, subject2.value, subject3.value],
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data != null) {
          final data1 = data[0] as T1;
          final data2 = data[1] as T2;
          final data3 = data[2] as T3;
          return builder(context, data1, data2, data3);
        } else {
          return emptyBuilder != null ? emptyBuilder!(context) : const SizedBox.shrink();
        }
      },
    );
  }
}

class Combine4DataSubjectBuilder<T1, T2, T3, T4> extends StatelessWidget {
  final DataSubject<T1> subject1;
  final DataSubject<T2> subject2;
  final DataSubject<T3> subject3;
  final DataSubject<T4> subject4;
  final Widget Function(BuildContext context, T1 data1, T2 data2, T3 data3, T4 data4) builder;
  final Widget Function(BuildContext context)? emptyBuilder;
  const Combine4DataSubjectBuilder({
    super.key,
    required this.subject1,
    required this.subject2,
    required this.subject3,
    required this.subject4,
    required this.builder,
    this.emptyBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<dynamic>(
      stream: CombineLatestStream<dynamic, dynamic>([
        subject1.stream,
        subject2.stream,
        subject3.stream,
        subject4.stream,
      ], (values) => values),
      initialData: [subject1.value, subject2.value, subject3.value, subject4.value],
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data != null) {
          final data1 = data[0] as T1;
          final data2 = data[1] as T2;
          final data3 = data[2] as T3;
          final data4 = data[3] as T4;
          return builder(context, data1, data2, data3, data4);
        } else {
          return emptyBuilder != null ? emptyBuilder!(context) : const SizedBox.shrink();
        }
      },
    );
  }
}

class SubjectTextField extends StatelessWidget {
  final TextEditingDataSubject subject;
  final InputDecoration? inputDecoration;
  final TextInputType? keyboardType;
  final bool autocorrect;
  final bool autofocus;
  final int? minLines;
  final int? maxLength;
  final int? maxLines;

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
      onChanged: (text) {
        subject.add(text);
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
    _subject.add(text);
  }
}
