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

import 'package:hippo_core/hippo_core.dart' as core;

typedef TextFilterPredicate<T> = bool Function(T item, String query);

class TextSearchResultFilter<T> extends core.ResultFilter<T> {
  TextSearchResultFilter({required this.matchesQuery, String initialQuery = ''})
    : querySubject = core.DataSubject.seeded(initialQuery);

  final TextFilterPredicate<T> matchesQuery;
  final core.DataSubject<String> querySubject;

  String get query => querySubject.value;

  @override
  Stream<core.FilterValue<String>> get valueStream {
    return querySubject.stream.map((query) => core.FilterValue(filter: this, value: query));
  }

  @override
  core.FilterValue<String> get currentValue {
    return core.FilterValue(filter: this, value: query);
  }

  void setQuery(String query) {
    querySubject.add(query);
  }

  void clearQuery() {
    setQuery('');
  }

  @override
  bool matches(T item) {
    final query = this.query;
    return query.isEmpty || matchesQuery(item, query);
  }

  @override
  void dispose() {
    querySubject.close();
  }
}

class TextSearchValueFilter extends core.ValueFilter<String> {
  TextSearchValueFilter([super.initialValue = '']);

  String get query => value;

  void setQuery(String query) {
    setValue(query);
  }

  void clearQuery() {
    setQuery('');
  }
}
