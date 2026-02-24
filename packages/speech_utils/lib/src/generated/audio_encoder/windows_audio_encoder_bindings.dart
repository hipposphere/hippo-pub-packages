// ignore_for_file: non_constant_identifier_names

@ffi.DefaultAsset('package:speech_utils/src/generated/audio_encoder/windows_audio_encoder_bindings.dart')
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
external int speech_utils_windows_encode_audio_file_to_aac(
  ffi.Pointer<ffi.Char> input_path_utf8,
  ffi.Pointer<ffi.Char> output_path_utf8,
  int bitrate_bps,
  ffi.Pointer<ffi.Char> error_utf8,
  int error_utf8_capacity,
);

@ffi.Native<ffi.Int32 Function(ffi.Pointer<ffi.Char>, ffi.Uint32)>()
external int speech_utils_windows_aac_encoder_healthcheck(
  ffi.Pointer<ffi.Char> error_utf8,
  int error_utf8_capacity,
);

@ffi.Native<
  ffi.Int32 Function(
    ffi.Pointer<ffi.Char>,
    ffi.Pointer<ffi.Int64>,
    ffi.Pointer<ffi.Int32>,
    ffi.Pointer<ffi.Int32>,
    ffi.Pointer<ffi.Int32>,
    ffi.Pointer<ffi.Char>,
    ffi.Uint32,
    ffi.Pointer<ffi.Char>,
    ffi.Uint32,
    ffi.Pointer<ffi.Char>,
    ffi.Uint32,
    ffi.Pointer<ffi.Char>,
    ffi.Uint32,
  )
>()
external int speech_utils_windows_read_audio_metadata(
  ffi.Pointer<ffi.Char> input_path_utf8,
  ffi.Pointer<ffi.Int64> out_duration_micros,
  ffi.Pointer<ffi.Int32> out_sample_rate_hz,
  ffi.Pointer<ffi.Int32> out_channel_count,
  ffi.Pointer<ffi.Int32> out_bitrate_bps,
  ffi.Pointer<ffi.Char> out_container_format_utf8,
  int out_container_format_utf8_capacity,
  ffi.Pointer<ffi.Char> out_codec_utf8,
  int out_codec_utf8_capacity,
  ffi.Pointer<ffi.Char> out_codec_profile_utf8,
  int out_codec_profile_utf8_capacity,
  ffi.Pointer<ffi.Char> error_utf8,
  int error_utf8_capacity,
);

@ffi.Native<ffi.Int32 Function(ffi.Pointer<ffi.Char>, ffi.Uint32)>()
external int speech_utils_windows_audio_metadata_healthcheck(
  ffi.Pointer<ffi.Char> error_utf8,
  int error_utf8_capacity,
);
