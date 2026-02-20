// ignore_for_file: non_constant_identifier_names

@ffi.DefaultAsset('package:speech_utils/src/recording/generated/macos_audio_recorder_bindings.dart')
library;

import 'dart:ffi' as ffi;

@ffi.Native<ffi.Int32 Function(ffi.Pointer<ffi.Char>, ffi.Uint32)>()
external int speech_utils_macos_audio_recorder_healthcheck(
  ffi.Pointer<ffi.Char> error_utf8,
  int error_utf8_capacity,
);

@ffi.Native<ffi.Int32 Function(ffi.Pointer<ffi.Int32>, ffi.Pointer<ffi.Char>, ffi.Uint32)>()
external int speech_utils_macos_audio_recorder_has_permission(
  ffi.Pointer<ffi.Int32> out_has_permission,
  ffi.Pointer<ffi.Char> error_utf8,
  int error_utf8_capacity,
);

@ffi.Native<ffi.Int32 Function(ffi.Pointer<ffi.Int32>, ffi.Pointer<ffi.Char>, ffi.Uint32)>()
external int speech_utils_macos_audio_recorder_request_permission(
  ffi.Pointer<ffi.Int32> out_has_permission,
  ffi.Pointer<ffi.Char> error_utf8,
  int error_utf8_capacity,
);

@ffi.Native<
  ffi.Int32 Function(
    ffi.Pointer<ffi.Char>,
    ffi.Uint32,
    ffi.Uint32,
    ffi.Pointer<ffi.Char>,
    ffi.Pointer<ffi.Char>,
    ffi.Uint32,
  )
>()
external int speech_utils_macos_audio_recorder_start_file(
  ffi.Pointer<ffi.Char> output_path_utf8,
  int sample_rate_hz,
  int channel_count,
  ffi.Pointer<ffi.Char> input_device_id_utf8,
  ffi.Pointer<ffi.Char> error_utf8,
  int error_utf8_capacity,
);

@ffi.Native<
  ffi.Int32 Function(
    ffi.Uint32,
    ffi.Uint32,
    ffi.Uint32,
    ffi.Pointer<ffi.Char>,
    ffi.Pointer<ffi.Char>,
    ffi.Uint32,
  )
>()
external int speech_utils_macos_audio_recorder_start_stream(
  int sample_rate_hz,
  int channel_count,
  int frames_per_chunk,
  ffi.Pointer<ffi.Char> input_device_id_utf8,
  ffi.Pointer<ffi.Char> error_utf8,
  int error_utf8_capacity,
);

@ffi.Native<
  ffi.Int32 Function(
    ffi.Pointer<ffi.Int16>,
    ffi.Uint32,
    ffi.Pointer<ffi.Uint32>,
    ffi.Pointer<ffi.Char>,
    ffi.Uint32,
  )
>()
external int speech_utils_macos_audio_recorder_read_stream_pcm16(
  ffi.Pointer<ffi.Int16> out_samples,
  int out_sample_capacity,
  ffi.Pointer<ffi.Uint32> out_samples_written,
  ffi.Pointer<ffi.Char> error_utf8,
  int error_utf8_capacity,
);

@ffi.Native<ffi.Int32 Function(ffi.Pointer<ffi.Char>, ffi.Uint32)>()
external int speech_utils_macos_audio_recorder_stop(
  ffi.Pointer<ffi.Char> error_utf8,
  int error_utf8_capacity,
);

@ffi.Native<ffi.Int32 Function(ffi.Pointer<ffi.Int32>, ffi.Pointer<ffi.Char>, ffi.Uint32)>()
external int speech_utils_macos_audio_recorder_is_recording(
  ffi.Pointer<ffi.Int32> out_is_recording,
  ffi.Pointer<ffi.Char> error_utf8,
  int error_utf8_capacity,
);

@ffi.Native<
  ffi.Int32 Function(
    ffi.Pointer<ffi.Double>,
    ffi.Pointer<ffi.Double>,
    ffi.Pointer<ffi.Char>,
    ffi.Uint32,
  )
>()
external int speech_utils_macos_audio_recorder_get_amplitude(
  ffi.Pointer<ffi.Double> out_current_dbfs,
  ffi.Pointer<ffi.Double> out_max_dbfs,
  ffi.Pointer<ffi.Char> error_utf8,
  int error_utf8_capacity,
);

@ffi.Native<
  ffi.Int32 Function(ffi.Pointer<ffi.Char>, ffi.Uint32, ffi.Pointer<ffi.Char>, ffi.Uint32)
>()
external int speech_utils_macos_audio_recorder_list_input_devices_json(
  ffi.Pointer<ffi.Char> out_json_utf8,
  int out_json_capacity,
  ffi.Pointer<ffi.Char> error_utf8,
  int error_utf8_capacity,
);
