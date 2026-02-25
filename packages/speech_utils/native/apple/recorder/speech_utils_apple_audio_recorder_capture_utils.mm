#import "speech_utils_apple_audio_recorder_capture_utils.h"

#import <AudioToolbox/AudioToolbox.h>

#include <algorithm>
#include <cmath>
#include <cstddef>
#include <cstdint>
#include <cstring>
#include <limits>
#include <vector>

namespace speech_utils::apple_recorder {

bool IsPcm16InterleavedMatchingTarget(AVAudioFormat* input_format, AVAudioFormat* target_format) {
  if (input_format == nil || target_format == nil) {
    return false;
  }
  if (input_format.commonFormat != AVAudioPCMFormatInt16 ||
      target_format.commonFormat != AVAudioPCMFormatInt16) {
    return false;
  }
  if (!input_format.isInterleaved || !target_format.isInterleaved) {
    return false;
  }
  if (input_format.channelCount != target_format.channelCount) {
    return false;
  }
  return std::abs(input_format.sampleRate - target_format.sampleRate) < 0.5;
}

NSArray<AVCaptureDevice*>* ListAudioCaptureDevices() {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
  return [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio];
#pragma clang diagnostic pop
}

AVCaptureDevice* FindAudioCaptureDeviceByUniqueId(NSString* unique_id) {
  if (unique_id == nil || unique_id.length == 0) {
    return nil;
  }
  for (AVCaptureDevice* device in ListAudioCaptureDevices()) {
    if ([device.uniqueID isEqualToString:unique_id]) {
      return device;
    }
  }
  return nil;
}

AVAudioPCMBuffer* CopySampleBufferToAudioPcmBuffer(CMSampleBufferRef sample_buffer) {
  if (sample_buffer == nullptr) {
    return nil;
  }

  CMAudioFormatDescriptionRef format_description =
      CMSampleBufferGetFormatDescription(sample_buffer);
  if (format_description == nullptr) {
    return nil;
  }

  const AudioStreamBasicDescription* asbd =
      CMAudioFormatDescriptionGetStreamBasicDescription(format_description);
  if (asbd == nullptr || asbd->mChannelsPerFrame == 0) {
    return nil;
  }

  AVAudioFormat* input_format = [[AVAudioFormat alloc] initWithStreamDescription:asbd];
  if (input_format == nil) {
    return nil;
  }

  const CMItemCount frame_count_raw = CMSampleBufferGetNumSamples(sample_buffer);
  if (frame_count_raw <= 0 || frame_count_raw > std::numeric_limits<AVAudioFrameCount>::max()) {
    return nil;
  }
  const auto frame_count = static_cast<AVAudioFrameCount>(frame_count_raw);

  AVAudioPCMBuffer* input_buffer =
      [[AVAudioPCMBuffer alloc] initWithPCMFormat:input_format frameCapacity:frame_count];
  if (input_buffer == nil) {
    return nil;
  }
  input_buffer.frameLength = frame_count;

  const UInt32 expected_buffers = input_format.isInterleaved ? 1 : input_format.channelCount;
  const std::size_t list_size =
      offsetof(AudioBufferList, mBuffers) + sizeof(AudioBuffer) * expected_buffers;
  std::vector<uint8_t> list_storage(list_size, 0);
  auto* source_audio_buffer_list = reinterpret_cast<AudioBufferList*>(list_storage.data());

  CMBlockBufferRef retained_block_buffer = nullptr;
  const OSStatus status = CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(
      sample_buffer, nullptr, source_audio_buffer_list, list_size, nullptr, nullptr,
      kCMSampleBufferFlag_AudioBufferList_Assure16ByteAlignment, &retained_block_buffer);
  if (status != noErr) {
    if (retained_block_buffer != nullptr) {
      CFRelease(retained_block_buffer);
    }
    return nil;
  }

  AudioBufferList* destination_audio_buffer_list = input_buffer.mutableAudioBufferList;
  const UInt32 buffers_to_copy = std::min<UInt32>(source_audio_buffer_list->mNumberBuffers,
                                                  destination_audio_buffer_list->mNumberBuffers);
  for (UInt32 index = 0; index < buffers_to_copy; index++) {
    const AudioBuffer& source = source_audio_buffer_list->mBuffers[index];
    AudioBuffer& destination = destination_audio_buffer_list->mBuffers[index];
    if (source.mData == nullptr || destination.mData == nullptr) {
      continue;
    }
    const UInt32 bytes_to_copy = std::min<UInt32>(source.mDataByteSize, destination.mDataByteSize);
    if (bytes_to_copy == 0) {
      continue;
    }
    std::memcpy(destination.mData, source.mData, bytes_to_copy);
  }

  if (retained_block_buffer != nullptr) {
    CFRelease(retained_block_buffer);
  }
  return input_buffer;
}

}  // namespace speech_utils::apple_recorder
