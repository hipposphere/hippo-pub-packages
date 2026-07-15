import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart';
import 'package:speech_utils_core/speech_utils_core.dart';

const _errorBytes = 4096;
const _textBytes = 256;

typedef NativeMetadataHealthcheck =
    int Function(ffi.Pointer<ffi.Char> error, int errorCapacity);

typedef NativeMetadataRead =
    int Function(
      ffi.Pointer<ffi.Char> inputPath,
      ffi.Pointer<ffi.Int64> durationMicros,
      ffi.Pointer<ffi.Int32> sampleRateHz,
      ffi.Pointer<ffi.Int32> channelCount,
      ffi.Pointer<ffi.Int32> bitrateBps,
      ffi.Pointer<ffi.Char> container,
      int containerCapacity,
      ffi.Pointer<ffi.Char> codec,
      int codecCapacity,
      ffi.Pointer<ffi.Char> codecProfile,
      int codecProfileCapacity,
      ffi.Pointer<ffi.Char> error,
      int errorCapacity,
    );

bool runMetadataHealthcheck(NativeMetadataHealthcheck function) {
  final error = calloc<ffi.Char>(_errorBytes);
  try {
    try {
      return function(error, _errorBytes) == 0;
    } on Object {
      return false;
    }
  } finally {
    calloc.free(error);
  }
}

AudioMetadata runMetadataRead(
  NativeMetadataRead function, {
  required String inputPath,
}) {
  final input = inputPath.toNativeUtf8(allocator: calloc).cast<ffi.Char>();
  final duration = calloc<ffi.Int64>();
  final sampleRate = calloc<ffi.Int32>();
  final channels = calloc<ffi.Int32>();
  final bitrate = calloc<ffi.Int32>();
  final container = calloc<ffi.Char>(_textBytes);
  final codec = calloc<ffi.Char>(_textBytes);
  final profile = calloc<ffi.Char>(_textBytes);
  final error = calloc<ffi.Char>(_errorBytes);
  try {
    final code = function(
      input,
      duration,
      sampleRate,
      channels,
      bitrate,
      container,
      _textBytes,
      codec,
      _textBytes,
      profile,
      _textBytes,
      error,
      _errorBytes,
    );
    final details = error.cast<Utf8>().toDartString();
    if (code != 0) {
      throw AudioMetadataException(
        'Native audio metadata read failed',
        errorCode: code,
        details: details.isEmpty ? null : details,
      );
    }
    if (duration.value < 0) {
      throw AudioMetadataException(
        'Native audio metadata returned an invalid duration',
        details: 'durationMicros=${duration.value}',
      );
    }
    return AudioMetadata(
      duration: Duration(microseconds: duration.value),
      sampleRateHz: _positive(sampleRate.value),
      channelCount: _positive(channels.value),
      bitrateBps: _positive(bitrate.value),
      containerFormat: _text(container),
      codec: _text(codec),
      codecProfile: _text(profile),
    );
  } finally {
    calloc.free(input);
    calloc.free(duration);
    calloc.free(sampleRate);
    calloc.free(channels);
    calloc.free(bitrate);
    calloc.free(container);
    calloc.free(codec);
    calloc.free(profile);
    calloc.free(error);
  }
}

int? _positive(int value) => value > 0 ? value : null;

String? _text(ffi.Pointer<ffi.Char> value) {
  final text = value.cast<Utf8>().toDartString().trim();
  return text.isEmpty ? null : text;
}
