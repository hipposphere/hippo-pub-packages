import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';

import 'src/audio_encoder_assets.dart';
import 'src/recorder_assets.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    if (!input.config.buildCodeAssets) {
      return;
    }
    await buildLinuxAudioRecorderAsset(input, output);
    await buildLinuxAudioEncoderAsset(input, output);
  });
}
