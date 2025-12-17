import 'dart:typed_data';

abstract class HidReport {
  int get reportId;
  Uint8List get data;
}

class HidInputReport implements HidReport {
  @override
  final int reportId;

  @override
  final Uint8List data;

  HidInputReport(this.reportId, this.data);
}

class HidOutputReport implements HidReport {
  @override
  final int reportId;

  @override
  final Uint8List data;

  HidOutputReport(this.reportId, this.data);
}

class HidFeatureReport implements HidReport {
  @override
  final int reportId;

  @override
  final Uint8List data;

  HidFeatureReport(this.reportId, this.data);
}
