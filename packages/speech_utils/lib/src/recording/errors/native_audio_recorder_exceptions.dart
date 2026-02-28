part of '../native_audio_recorder.dart';

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

/// Thrown when recorder operations are requested on an unsupported platform.
final class NativeAudioRecorderUnsupportedPlatformException
    extends NativeAudioRecorderException {
  const NativeAudioRecorderUnsupportedPlatformException(super.message);
}

/// Thrown when starting a recording while another recording is still active.
final class NativeAudioRecorderBusyException extends NativeAudioRecorderException {
  const NativeAudioRecorderBusyException(super.message);
}

/// Thrown when recorder internal state cannot satisfy the requested operation.
final class NativeAudioRecorderInvalidStateException extends NativeAudioRecorderException {
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
