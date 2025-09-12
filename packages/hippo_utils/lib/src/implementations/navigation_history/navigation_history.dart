import 'impl/stub.dart' if (dart.library.js_interop) 'impl/web.dart' as impl;

void addWebNavigationHistory(String title, String tag) {
  impl.addWebHistoryElementImplementation(title, tag);
}

String buildBaseUrl() {
  return impl.buildBaseUrl();
}

String? getCurrentWindowLocation() {
  return impl.getCurrentWindowLocation();
}
