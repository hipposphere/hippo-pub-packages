import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';

import 'src/aac_assets.dart';
import 'src/metadata_assets.dart';
import 'src/recorder_assets.dart';
import 'src/ten_vad_assets.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    if (!input.config.buildCodeAssets) {
      return;
    }

    await bundleTenVadAsset(input, output);
    await buildWindowsAacEncoderAsset(input, output);
    await buildAndroidAacEncoderAsset(input, output);
    await buildIosAacEncoderAsset(input, output);
    await buildMacosAacEncoderAsset(input, output);
    await buildWindowsAudioRecorderAsset(input, output);
    await buildIosAudioRecorderAsset(input, output);
    await buildMacosAudioMetadataAsset(input, output);
    await buildMacosAudioRecorderAsset(input, output);
  });
}
