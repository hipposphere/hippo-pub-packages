// ignore_for_file: non_constant_identifier_names

@ffi.DefaultAsset(
  'package:speech_utils_macos/src/generated/macos_audio_recorder_bindings.dart',
)
library;

import 'dart:ffi' as ffi;

@ffi.Native<
  ffi.Int32 Function(
    ffi.Pointer<ffi.Char>,
    ffi.Pointer<ffi.Char>,
    ffi.Uint32,
    ffi.Pointer<ffi.Char>,
    ffi.Uint32,
  )
>()
external int speech_utils_ios_encode_audio_file_to_aac(
  ffi.Pointer<ffi.Char> input_path_utf8,
  ffi.Pointer<ffi.Char> output_path_utf8,
  int bitrate_bps,
  ffi.Pointer<ffi.Char> error_utf8,
  int error_utf8_capacity,
);

@ffi.Native<
  ffi.Int32 Function(
    ffi.Pointer<ffi.Char>,
    ffi.Pointer<ffi.Char>,
    ffi.Uint32,
    ffi.Pointer<ffi.Char>,
    ffi.Uint32,
  )
>()
external int speech_utils_macos_encode_audio_file_to_aac(
  ffi.Pointer<ffi.Char> input_path_utf8,
  ffi.Pointer<ffi.Char> output_path_utf8,
  int bitrate_bps,
  ffi.Pointer<ffi.Char> error_utf8,
  int error_utf8_capacity,
);
