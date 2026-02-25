#import "speech_utils_apple_audio_recorder_ios_session.h"

#import <TargetConditionals.h>
#import <AVFoundation/AVFoundation.h>

#include <cmath>

#include "speech_utils_apple_audio_recorder_common_internal.h"

namespace speech_utils::apple_recorder {

bool ConfigureIosAudioSession(uint32_t sample_rate_hz, int32_t processing_flags,
                              int32_t apple_session_mode_code,
                              uint32_t apple_category_options_flags,
                              double preferred_latency_seconds,
                              double apple_preferred_io_buffer_duration_seconds,
                              double apple_preferred_input_gain, char* error_utf8,
                              uint32_t error_utf8_capacity) {
#if TARGET_OS_IPHONE
  AVAudioSession* audio_session = [AVAudioSession sharedInstance];
  NSError* session_error = nil;
  NSString* mode = ResolveAppleSessionMode(apple_session_mode_code, processing_flags);
  const AVAudioSessionCategoryOptions options =
      ResolveAppleCategoryOptions(apple_category_options_flags);
  if (![audio_session setCategory:AVAudioSessionCategoryPlayAndRecord
                         mode:mode
                      options:options
                        error:&session_error]) {
    WriteNSError(session_error, "Failed to configure AVAudioSession category", error_utf8,
                 error_utf8_capacity);
    return false;
  }

  if (apple_preferred_io_buffer_duration_seconds > 0.0) {
    [audio_session setPreferredIOBufferDuration:apple_preferred_io_buffer_duration_seconds
                                          error:nil];
  } else if (preferred_latency_seconds > 0.0) {
    [audio_session setPreferredIOBufferDuration:preferred_latency_seconds error:nil];
  }

  [audio_session setPreferredSampleRate:static_cast<double>(sample_rate_hz) error:nil];

  if (std::isfinite(apple_preferred_input_gain) && apple_preferred_input_gain >= 0.0 &&
      apple_preferred_input_gain <= 1.0 && audio_session.inputGainSettable) {
    [audio_session setInputGain:static_cast<float>(apple_preferred_input_gain) error:nil];
  }

  if (![audio_session setActive:YES error:&session_error]) {
    WriteNSError(session_error, "Failed to activate AVAudioSession", error_utf8,
                 error_utf8_capacity);
    return false;
  }
  return true;
#else
  (void)sample_rate_hz;
  (void)processing_flags;
  (void)apple_session_mode_code;
  (void)apple_category_options_flags;
  (void)preferred_latency_seconds;
  (void)apple_preferred_io_buffer_duration_seconds;
  (void)apple_preferred_input_gain;
  (void)error_utf8;
  (void)error_utf8_capacity;
  return true;
#endif
}

}  // namespace speech_utils::apple_recorder
