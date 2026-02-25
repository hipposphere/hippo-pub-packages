#ifndef SPEECH_UTILS_APPLE_AUDIO_RECORDER_CAPTURE_UTILS_H_
#define SPEECH_UTILS_APPLE_AUDIO_RECORDER_CAPTURE_UTILS_H_

#import <AVFoundation/AVFoundation.h>

namespace speech_utils::apple_recorder {

bool IsPcm16InterleavedMatchingTarget(AVAudioFormat* input_format, AVAudioFormat* target_format);

NSArray<AVCaptureDevice*>* ListAudioCaptureDevices();

AVCaptureDevice* FindAudioCaptureDeviceByUniqueId(NSString* unique_id);

AVAudioPCMBuffer* CopySampleBufferToAudioPcmBuffer(CMSampleBufferRef sample_buffer);

}  // namespace speech_utils::apple_recorder

#endif  // SPEECH_UTILS_APPLE_AUDIO_RECORDER_CAPTURE_UTILS_H_
