import 'dart:typed_data';

/// Type of HID report
enum HidReportType {
  /// Output report (device receives data from host)
  output,

  /// Feature report (bidirectional configuration/control data)
  feature,
}

/// Represents a HID report with a report ID and data payload.
///
/// Used for all HID report types (input, output, and feature reports).
class HidReport {
  final int reportId;
  final Uint8List data;

  HidReport(this.reportId, this.data);

  /// Returns the report data normalized for cross-platform consistency.
  ///
  /// On some platforms (notably macOS), HID reports may include a leading
  /// 0x00 padding byte that other platforms (Windows) don't include.
  /// This getter detects this pattern and returns the data without the
  /// padding byte when detected, ensuring consistent parsing across platforms.
  ///
  /// The detection heuristic:
  /// - If byte 0 is 0x00 and data has more than 1 byte
  /// - And byte 1 is non-zero (actual data starts there)
  /// - Then strip the leading byte
  ///
  /// If no padding is detected, returns the original data unchanged.
  Uint8List get normalizedData {
    if (data.length > 1 && data[0] == 0x00 && data[1] != 0x00) {
      // Strip the leading padding byte
      return Uint8List.sublistView(data, 1);
    }
    return data;
  }

  /// Returns the byte offset where actual data begins in the raw [data].
  ///
  /// Returns 1 if a leading padding byte was detected, 0 otherwise.
  /// This can be used when you need to work with the raw data but need
  /// to know the correct offset.
  int get dataOffset {
    if (data.length > 1 && data[0] == 0x00 && data[1] != 0x00) {
      return 1;
    }
    return 0;
  }
}
