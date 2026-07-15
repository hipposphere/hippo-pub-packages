import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

const _sources = <String>[
  'native/ios/speech_utils_native_audio_recorder_impl.mm',
  'native/ios/speech_utils_ios_audio_recorder_session.mm',
  'native/ios/speech_utils_native_audio_recorder_wav.mm',
  'native/ios/speech_utils_native_audio_codec.mm',
  'native/ios/speech_utils_native_audio_codec_bindings.mm',
  'native/ios/speech_utils_ios_audio_recorder.mm',
];

void main(List<String> args) async {
  await build(args, (input, output) async {
    if (!input.config.buildCodeAssets || input.config.code.targetOS != OS.iOS) {
      return;
    }
    for (final source in _sources) {
      output.dependencies.add(input.packageRoot.resolve(source));
    }
    await CBuilder.library(
      name: 'speech_utils_ios_audio_recorder',
      assetName: 'src/generated/ios_audio_recorder_bindings.dart',
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
