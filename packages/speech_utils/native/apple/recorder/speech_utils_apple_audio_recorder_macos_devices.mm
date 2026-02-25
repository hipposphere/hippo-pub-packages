#import "speech_utils_apple_audio_recorder_macos_devices.h"

#import <TargetConditionals.h>
#import <AudioToolbox/AudioToolbox.h>
#if !TARGET_OS_IPHONE
#import <CoreAudio/CoreAudio.h>
#endif

#include <string>
#include <vector>

#include "speech_utils_apple_audio_recorder_common_internal.h"

namespace speech_utils::apple_recorder {

#if !TARGET_OS_IPHONE
namespace {

std::string DescribeOsStatus(const char* prefix, OSStatus status) {
  return std::string(prefix) + " (OSStatus=" + std::to_string(static_cast<int32_t>(status)) + ").";
}

bool ResolveMacosInputDeviceIdByUid(NSString* uid, AudioDeviceID* out_device_id, char* error_utf8,
                                    uint32_t error_utf8_capacity) {
  if (uid == nil || uid.length == 0 || out_device_id == nullptr) {
    WriteError("Invalid macOS input-device selection request.", error_utf8, error_utf8_capacity);
    return false;
  }

  AudioObjectPropertyAddress devices_address{
      kAudioHardwarePropertyDevices, kAudioObjectPropertyScopeGlobal, kAudioObjectPropertyElementMain};
  UInt32 device_ids_size = 0;
  OSStatus status = AudioObjectGetPropertyDataSize(kAudioObjectSystemObject, &devices_address, 0,
                                                   nullptr, &device_ids_size);
  if (status != noErr) {
    WriteError(DescribeOsStatus("Failed to enumerate CoreAudio devices", status), error_utf8,
               error_utf8_capacity);
    return false;
  }
  if (device_ids_size == 0) {
    WriteError("No CoreAudio devices are currently available.", error_utf8, error_utf8_capacity);
    return false;
  }

  const auto device_count =
      static_cast<std::size_t>(device_ids_size / static_cast<UInt32>(sizeof(AudioDeviceID)));
  std::vector<AudioDeviceID> device_ids(device_count, kAudioObjectUnknown);
  status = AudioObjectGetPropertyData(kAudioObjectSystemObject, &devices_address, 0, nullptr,
                                      &device_ids_size, device_ids.data());
  if (status != noErr) {
    WriteError(DescribeOsStatus("Failed to read CoreAudio devices", status), error_utf8,
               error_utf8_capacity);
    return false;
  }

  AudioObjectPropertyAddress uid_address{
      kAudioDevicePropertyDeviceUID, kAudioObjectPropertyScopeGlobal, kAudioObjectPropertyElementMain};
  AudioObjectPropertyAddress input_streams_address{
      kAudioDevicePropertyStreams, kAudioDevicePropertyScopeInput, kAudioObjectPropertyElementMain};

  for (AudioDeviceID candidate_device_id : device_ids) {
    CFStringRef candidate_uid_ref = nullptr;
    UInt32 uid_size = static_cast<UInt32>(sizeof(candidate_uid_ref));
    status = AudioObjectGetPropertyData(candidate_device_id, &uid_address, 0, nullptr, &uid_size,
                                        &candidate_uid_ref);
    if (status != noErr || candidate_uid_ref == nullptr) {
      if (candidate_uid_ref != nullptr) {
        CFRelease(candidate_uid_ref);
      }
      continue;
    }

    NSString* candidate_uid = (__bridge NSString*)candidate_uid_ref;
    const bool is_match = [candidate_uid isEqualToString:uid];
    CFRelease(candidate_uid_ref);
    if (!is_match) {
      continue;
    }

    UInt32 input_streams_size = 0;
    status = AudioObjectGetPropertyDataSize(candidate_device_id, &input_streams_address, 0, nullptr,
                                            &input_streams_size);
    if (status != noErr) {
      WriteError(
          DescribeOsStatus("Failed to query selected macOS input-device stream information", status),
          error_utf8, error_utf8_capacity);
      return false;
    }
    if (input_streams_size == 0) {
      WriteError("Selected macOS audio device does not expose an input stream.", error_utf8,
                 error_utf8_capacity);
      return false;
    }

    *out_device_id = candidate_device_id;
    return true;
  }

  WriteError("Selected macOS input device is not available.", error_utf8, error_utf8_capacity);
  return false;
}

}  // namespace
#endif

bool SetVoiceProcessingInputDeviceOnMacos(AVAudioInputNode* input_node, NSString* uid,
                                          char* error_utf8, uint32_t error_utf8_capacity) {
#if TARGET_OS_IPHONE
  (void)input_node;
  (void)uid;
  (void)error_utf8;
  (void)error_utf8_capacity;
  return true;
#else
  if (uid == nil || uid.length == 0) {
    return true;
  }
  if (input_node == nil) {
    WriteError("AVAudioEngine input node is unavailable for input-device selection.", error_utf8,
               error_utf8_capacity);
    return false;
  }

  AudioDeviceID selected_device_id = kAudioObjectUnknown;
  if (!ResolveMacosInputDeviceIdByUid(uid, &selected_device_id, error_utf8, error_utf8_capacity)) {
    return false;
  }

  AudioUnit input_audio_unit = input_node.audioUnit;
  if (input_audio_unit == nullptr) {
    WriteError("AVAudioEngine input AudioUnit is unavailable.", error_utf8, error_utf8_capacity);
    return false;
  }

  const OSStatus status = AudioUnitSetProperty(input_audio_unit, kAudioOutputUnitProperty_CurrentDevice,
                                               kAudioUnitScope_Global, 0, &selected_device_id,
                                               static_cast<UInt32>(sizeof(selected_device_id)));
  if (status != noErr) {
    WriteError(DescribeOsStatus("Failed to set AVAudioEngine input device", status), error_utf8,
               error_utf8_capacity);
    return false;
  }
  return true;
#endif
}

}  // namespace speech_utils::apple_recorder
