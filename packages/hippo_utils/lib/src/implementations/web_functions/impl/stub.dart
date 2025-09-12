import '../models/web_functions_abstraction.dart';

class WebFunctionsImpl implements WebFunctionsAbstraction {
  @override
  Future<void> reload() {
    throw UnimplementedError();
  }

  @override
  Future<void> clearCacheStorageAndReload() {
    throw UnimplementedError();
  }

  @override
  void setPathUrlStrategy() {}
}
