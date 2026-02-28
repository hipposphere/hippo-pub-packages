#ifndef SPEECH_UTILS_APPLE_AUDIO_RECORDER_COMMON_H_
#define SPEECH_UTILS_APPLE_AUDIO_RECORDER_COMMON_H_

#import <TargetConditionals.h>
#import <AVFoundation/AVFoundation.h>

#include <cstdint>
#include <string>

namespace speech_utils::apple_recorder {

inline constexpr int32_t kProcessingFlagNoiseSuppression = 1 << 0;
inline constexpr int32_t kProcessingFlagEchoCancellation = 1 << 1;
inline constexpr int32_t kProcessingFlagAutomaticGainControl = 1 << 2;
inline constexpr int32_t kProcessingFlagPresetVoice = 1 << 4;
inline constexpr int32_t kProcessingFlagPresetVoiceIsolation = 1 << 5;

inline constexpr int32_t kAppleFileEncoderAacLc = 0;
inline constexpr int32_t kAppleFileEncoderAacHe = 1;
inline constexpr int32_t kAppleFileEncoderAacEld = 2;

void WriteError(const std::string& message, char* out_error_utf8, uint32_t out_error_capacity);

void WriteNSError(NSError* error, const char* prefix, char* out_error_utf8,
                  uint32_t out_error_capacity);

std::string TrimAscii(const char* utf8);

bool EnsureMicrophonePermission(int32_t* out_has_permission, bool request_if_needed,
                                char* out_error_utf8, uint32_t out_error_capacity);

NSString* ResolveIosSessionMode(int32_t ios_session_mode_code, int32_t processing_flags);

AVAudioSessionCategoryOptions ResolveIosCategoryOptions(uint32_t ios_category_options_flags);

bool RequiresVoiceProcessing(int32_t processing_flags);

AudioFormatID ResolveAppleAacFormatId(int32_t file_encoder_code);

uint32_t ResolveAppleAacBitrate(uint32_t requested_bitrate_bps);

}  // namespace speech_utils::apple_recorder

#endif  // SPEECH_UTILS_APPLE_AUDIO_RECORDER_COMMON_H_
