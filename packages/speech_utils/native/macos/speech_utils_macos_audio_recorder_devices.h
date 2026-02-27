#ifndef SPEECH_UTILS_MACOS_AUDIO_RECORDER_DEVICES_H_
#define SPEECH_UTILS_MACOS_AUDIO_RECORDER_DEVICES_H_

#import <TargetConditionals.h>

#if !TARGET_OS_IPHONE
#import <AVFoundation/AVFoundation.h>
#endif

#include <cstdint>

namespace speech_utils::apple_recorder {

bool SetMacosInputDevice(AVAudioInputNode* input_node, NSString* input_uid, char* error_utf8,
                         uint32_t error_utf8_capacity);

}  // namespace speech_utils::apple_recorder

#endif  // SPEECH_UTILS_MACOS_AUDIO_RECORDER_DEVICES_H_
