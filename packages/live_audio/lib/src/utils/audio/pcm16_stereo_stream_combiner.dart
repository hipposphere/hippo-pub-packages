import 'dart:async';
import 'dart:typed_data';

import 'pcm16_mono_to_stereo.dart';

final class Pcm16StereoStreamCombiner {
  Pcm16StereoStreamCombiner({required this.leftAudio, required this.rightAudio});

  final Stream<List<int>> leftAudio;
  final Stream<List<int>> rightAudio;

  Stream<Uint8List> get chunks {
    late final StreamController<Uint8List> controller;
    late final StreamSubscription<List<int>> leftSubscription;
    late final StreamSubscription<List<int>> rightSubscription;
    final leftConverter = Pcm16MonoToStereoChannelConverter.left();
    final rightConverter = Pcm16MonoToStereoChannelConverter.right();
    var leftDone = false;
    var rightDone = false;

    void closeIfDone() {
      if (leftDone && rightDone) {
        controller.close();
      }
    }

    controller = StreamController<Uint8List>(
      sync: true,
      onListen: () {
        leftSubscription = leftAudio.listen(
          (chunk) {
            final stereoChunk = leftConverter.convert(Uint8List.fromList(chunk));
            if (stereoChunk.isNotEmpty) {
              controller.add(stereoChunk);
            }
          },
          onError: controller.addError,
          onDone: () {
            leftDone = true;
            closeIfDone();
          },
        );
        rightSubscription = rightAudio.listen(
          (chunk) {
            final stereoChunk = rightConverter.convert(Uint8List.fromList(chunk));
            if (stereoChunk.isNotEmpty) {
              controller.add(stereoChunk);
            }
          },
          onError: controller.addError,
          onDone: () {
            rightDone = true;
            closeIfDone();
          },
        );
      },
      onPause: () {
        leftSubscription.pause();
        rightSubscription.pause();
      },
      onResume: () {
        leftSubscription.resume();
        rightSubscription.resume();
      },
      onCancel: () async {
        await leftSubscription.cancel();
        await rightSubscription.cancel();
      },
    );
    return controller.stream;
  }
}
