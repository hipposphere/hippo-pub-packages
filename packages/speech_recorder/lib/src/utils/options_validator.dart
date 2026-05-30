import 'package:speech_utils/speech_utils.dart';

import '../models/options.dart';
import '../models/streaming_options.dart';

void validateSpeechRecorderOptions(SpeechRecorderOptions options) {
  if (options.path.trim().isEmpty) {
    throw ArgumentError.value(options.path, 'path', 'Cannot be empty.');
  }

  final recordConfig = options.recordConfig;
  recordConfig.validate();

  final encoder = recordConfig.encoding.encoder;
  if (encoder == AudioEncoder.flac || encoder == AudioEncoder.opus) {
    throw ArgumentError.value(
      encoder,
      'recordConfig.encoding.encoder',
      'Native speech recorder currently supports only '
          'AudioEncoder.aacLc/aacHe/aacEld/wav/pcm16bits.',
    );
  }
}

void validateSpeechRecorderStreamingOptions(
  SpeechRecorderOptions options,
  SpeechRecorderStreamingOptions streamingOptions,
) {
  final recordConfig = options.recordConfig;
  final splitOptions = streamingOptions.resolvePauseSplitOptions(recordConfig);
  splitOptions.validate();
  if (recordConfig.sampleRateHz != splitOptions.sampleRateHz) {
    throw ArgumentError(
      'recordConfig.sampleRateHz (${recordConfig.sampleRateHz}) must match '
      'streamingOptions.pauseSplitOptions.sampleRateHz '
      '(${splitOptions.sampleRateHz}).',
    );
  }
  if (recordConfig.channelCount != splitOptions.channelCount) {
    throw ArgumentError(
      'recordConfig.channelCount (${recordConfig.channelCount}) must match '
      'streamingOptions.pauseSplitOptions.channelCount '
      '(${splitOptions.channelCount}).',
    );
  }

  final encoder = recordConfig.encoding.encoder;
  if (!encoder.supportsSegmentedCaptureOutput) {
    throw ArgumentError.value(
      encoder,
      'recordConfig.encoding.encoder',
      'startStreaming requires an encoder supported by segmented capture output '
          '(AudioEncoder.wav/aacLc/aacHe/aacEld).',
    );
  }
}
