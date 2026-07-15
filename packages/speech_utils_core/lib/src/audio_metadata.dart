final class AudioMetadata {
  const AudioMetadata({
    required this.duration,
    this.sampleRateHz,
    this.channelCount,
    this.bitrateBps,
    this.containerFormat,
    this.codec,
    this.codecProfile,
  });

  final Duration duration;
  final int? sampleRateHz;
  final int? channelCount;
  final int? bitrateBps;
  final String? containerFormat;
  final String? codec;
  final String? codecProfile;
}

class NativeAudioMetadataReaderException implements Exception {
  const NativeAudioMetadataReaderException(this.message, {this.details});

  final String message;
  final String? details;

  @override
  String toString() {
    final values = <String>[
      message,
      if (details != null && details!.isNotEmpty) 'details=$details',
    ];
    return 'NativeAudioMetadataReaderException: ${values.join(' | ')}';
  }
}

final class NativeAudioMetadataUnsupportedPlatformException
    extends NativeAudioMetadataReaderException {
  const NativeAudioMetadataUnsupportedPlatformException(super.message);
}

final class AudioMetadataException extends NativeAudioMetadataReaderException {
  const AudioMetadataException(super.message, {this.errorCode, super.details});

  final int? errorCode;

  @override
  String toString() {
    final values = <String>[
      message,
      if (errorCode != null) 'errorCode=$errorCode',
      if (details != null && details!.isNotEmpty) 'details=$details',
    ];
    return 'AudioMetadataException: ${values.join(' | ')}';
  }
}
