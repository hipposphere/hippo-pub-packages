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
  streamingOptions.pauseSplitOptions.validate();
  if (recordConfig.sampleRateHz !=
      streamingOptions.pauseSplitOptions.sampleRateHz) {
    throw ArgumentError(
      'recordConfig.sampleRateHz (${recordConfig.sampleRateHz}) must match '
      'streamingOptions.pauseSplitOptions.sampleRateHz '
      '(${streamingOptions.pauseSplitOptions.sampleRateHz}).',
    );
  }
  if (recordConfig.channelCount !=
      streamingOptions.pauseSplitOptions.channelCount) {
    throw ArgumentError(
      'recordConfig.channelCount (${recordConfig.channelCount}) must match '
      'streamingOptions.pauseSplitOptions.channelCount '
      '(${streamingOptions.pauseSplitOptions.channelCount}).',
    );
  }

  final encoder = recordConfig.encoding.encoder;
  if (!encoder.supportsVadSegmentationOutput) {
    throw ArgumentError.value(
      encoder,
      'recordConfig.encoding.encoder',
      'startStreaming requires an encoder supported by VAD segmentation output '
          '(AudioEncoder.wav/aacLc/aacHe/aacEld).',
    );
  }
}
