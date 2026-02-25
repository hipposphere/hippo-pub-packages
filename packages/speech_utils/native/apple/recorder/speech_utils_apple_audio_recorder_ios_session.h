#ifndef SPEECH_UTILS_APPLE_AUDIO_RECORDER_IOS_SESSION_H_
#define SPEECH_UTILS_APPLE_AUDIO_RECORDER_IOS_SESSION_H_

#include <cstdint>

namespace speech_utils::apple_recorder {

bool ConfigureIosAudioSession(uint32_t sample_rate_hz, int32_t processing_flags,
                              int32_t apple_session_mode_code,
                              uint32_t apple_category_options_flags,
                              double preferred_latency_seconds,
                              double apple_preferred_io_buffer_duration_seconds,
                              double apple_preferred_input_gain, char* error_utf8,
                              uint32_t error_utf8_capacity);

}  // namespace speech_utils::apple_recorder

#endif  // SPEECH_UTILS_APPLE_AUDIO_RECORDER_IOS_SESSION_H_
