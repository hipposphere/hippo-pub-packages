#ifndef SPEECH_UTILS_APPLE_AUDIO_RECORDER_COMMON_INTERNAL_H_
#define SPEECH_UTILS_APPLE_AUDIO_RECORDER_COMMON_INTERNAL_H_

#import <TargetConditionals.h>
#import <AVFoundation/AVFoundation.h>

#include <cstdint>
#include <string>

namespace speech_utils::apple_recorder {

inline constexpr int32_t kProcessingFlagNoiseSuppression = 1 << 0;
inline constexpr int32_t kProcessingFlagEchoCancellation = 1 << 1;
inline constexpr int32_t kProcessingFlagAutomaticGainControl = 1 << 2;
inline constexpr int32_t kProcessingFlagPresetVoiceIsolation = 1 << 5;
inline constexpr int32_t kProcessingFlagPresetRaw = 1 << 6;

void WriteError(const std::string& message, char* out_error_utf8, uint32_t out_error_capacity);

void WriteNSError(NSError* error, const char* prefix, char* out_error_utf8,
                  uint32_t out_error_capacity);

bool WriteOutput(const std::string& output, char* out_utf8, uint32_t out_capacity,
                 char* error_utf8, uint32_t error_capacity);

std::string TrimAscii(const char* utf8);

bool WriteJsonArray(NSArray<NSDictionary<NSString*, id>*>* json_array, char* out_json_utf8,
                    uint32_t out_json_capacity, char* error_utf8,
                    uint32_t error_utf8_capacity);

bool EnsureAudioInputPermission(int32_t* out_has_permission, bool request_if_needed,
                                char* out_error_utf8, uint32_t out_error_capacity);

NSString* ResolveAppleSessionMode(int32_t apple_session_mode_code, int32_t processing_flags);

AVAudioSessionCategoryOptions ResolveAppleCategoryOptions(uint32_t apple_category_options_flags);

bool ShouldUseVoiceProcessingBackend(int32_t processing_flags);

}  // namespace speech_utils::apple_recorder

#endif  // SPEECH_UTILS_APPLE_AUDIO_RECORDER_COMMON_INTERNAL_H_
