#include "recorder/windows_audio_recorder_api.h"

extern "C" __declspec(dllexport) int32_t
speech_utils_windows_audio_recorder_healthcheck(char* error_utf8, uint32_t error_utf8_capacity) {
  return speech_utils::windows_recorder::Healthcheck(error_utf8, error_utf8_capacity);
}

extern "C" __declspec(dllexport) int32_t
speech_utils_windows_audio_recorder_has_permission(int32_t* out_has_permission, char* error_utf8,
                                                   uint32_t error_utf8_capacity) {
  return speech_utils::windows_recorder::HasPermission(out_has_permission, error_utf8,
                                                       error_utf8_capacity);
}

extern "C" __declspec(dllexport) int32_t
speech_utils_windows_audio_recorder_request_permission(int32_t* out_has_permission,
                                                       char* error_utf8,
                                                       uint32_t error_utf8_capacity) {
  return speech_utils::windows_recorder::RequestPermission(out_has_permission, error_utf8,
                                                           error_utf8_capacity);
}

extern "C" __declspec(dllexport) int32_t
speech_utils_windows_audio_recorder_list_input_devices_json(char* out_json_utf8,
                                                            uint32_t out_json_capacity,
                                                            char* error_utf8,
                                                            uint32_t error_utf8_capacity) {
  return speech_utils::windows_recorder::ListInputDevicesJson(
      out_json_utf8, out_json_capacity, error_utf8, error_utf8_capacity);
}

extern "C" __declspec(dllexport) int32_t
speech_utils_windows_audio_recorder_start_file(const char* output_path_utf8, uint32_t sample_rate_hz,
                                               uint32_t channel_count,
                                               const char* input_device_id_utf8,
                                               char* error_utf8,
                                               uint32_t error_utf8_capacity) {
  return speech_utils::windows_recorder::StartFile(output_path_utf8, sample_rate_hz, channel_count,
                                                   input_device_id_utf8, error_utf8,
                                                   error_utf8_capacity);
}

extern "C" __declspec(dllexport) int32_t
speech_utils_windows_audio_recorder_start_stream(uint32_t sample_rate_hz, uint32_t channel_count,
                                                 uint32_t frames_per_chunk,
                                                 const char* input_device_id_utf8,
                                                 char* error_utf8,
                                                 uint32_t error_utf8_capacity) {
  return speech_utils::windows_recorder::StartStream(sample_rate_hz, channel_count, frames_per_chunk,
                                                     input_device_id_utf8, error_utf8,
                                                     error_utf8_capacity);
}

extern "C" __declspec(dllexport) int32_t
speech_utils_windows_audio_recorder_read_stream_pcm16(int16_t* out_samples,
                                                       uint32_t out_sample_capacity,
                                                       uint32_t* out_samples_written,
                                                       char* error_utf8,
                                                       uint32_t error_utf8_capacity) {
  return speech_utils::windows_recorder::ReadStreamPcm16(
      out_samples, out_sample_capacity, out_samples_written, error_utf8, error_utf8_capacity);
}

extern "C" __declspec(dllexport) int32_t
speech_utils_windows_audio_recorder_stop(char* error_utf8, uint32_t error_utf8_capacity) {
  return speech_utils::windows_recorder::Stop(error_utf8, error_utf8_capacity);
}

extern "C" __declspec(dllexport) int32_t
speech_utils_windows_audio_recorder_is_recording(int32_t* out_is_recording, char* error_utf8,
                                                 uint32_t error_utf8_capacity) {
  return speech_utils::windows_recorder::IsRecording(out_is_recording, error_utf8,
                                                     error_utf8_capacity);
}

extern "C" __declspec(dllexport) int32_t
speech_utils_windows_audio_recorder_get_amplitude(double* out_current_dbfs, double* out_max_dbfs,
                                                  char* error_utf8,
                                                  uint32_t error_utf8_capacity) {
  return speech_utils::windows_recorder::GetAmplitude(out_current_dbfs, out_max_dbfs, error_utf8,
                                                      error_utf8_capacity);
}
