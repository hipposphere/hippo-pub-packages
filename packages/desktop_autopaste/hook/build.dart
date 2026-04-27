import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';

import 'src/desktop_autopaste_assets.dart';

typedef HookBuildStep =
    Future<void> Function(BuildInput input, BuildOutputBuilder output);

final _buildSteps = <HookBuildStep>[
  buildDesktopAutopasteWindowsAsset,
  buildDesktopAutopasteMacosAsset,
  buildDesktopAutopasteLinuxAsset,
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
