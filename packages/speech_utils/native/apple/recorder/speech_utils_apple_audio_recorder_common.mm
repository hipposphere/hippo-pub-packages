#import "speech_utils_apple_audio_recorder_common_internal.h"

#import <dispatch/dispatch.h>

#include <algorithm>
#include <cctype>
#include <cstring>

namespace speech_utils::apple_recorder {

void WriteError(const std::string& message, char* out_error_utf8, uint32_t out_error_capacity) {
  if (out_error_utf8 == nullptr || out_error_capacity == 0) {
    return;
  }
  const auto copy_length = static_cast<uint32_t>(
      std::min<std::size_t>(message.size(), static_cast<std::size_t>(out_error_capacity - 1)));
  std::memcpy(out_error_utf8, message.data(), copy_length);
  out_error_utf8[copy_length] = '\0';
}

void WriteNSError(NSError* error, const char* prefix, char* out_error_utf8,
                  uint32_t out_error_capacity) {
  if (error == nil) {
    WriteError(std::string(prefix) + ": unknown error", out_error_utf8, out_error_capacity);
    return;
  }
  const std::string message =
      std::string(prefix) + ": " + [[error localizedDescription] UTF8String];
  WriteError(message, out_error_utf8, out_error_capacity);
}

bool WriteOutput(const std::string& output, char* out_utf8, uint32_t out_capacity,
                 char* error_utf8, uint32_t error_capacity) {
  if (out_utf8 == nullptr || out_capacity == 0) {
    WriteError("Output buffer is null.", error_utf8, error_capacity);
    return false;
  }
  if (output.size() + 1 > out_capacity) {
    WriteError("Output buffer is too small.", error_utf8, error_capacity);
    return false;
  }
  std::memcpy(out_utf8, output.data(), output.size());
  out_utf8[output.size()] = '\0';
  return true;
}

std::string TrimAscii(const char* utf8) {
  if (utf8 == nullptr) {
    return {};
  }

  std::string value(utf8);
  const auto is_whitespace = [](unsigned char ch) { return std::isspace(ch) != 0; };

  const auto begin = std::find_if_not(value.begin(), value.end(), [&](char ch) {
    return is_whitespace(static_cast<unsigned char>(ch));
  });
  if (begin == value.end()) {
    return {};
  }

  const auto end = std::find_if_not(value.rbegin(), value.rend(), [&](char ch) {
                     return is_whitespace(static_cast<unsigned char>(ch));
                   }).base();
  return std::string(begin, end);
}

bool WriteJsonArray(NSArray<NSDictionary<NSString*, id>*>* json_array, char* out_json_utf8,
                    uint32_t out_json_capacity, char* error_utf8,
                    uint32_t error_utf8_capacity) {
  NSError* json_error = nil;
  NSData* json_data = [NSJSONSerialization dataWithJSONObject:json_array options:0 error:&json_error];
  if (json_data == nil) {
    WriteNSError(json_error, "Failed to encode input devices", error_utf8, error_utf8_capacity);
    return false;
  }

  const std::string payload(reinterpret_cast<const char*>(json_data.bytes), json_data.length);
  return WriteOutput(payload, out_json_utf8, out_json_capacity, error_utf8, error_utf8_capacity);
}

bool EnsureAudioInputPermission(int32_t* out_has_permission, bool request_if_needed,
                                char* out_error_utf8, uint32_t out_error_capacity) {
  if (out_has_permission == nullptr) {
    WriteError("Permission output pointer is null.", out_error_utf8, out_error_capacity);
    return false;
  }

  AVAuthorizationStatus status =
      [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
  if (status == AVAuthorizationStatusAuthorized) {
    *out_has_permission = 1;
    return true;
  }
  if (status == AVAuthorizationStatusDenied || status == AVAuthorizationStatusRestricted) {
    *out_has_permission = 0;
    return true;
  }
  if (!request_if_needed) {
    *out_has_permission = 0;
    return true;
  }

  __block bool granted = false;
  dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
  [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio
                           completionHandler:^(BOOL did_grant) {
                             granted = did_grant;
                             dispatch_semaphore_signal(semaphore);
                           }];

  const auto timeout = dispatch_time(DISPATCH_TIME_NOW, 30LL * NSEC_PER_SEC);
  if (dispatch_semaphore_wait(semaphore, timeout) != 0) {
    WriteError("Timed out while requesting microphone permission.", out_error_utf8,
               out_error_capacity);
    return false;
  }

  *out_has_permission = granted ? 1 : 0;
  return true;
}

NSString* ResolveAppleSessionMode(int32_t apple_session_mode_code, int32_t processing_flags) {
#if TARGET_OS_IPHONE
  switch (apple_session_mode_code) {
    case 1:
      return AVAudioSessionModeVoiceChat;
    case 2:
      return AVAudioSessionModeVideoChat;
    case 3:
      return AVAudioSessionModeMeasurement;
    case 4:
      return AVAudioSessionModeGameChat;
    case 5:
      return AVAudioSessionModeSpokenAudio;
    case 0:
    default:
      break;
  }

  if ((processing_flags & kProcessingFlagPresetRaw) != 0) {
    return AVAudioSessionModeMeasurement;
  }
  if ((processing_flags &
       (kProcessingFlagNoiseSuppression | kProcessingFlagEchoCancellation |
        kProcessingFlagAutomaticGainControl | kProcessingFlagPresetVoiceIsolation)) != 0) {
    return AVAudioSessionModeVoiceChat;
  }
  return AVAudioSessionModeDefault;
#else
  (void)apple_session_mode_code;
  (void)processing_flags;
  return nil;
#endif
}

AVAudioSessionCategoryOptions ResolveAppleCategoryOptions(uint32_t apple_category_options_flags) {
#if TARGET_OS_IPHONE
  AVAudioSessionCategoryOptions options = 0;
  if ((apple_category_options_flags & (1u << 0)) != 0u) {
    options |= AVAudioSessionCategoryOptionAllowBluetooth;
  }
  if ((apple_category_options_flags & (1u << 1)) != 0u) {
    options |= AVAudioSessionCategoryOptionAllowBluetoothA2DP;
  }
  if ((apple_category_options_flags & (1u << 2)) != 0u) {
    options |= AVAudioSessionCategoryOptionDefaultToSpeaker;
  }
  if ((apple_category_options_flags & (1u << 3)) != 0u) {
    options |= AVAudioSessionCategoryOptionMixWithOthers;
  }
  if ((apple_category_options_flags & (1u << 4)) != 0u) {
    options |= AVAudioSessionCategoryOptionDuckOthers;
  }
  return options;
#else
  (void)apple_category_options_flags;
  return 0;
#endif
}

bool ShouldUseVoiceProcessingBackend(int32_t processing_flags) {
  const int32_t voice_processing_mask =
      kProcessingFlagNoiseSuppression | kProcessingFlagEchoCancellation |
      kProcessingFlagAutomaticGainControl | kProcessingFlagPresetVoiceIsolation;
  return (processing_flags & voice_processing_mask) != 0;
}

}  // namespace speech_utils::apple_recorder
