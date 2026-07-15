/// Base exception for recorder-specific runtime failures.
class NativeAudioRecorderException implements Exception {
  const NativeAudioRecorderException(this.message, {this.details});

  final String message;
  final String? details;

  @override
  String toString() {
    final detailsText = <String>[
      message,
      if (details != null && details!.isNotEmpty) 'details=$details',
    ];
    return 'NativeAudioRecorderException: ${detailsText.join(' | ')}';
  }
}

final class NativeAudioRecorderUnsupportedPlatformException
    extends NativeAudioRecorderException {
  const NativeAudioRecorderUnsupportedPlatformException(super.message);
}

final class NativeAudioRecorderBusyException
    extends NativeAudioRecorderException {
  const NativeAudioRecorderBusyException(super.message);
}

final class NativeAudioRecorderInvalidStateException
    extends NativeAudioRecorderException {
  const NativeAudioRecorderInvalidStateException(super.message);
}

final class AudioRecorderException extends NativeAudioRecorderException {
  const AudioRecorderException(super.message, {this.errorCode, super.details});

  final int? errorCode;

  @override
  String toString() {
    final detailsText = <String>[
      message,
      if (errorCode != null) 'errorCode=$errorCode',
      if (details != null && details!.isNotEmpty) 'details=$details',
    ];
    return 'AudioRecorderException: ${detailsText.join(' | ')}';
  }
}
