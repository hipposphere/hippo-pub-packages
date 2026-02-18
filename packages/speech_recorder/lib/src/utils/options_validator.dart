import 'package:record/record.dart' as record;

import '../models/options.dart';

void validateSpeechRecorderOptions(SpeechRecorderOptions options) {
  if (options.path.trim().isEmpty) {
    throw ArgumentError.value(options.path, 'path', 'Cannot be empty.');
  }

  final streamingOptions = options.streaming;
  if (streamingOptions == null) {
    return;
  }

  streamingOptions.pauseSplitOptions.validate();

  if (streamingOptions.bitrateKbps <= 0) {
    throw ArgumentError.value(
      streamingOptions.bitrateKbps,
      'streaming.bitrateKbps',
      'Must be > 0.',
    );
  }
  if (streamingOptions.fileExtension.trim().isEmpty) {
    throw ArgumentError.value(
      streamingOptions.fileExtension,
      'streaming.fileExtension',
      'Cannot be empty.',
    );
  }
  if (streamingOptions.mimeType.trim().isEmpty) {
    throw ArgumentError.value(
      streamingOptions.mimeType,
      'streaming.mimeType',
      'Cannot be empty.',
    );
  }

  final recordConfig = options.recordConfig;
  if (recordConfig.encoder != record.AudioEncoder.pcm16bits) {
    throw ArgumentError.value(
      recordConfig.encoder,
      'recordConfig.encoder',
      'Streaming mode requires AudioEncoder.pcm16bits.',
    );
  }
  if (recordConfig.sampleRate !=
      streamingOptions.pauseSplitOptions.sampleRateHz) {
    throw ArgumentError(
      'recordConfig.sampleRate (${recordConfig.sampleRate}) must match '
      'streaming.pauseSplitOptions.sampleRateHz '
      '(${streamingOptions.pauseSplitOptions.sampleRateHz}).',
    );
  }
  if (recordConfig.numChannels !=
      streamingOptions.pauseSplitOptions.channelCount) {
    throw ArgumentError(
      'recordConfig.numChannels (${recordConfig.numChannels}) must match '
      'streaming.pauseSplitOptions.channelCount '
      '(${streamingOptions.pauseSplitOptions.channelCount}).',
    );
  }
}
