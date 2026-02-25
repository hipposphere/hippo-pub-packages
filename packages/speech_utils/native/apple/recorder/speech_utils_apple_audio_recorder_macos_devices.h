#ifndef SPEECH_UTILS_APPLE_AUDIO_RECORDER_MACOS_DEVICES_H_
#define SPEECH_UTILS_APPLE_AUDIO_RECORDER_MACOS_DEVICES_H_

#import <AVFoundation/AVFoundation.h>

#include <cstdint>

namespace speech_utils::apple_recorder {

bool SetVoiceProcessingInputDeviceOnMacos(AVAudioInputNode* input_node, NSString* uid,
                                          char* error_utf8, uint32_t error_utf8_capacity);

}  // namespace speech_utils::apple_recorder

#endif  // SPEECH_UTILS_APPLE_AUDIO_RECORDER_MACOS_DEVICES_H_
