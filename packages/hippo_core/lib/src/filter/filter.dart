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

import 'package:hippo_core/src/data_subject/data_subject.dart';

typedef FilterItemsFetcher<T> = FutureOr<Iterable<T>> Function(List<FilterValue<dynamic>> values);

abstract class Filter {
  const Filter();

  Stream<FilterValue<dynamic>> get valueStream => const Stream.empty();

  FilterValue<dynamic>? get currentValue => null;

  void dispose() {}
}

class FilterValue<TValue> {
  const FilterValue({required this.filter, required this.value});

  final Filter filter;
  final TValue value;
}

abstract class ResultFilter<T> extends Filter {
  const ResultFilter();

  bool matches(T item);
}

abstract class ValueFilter<TValue> extends Filter {
  ValueFilter(TValue initialValue) : valueSubject = DataSubject.seeded(initialValue);

  final DataSubject<TValue> valueSubject;

  TValue get value => valueSubject.value;

  @override
  Stream<FilterValue<TValue>> get valueStream {
    return valueSubject.stream.map((value) => FilterValue(filter: this, value: value));
  }

  @override
  FilterValue<TValue> get currentValue {
    return FilterValue(filter: this, value: value);
  }

  void setValue(TValue value) {
    valueSubject.add(value);
  }

  TValue valueFrom(List<FilterValue<dynamic>> values) {
    return values.where((value) => value.filter == this).single.value as TValue;
  }

  @override
  void dispose() {
    valueSubject.close();
  }
}
