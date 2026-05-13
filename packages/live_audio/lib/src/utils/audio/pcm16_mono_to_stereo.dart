import 'dart:typed_data';

enum Pcm16StereoChannel { left, right }

final class Pcm16MonoToStereoChannelConverter {
  Pcm16MonoToStereoChannelConverter(this.channel);

  Pcm16MonoToStereoChannelConverter.left() : channel = Pcm16StereoChannel.left;

  Pcm16MonoToStereoChannelConverter.right() : channel = Pcm16StereoChannel.right;

  final Pcm16StereoChannel channel;
  int? _pendingByte;

  Uint8List convert(Uint8List input) {
    if (input.isEmpty && _pendingByte == null) {
      return Uint8List(0);
    }

    final hasPending = _pendingByte != null;
    final combined = Uint8List(input.length + (hasPending ? 1 : 0));
    var inputOffset = 0;
    if (hasPending) {
      combined[0] = _pendingByte!;
      inputOffset = 1;
      _pendingByte = null;
    }
    combined.setAll(inputOffset, input);

    final processLength = combined.length - (combined.length % 2);
    if (processLength != combined.length) {
      _pendingByte = combined.last;
    }
    if (processLength == 0) {
      return Uint8List(0);
    }

    final output = Uint8List(processLength * 2);
    final writeLeft = channel == Pcm16StereoChannel.left;
    for (var inputIndex = 0, outputIndex = 0; inputIndex < processLength;) {
      final low = combined[inputIndex++];
      final high = combined[inputIndex++];
      if (writeLeft) {
        output[outputIndex++] = low;
        output[outputIndex++] = high;
        outputIndex += 2;
      } else {
        outputIndex += 2;
        output[outputIndex++] = low;
        output[outputIndex++] = high;
      }
    }
    return output;
  }
}
