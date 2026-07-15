import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

const _assetName = 'src/generated/macos_audio_recorder_bindings.dart';
const _sources = <String>[
  'native/macos/speech_utils_native_audio_recorder_impl.mm',
  'native/macos/speech_utils_native_audio_recorder_wav.mm',
  'native/macos/speech_utils_native_audio_codec.mm',
  'native/macos/speech_utils_native_audio_codec_bindings.mm',
  'native/macos/speech_utils_macos_audio_recorder.mm',
];

void main(List<String> args) async {
  await build(args, (input, output) async {
    if (!input.config.buildCodeAssets ||
        input.config.code.targetOS != OS.macOS) {
      return;
    }

    for (final source in _sources) {
      output.dependencies.add(input.packageRoot.resolve(source));
    }
    await CBuilder.library(
      name: 'speech_utils_macos_audio_recorder',
      assetName: _assetName,
      language: Language.objectiveC,
      sources: _sources,
      includes: const ['native/include'],
      std: 'c++17',
      flags: const ['-fobjc-arc'],
      frameworks: const [
        'Foundation',
        'AVFoundation',
        'CoreMedia',
        'AudioToolbox',
      ],
      libraries: const ['c++'],
    ).run(input: input, output: output);
  });
}
