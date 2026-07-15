import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';

import 'src/ten_vad_assets.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    if (input.config.buildCodeAssets) {
      await bundleTenVadAsset(input, output);
    }
  });
}
