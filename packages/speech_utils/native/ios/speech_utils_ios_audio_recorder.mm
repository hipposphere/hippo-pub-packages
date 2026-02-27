#include "../apple/speech_utils_apple_audio_recorder_api.h"

extern "C" __attribute__((visibility("default"))) int32_t
speech_utils_ios_audio_recorder_has_permission(int32_t* out_has_permission, char* error_utf8,
                                               uint32_t error_utf8_capacity) {
  return speech_utils::apple_recorder::HasPermission(out_has_permission, error_utf8,
                                                     error_utf8_capacity);
}

extern "C" __attribute__((visibility("default"))) int32_t
speech_utils_ios_audio_recorder_request_permission(int32_t* out_has_permission,
                                                   char* error_utf8,
                                                   uint32_t error_utf8_capacity) {
  return speech_utils::apple_recorder::RequestPermission(out_has_permission, error_utf8,
                                                         error_utf8_capacity);
}

extern "C" __attribute__((visibility("default"))) int32_t
speech_utils_ios_audio_recorder_list_input_devices_json(char* out_json_utf8,
                                                        uint32_t out_json_capacity,
                                                        char* error_utf8,
                                                        uint32_t error_utf8_capacity) {
  return speech_utils::apple_recorder::ListInputDevicesJson(
      out_json_utf8, out_json_capacity, error_utf8, error_utf8_capacity);
}

extern "C" __attribute__((visibility("default"))) int32_t
speech_utils_ios_audio_recorder_start_file(
    const speech_utils::recorder::RecorderStartConfig* start_config,
    char* error_utf8,
    uint32_t error_utf8_capacity) {
  return speech_utils::apple_recorder::StartFile(start_config, error_utf8, error_utf8_capacity);
}

extern "C" __attribute__((visibility("default"))) int32_t
speech_utils_ios_audio_recorder_start_stream(
    const speech_utils::recorder::RecorderStartConfig* start_config,
    char* error_utf8,
    uint32_t error_utf8_capacity) {
  return speech_utils::apple_recorder::StartStream(start_config, error_utf8,
                                                   error_utf8_capacity);
}

extern "C" __attribute__((visibility("default"))) int32_t
speech_utils_ios_audio_recorder_read_stream_pcm16(int16_t* out_samples,
                                                   uint32_t out_sample_capacity,
                                                   uint32_t* out_samples_written,
                                                   char* error_utf8,
                                                   uint32_t error_utf8_capacity) {
  return speech_utils::apple_recorder::ReadStreamPcm16(
      out_samples, out_sample_capacity, out_samples_written, error_utf8, error_utf8_capacity);
}

extern "C" __attribute__((visibility("default"))) int32_t
speech_utils_ios_audio_recorder_stop(char* error_utf8, uint32_t error_utf8_capacity) {
  return speech_utils::apple_recorder::Stop(error_utf8, error_utf8_capacity);
}

extern "C" __attribute__((visibility("default"))) int32_t
speech_utils_ios_audio_recorder_reset(char* error_utf8, uint32_t error_utf8_capacity) {
  return speech_utils::apple_recorder::Reset(error_utf8, error_utf8_capacity);
}

extern "C" __attribute__((visibility("default"))) int32_t
speech_utils_ios_audio_recorder_is_recording(int32_t* out_is_recording, char* error_utf8,
                                             uint32_t error_utf8_capacity) {
  return speech_utils::apple_recorder::IsRecording(out_is_recording, error_utf8,
                                                   error_utf8_capacity);
}

extern "C" __attribute__((visibility("default"))) int32_t
speech_utils_ios_audio_recorder_get_amplitude(double* out_current_dbfs, double* out_max_dbfs,
                                              char* error_utf8,
                                              uint32_t error_utf8_capacity) {
  return speech_utils::apple_recorder::GetAmplitude(out_current_dbfs, out_max_dbfs, error_utf8,
                                                    error_utf8_capacity);
}
