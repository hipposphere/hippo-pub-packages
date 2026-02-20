import 'package:speech_utils/speech_utils.dart';

import '../models/options.dart';

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

  final streamingOptions = options.streaming;
  if (streamingOptions == null) {
    return;
  }

  streamingOptions.pauseSplitOptions.validate();
  if (recordConfig.sampleRateHz !=
      streamingOptions.pauseSplitOptions.sampleRateHz) {
    throw ArgumentError(
      'recordConfig.sampleRateHz (${recordConfig.sampleRateHz}) must match '
      'streaming.pauseSplitOptions.sampleRateHz '
      '(${streamingOptions.pauseSplitOptions.sampleRateHz}).',
    );
  }
  if (recordConfig.channelCount !=
      streamingOptions.pauseSplitOptions.channelCount) {
    throw ArgumentError(
      'recordConfig.channelCount (${recordConfig.channelCount}) must match '
      'streaming.pauseSplitOptions.channelCount '
      '(${streamingOptions.pauseSplitOptions.channelCount}).',
    );
  }

  if (!encoder.supportsVadSegmentationOutput) {
    throw ArgumentError.value(
      encoder,
      'recordConfig.encoding.encoder',
      'Streaming mode requires an encoder supported by VAD segmentation output '
          '(AudioEncoder.wav/aacLc/aacHe/aacEld).',
    );
  }
}
