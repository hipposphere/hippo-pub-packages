import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';

import 'src/aac_assets.dart';
import 'src/metadata_assets.dart';
import 'src/recorder_assets.dart';
import 'src/ten_vad_assets.dart';

typedef HookBuildStep = Future<void> Function(BuildInput input, BuildOutputBuilder output);

final _buildSteps = <HookBuildStep>[
  bundleTenVadAsset,
    buildWindowsAacEncoderAsset,
    buildAndroidAacEncoderAsset,
    buildIosAacEncoderAsset,
    buildMacosAacEncoderAsset,
    buildIosAudioMetadataAsset,
    buildWindowsAudioRecorderAsset,
    buildIosAudioRecorderAsset,
    buildMacosAudioMetadataAsset,
  buildMacosAudioRecorderAsset,
];

void main(List<String> args) async {
  await build(args, (input, output) async {
    if (!input.config.buildCodeAssets) {
      return;
    }

    for (final step in _buildSteps) {
      await step(input, output);
    }
  });
}
