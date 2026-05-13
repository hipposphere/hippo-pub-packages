int? audioRateFromMimeType(String mimeType) {
  final match = RegExp(r'rate=(\d+)').firstMatch(mimeType);
  return match == null ? null : int.tryParse(match.group(1)!);
}
