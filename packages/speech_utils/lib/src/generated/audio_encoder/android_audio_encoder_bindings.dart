// ignore_for_file: non_constant_identifier_names

@ffi.DefaultAsset(
  'package:speech_utils/src/generated/audio_encoder/android_audio_encoder_bindings.dart',
)
library;

import 'dart:ffi' as ffi;

@ffi.Native<
  ffi.Int32 Function(
    ffi.Pointer<ffi.Char>,
    ffi.Pointer<ffi.Char>,
    ffi.Uint32,
    ffi.Pointer<ffi.Int64>,
    ffi.Pointer<ffi.Char>,
    ffi.Uint32,
  )
>()
external int speech_utils_android_start_async_encode_wav_file_to_aac_m4a(
  ffi.Pointer<ffi.Char> input_path_utf8,
  ffi.Pointer<ffi.Char> output_path_utf8,
  int bitrate_bps,
  ffi.Pointer<ffi.Int64> out_task_handle,
  ffi.Pointer<ffi.Char> error_utf8,
  int error_utf8_capacity,
);

@ffi.Native<
  ffi.Int32 Function(
    ffi.Int64,
    ffi.Pointer<ffi.Int32>,
    ffi.Pointer<ffi.Int32>,
    ffi.Pointer<ffi.Char>,
    ffi.Uint32,
  )
>()
external int speech_utils_android_get_async_encode_wav_file_to_aac_m4a_status(
  int task_handle,
  ffi.Pointer<ffi.Int32> out_done,
  ffi.Pointer<ffi.Int32> out_result_code,
  ffi.Pointer<ffi.Char> out_error_utf8,
  int out_error_utf8_capacity,
);

@ffi.Native<ffi.Int32 Function(ffi.Int64, ffi.Pointer<ffi.Char>, ffi.Uint32)>()
external int speech_utils_android_dispose_async_encode_wav_file_to_aac_m4a(
  int task_handle,
  ffi.Pointer<ffi.Char> out_error_utf8,
  int out_error_utf8_capacity,
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
external int speech_utils_android_encode_wav_file_to_aac_m4a(
  ffi.Pointer<ffi.Char> input_path_utf8,
  ffi.Pointer<ffi.Char> output_path_utf8,
  int bitrate_bps,
  ffi.Pointer<ffi.Char> error_utf8,
  int error_utf8_capacity,
);

@ffi.Native<ffi.Int32 Function(ffi.Pointer<ffi.Char>, ffi.Uint32)>()
external int speech_utils_android_aac_encoder_healthcheck(
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
external int speech_utils_android_read_audio_metadata(
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
external int speech_utils_android_audio_metadata_healthcheck(
  ffi.Pointer<ffi.Char> error_utf8,
  int error_utf8_capacity,
);
