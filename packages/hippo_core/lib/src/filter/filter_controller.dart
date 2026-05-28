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
import 'package:hippo_core/src/filter/filter.dart';

abstract class FilterController<T> {
  FilterController({required Iterable<T> items, Iterable<Filter> filters = const []})
    : dataSubject = DataSubject.seeded(List.unmodifiable(items)),
      filters = List.unmodifiable(filters),
      filteredDataSubject = DataSubject<List<T>>.empty(),
      _ownsDataSubject = true,
      _itemsFetcher = null {
    _syncFilterValueSubscriptions();
    applyFilter();
  }

  FilterController.fromSubject({
    required this.dataSubject,
    Iterable<Filter> filters = const [],
    bool closeDataSubjectOnDispose = false,
  }) : filters = List.unmodifiable(filters),
       filteredDataSubject = DataSubject<List<T>>.empty(),
       _ownsDataSubject = closeDataSubjectOnDispose,
       _itemsFetcher = null {
    _dataSubscription = dataSubject.listen((_) => applyFilter());
    _syncFilterValueSubscriptions();
    applyFilter();
  }

  FilterController.fetched({
    required FilterItemsFetcher<T> fetcher,
    Iterable<Filter> filters = const [],
  }) : dataSubject = DataSubject.seeded(const []),
       filters = List.unmodifiable(filters),
       filteredDataSubject = DataSubject<List<T>>.empty(),
       _ownsDataSubject = true,
       _itemsFetcher = fetcher {
    applyFilter();
    _syncFilterValueSubscriptions();
    refresh();
  }

  final DataSubject<List<T>> dataSubject;
  final List<Filter> filters;
  final DataSubject<List<T>> filteredDataSubject;
  final bool _ownsDataSubject;
  final FilterItemsFetcher<T>? _itemsFetcher;

  StreamSubscription<List<T>>? _dataSubscription;
  final _filterValueSubscriptions = <StreamSubscription<dynamic>>[];
  var _refreshVersion = 0;

  List<T> get data => dataSubject.value;

  Iterable<ResultFilter<T>> get resultFilters => filters.whereType<ResultFilter<T>>();

  List<FilterValue<dynamic>> get filterValues {
    return [for (final filter in filters) ?filter.currentValue];
  }

  List<T> get filteredData => filteredDataSubject.value;

  void setData(Iterable<T> data) {
    dataSubject.add(List.unmodifiable(data));
    applyFilter();
  }

  Future<void> refresh() async {
    final fetcher = _itemsFetcher;
    if (fetcher == null) {
      applyFilter();
      return;
    }

    final refreshVersion = ++_refreshVersion;
    final data = await fetcher(filterValues);
    if (refreshVersion != _refreshVersion || dataSubject.isClosed) {
      return;
    }
    dataSubject.add(List.unmodifiable(data));
    applyFilter();
  }

  void applyFilter() {
    filteredDataSubject.add(
      List.unmodifiable(
        dataSubject.value.where((item) => resultFilters.every((filter) => filter.matches(item))),
      ),
    );
  }

  void _syncFilterValueSubscriptions() {
    _cancelFilterValueSubscriptions();

    for (final filter in filters) {
      var isInitialEvent = true;
      final subscription = filter.valueStream.listen((_) {
        if (isInitialEvent) {
          isInitialEvent = false;
          return;
        }
        refresh();
      });
      _filterValueSubscriptions.add(subscription);
    }
  }

  void _cancelFilterValueSubscriptions() {
    for (final subscription in _filterValueSubscriptions) {
      unawaited(subscription.cancel());
    }
    _filterValueSubscriptions.clear();
  }

  void dispose() {
    final dataSubscription = _dataSubscription;
    if (dataSubscription != null) {
      unawaited(dataSubscription.cancel());
    }
    _cancelFilterValueSubscriptions();
    if (_ownsDataSubject) {
      dataSubject.close();
    }
    filteredDataSubject.close();
    for (final filter in filters) {
      filter.dispose();
    }
  }
}
