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
