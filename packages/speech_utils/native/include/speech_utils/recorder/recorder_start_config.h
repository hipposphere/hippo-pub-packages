#ifndef SPEECH_UTILS_RECORDER_START_CONFIG_H_
#define SPEECH_UTILS_RECORDER_START_CONFIG_H_

#include <cstdint>

namespace speech_utils::recorder {

struct RecorderRuntimeConfig {
  int32_t processing_flags;
  int32_t apple_session_mode_code;
  uint32_t apple_category_options_flags;
  double preferred_latency_seconds;
  double apple_preferred_io_buffer_duration_seconds;
  double apple_preferred_input_gain;
  uint32_t windows_preferred_period_frames;
  uint32_t windows_flags;
  int32_t windows_capture_category_code;
  int32_t windows_use_communications_device;
};

struct RecorderStartConfig {
  uint32_t sample_rate_hz;
  uint32_t channel_count;
  uint32_t frames_per_chunk;
  const char* output_path_utf8;
  const char* input_device_id_utf8;
  RecorderRuntimeConfig runtime;
};

}  // namespace speech_utils::recorder

#endif  // SPEECH_UTILS_RECORDER_START_CONFIG_H_
