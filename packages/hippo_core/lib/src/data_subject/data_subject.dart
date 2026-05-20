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

  bool get hasValue => _subject.hasValue;

  StreamSubscription<T> listen(
    void Function(T data) onData, {
    Function? onError,
    void Function()? onDone,
    bool cancelOnError = false,
  }) {
    return _subject.listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}
