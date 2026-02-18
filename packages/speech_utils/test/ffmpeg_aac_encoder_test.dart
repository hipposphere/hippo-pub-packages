import 'dart:typed_data';

import 'package:speech_utils/speech_utils.dart';
import 'package:test/test.dart';

void main() {
  group('FfmpegAacEncoder', () {
    test('uses ffmpeg with raw pcm stdin parameters', () async {
      late String usedExecutable;
      late List<String> usedArguments;
      Uint8List? usedStdin;

      final encoder = FfmpegAacEncoder(
        ffmpegExecutable: 'ffmpeg-custom',
        commandRunner: (executable, arguments, {stdinBytes}) async {
          usedExecutable = executable;
          usedArguments = List<String>.from(arguments);
          usedStdin = stdinBytes;
          return const FfmpegCommandResult(exitCode: 0, stderr: '');
        },
      );

      final pcm = Uint8List.fromList(<int>[1, 2, 3, 4]);
      await encoder.encodePcm16BytesToAac(
        pcm16leBytes: pcm,
        sampleRateHz: 16000,
        channelCount: 1,
        outputPath: 'out.m4a',
        bitrateKbps: 56,
      );

      expect(usedExecutable, 'ffmpeg-custom');
      expect(
        usedArguments,
        containsAllInOrder([
          '-f',
          's16le',
          '-ar',
          '16000',
          '-ac',
          '1',
          '-i',
          'pipe:0',
          '-c:a',
          'aac',
          '-b:a',
          '56k',
          'out.m4a',
        ]),
      );
      expect(usedStdin, same(pcm));
    });

    test('throws AacEncodingException on non-zero exit code', () {
      final encoder = FfmpegAacEncoder(
        commandRunner: (executable, arguments, {stdinBytes}) async {
          return const FfmpegCommandResult(exitCode: 1, stderr: 'boom');
        },
      );

      expect(
        () => encoder.encodeAudioFileToAac(inputPath: 'in.wav', outputPath: 'out.m4a'),
        throwsA(isA<AacEncodingException>()),
      );
    });
  });
}
