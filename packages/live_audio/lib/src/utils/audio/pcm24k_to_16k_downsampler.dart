import 'dart:typed_data';

final class Pcm24kTo16kDownsampler {
  final List<int> _pending = <int>[];

  Uint8List convert(Uint8List input) {
    if (input.isEmpty && _pending.isEmpty) {
      return Uint8List(0);
    }

    final combined = Uint8List(_pending.length + input.length)
      ..setAll(0, _pending)
      ..setAll(_pending.length, input);
    final evenLength = combined.length - (combined.length % 2);
    final processLength = (evenLength ~/ 6) * 6;
    if (processLength == 0) {
      _pending
        ..clear()
        ..addAll(combined);
      return Uint8List(0);
    }

    final output = Uint8List((processLength ~/ 6) * 4);
    final inputView = ByteData.sublistView(combined, 0, processLength);
    final outputView = ByteData.sublistView(output);

    var outputOffset = 0;
    for (var inputOffset = 0; inputOffset < processLength; inputOffset += 6) {
      final first = inputView.getInt16(inputOffset, Endian.little);
      final second = inputView.getInt16(inputOffset + 2, Endian.little);
      final third = inputView.getInt16(inputOffset + 4, Endian.little);

      outputView.setInt16(outputOffset, first, Endian.little);
      outputOffset += 2;
      outputView.setInt16(
        outputOffset,
        ((second + third) ~/ 2).clamp(-32768, 32767),
        Endian.little,
      );
      outputOffset += 2;
    }

    _pending
      ..clear()
      ..addAll(combined.sublist(processLength));
    return output;
  }
}
