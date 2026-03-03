#ifndef SPEECH_UTILS_IOS_AUDIO_RECORDER_SESSION_H_
#define SPEECH_UTILS_IOS_AUDIO_RECORDER_SESSION_H_

#import <AVFoundation/AVFoundation.h>

#include <cstdint>

@class NSString;

namespace speech_utils::native_recorder {

bool ConfigureIosRecorderSession(uint32_t sample_rate_hz, int32_t processing_flags,
                                 int32_t ios_session_mode_code,
                                 uint32_t ios_category_options_flags,
                                 double preferred_latency_seconds,
                                 double ios_preferred_io_buffer_duration_seconds,
                                 double ios_preferred_input_gain, char* error_utf8,
                                 uint32_t error_utf8_capacity);

bool SelectIosInputDeviceByUid(NSString* input_uid, char* error_utf8,
                               uint32_t error_utf8_capacity);

}  // namespace speech_utils::native_recorder

#endif  // SPEECH_UTILS_IOS_AUDIO_RECORDER_SESSION_H_
