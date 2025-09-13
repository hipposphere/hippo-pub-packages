/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited 
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
import 'package:hippo_utils/rxdart.dart';

extension IterableStreamIterableExtensions<T> on Iterable<Stream<List<T>>> {
  Stream<List<T>> flattenAndExpand() {
    return flatten().map((list) => list.expand((e) => e).toList());
  }
}

extension IterableStreamExtension<T> on Iterable<Stream<T>> {
  Stream<List<T>> flatten() {
    return Rx.combineLatest(this, (e) => e);
  }
}
