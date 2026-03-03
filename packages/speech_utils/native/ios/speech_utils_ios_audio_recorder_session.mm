#import "speech_utils_ios_audio_recorder_session.h"

#import <AVFoundation/AVFoundation.h>

#include <algorithm>
#include <cmath>

#import "speech_utils_native_audio_recorder_common.h"

namespace speech_utils::native_recorder {

bool ConfigureIosRecorderSession(uint32_t sample_rate_hz, int32_t processing_flags,
                                 int32_t ios_session_mode_code,
                                 uint32_t ios_category_options_flags,
                                 double preferred_latency_seconds,
                                 double ios_preferred_io_buffer_duration_seconds,
                                 double ios_preferred_input_gain, char* error_utf8,
                                 uint32_t error_utf8_capacity) {
  AVAudioSession* audio_session = AVAudioSession.sharedInstance;
  NSError* session_error = nil;

  const AVAudioSessionCategoryOptions category_options =
      ResolveIosCategoryOptions(ios_category_options_flags);
  NSString* session_mode = ResolveIosSessionMode(ios_session_mode_code, processing_flags);

  if (![audio_session setCategory:AVAudioSessionCategoryPlayAndRecord
                             mode:session_mode
                          options:category_options
                            error:&session_error]) {
    WriteNSError(session_error, "Failed to configure AVAudioSession category", error_utf8,
                 error_utf8_capacity);
    return false;
  }

  if (sample_rate_hz > 0) {
    const double preferred_sample_rate =
        std::min<double>(static_cast<double>(sample_rate_hz), 48000.0);
    [audio_session setPreferredSampleRate:preferred_sample_rate error:nil];
  }

  const double io_buffer_duration =
      ios_preferred_io_buffer_duration_seconds > 0.0
          ? ios_preferred_io_buffer_duration_seconds
          : preferred_latency_seconds;
  if (io_buffer_duration > 0.0) {
    [audio_session setPreferredIOBufferDuration:io_buffer_duration error:nil];
  }

  if (std::isfinite(ios_preferred_input_gain) && ios_preferred_input_gain >= 0.0 &&
      ios_preferred_input_gain <= 1.0 && audio_session.inputGainSettable) {
    [audio_session setInputGain:static_cast<float>(ios_preferred_input_gain) error:nil];
  }

  if (![audio_session setActive:YES error:&session_error]) {
    WriteNSError(session_error, "Failed to activate AVAudioSession", error_utf8,
                 error_utf8_capacity);
    return false;
  }

  return true;
}

bool SelectIosInputDeviceByUid(NSString* input_uid, char* error_utf8,
                               uint32_t error_utf8_capacity) {
  if (input_uid == nil || input_uid.length == 0) {
    AVAudioSession* audio_session = AVAudioSession.sharedInstance;
    NSError* session_error = nil;
    if (![audio_session setPreferredInput:nil error:&session_error]) {
      WriteNSError(session_error, "Failed to clear preferred iOS input device", error_utf8,
                   error_utf8_capacity);
      return false;
    }
    return true;
  }

  AVAudioSession* audio_session = AVAudioSession.sharedInstance;
  NSArray<AVAudioSessionPortDescription*>* available_inputs = audio_session.availableInputs;

  AVAudioSessionPortDescription* selected_input = nil;
  for (AVAudioSessionPortDescription* input in available_inputs) {
    if ([input.UID isEqualToString:input_uid]) {
      selected_input = input;
      break;
    }
  }

  if (selected_input == nil) {
    WriteError("Selected iOS input device is not available.", error_utf8, error_utf8_capacity);
    return false;
  }

  NSError* session_error = nil;
  if (![audio_session setPreferredInput:selected_input error:&session_error]) {
    WriteNSError(session_error, "Failed to set preferred iOS input device", error_utf8,
                 error_utf8_capacity);
    return false;
  }

  return true;
}

}  // namespace speech_utils::native_recorder
