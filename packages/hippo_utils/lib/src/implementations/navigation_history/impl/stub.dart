void addWebHistoryElementImplementation(String title, String tag) {}

String? getCurrentWindowLocation() {
  return null;
}

String buildBaseUrl() {
  final uri = Uri.parse(getCurrentWindowLocation()!);
  return uri.origin;
}

void forceRefreshPage() {}
