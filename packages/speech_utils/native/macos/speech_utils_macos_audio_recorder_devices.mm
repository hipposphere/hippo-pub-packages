#import "speech_utils_macos_audio_recorder_devices.h"

#import <TargetConditionals.h>

#if !TARGET_OS_IPHONE
#import <AudioToolbox/AudioToolbox.h>
#import <CoreAudio/CoreAudio.h>
#endif

#include <cstdint>
#include <string>
#include <vector>

#import "../apple/speech_utils_apple_audio_recorder_common.h"

namespace speech_utils::apple_recorder {

#if !TARGET_OS_IPHONE
namespace {

std::string OsStatusToString(const char* context, OSStatus status) {
  return std::string(context) + " (OSStatus=" + std::to_string(static_cast<int32_t>(status)) +
         ")";
}

bool IsDefaultInputDeviceUid(NSString* input_uid) {
  if (input_uid == nil || input_uid.length == 0) {
    return false;
  }

  AudioObjectPropertyAddress default_input_addr{
      kAudioHardwarePropertyDefaultInputDevice, kAudioObjectPropertyScopeGlobal,
      kAudioObjectPropertyElementMain};
  AudioDeviceID default_device_id = kAudioObjectUnknown;
  UInt32 default_device_size = static_cast<UInt32>(sizeof(default_device_id));
  OSStatus status = AudioObjectGetPropertyData(kAudioObjectSystemObject, &default_input_addr, 0,
                                               nullptr, &default_device_size,
                                               &default_device_id);
  if (status != noErr || default_device_id == kAudioObjectUnknown) {
    return false;
  }

  AudioObjectPropertyAddress uid_addr{
      kAudioDevicePropertyDeviceUID, kAudioObjectPropertyScopeGlobal,
      kAudioObjectPropertyElementMain};
  CFStringRef default_uid_ref = nullptr;
  UInt32 uid_size = static_cast<UInt32>(sizeof(default_uid_ref));
  status = AudioObjectGetPropertyData(default_device_id, &uid_addr, 0, nullptr, &uid_size,
                                      &default_uid_ref);
  if (status != noErr || default_uid_ref == nullptr) {
    if (default_uid_ref != nullptr) {
      CFRelease(default_uid_ref);
    }
    return false;
  }

  NSString* default_uid = (__bridge NSString*)default_uid_ref;
  const bool is_default = [default_uid isEqualToString:input_uid];
  CFRelease(default_uid_ref);
  return is_default;
}

bool ResolveInputDeviceId(NSString* input_uid, AudioDeviceID* out_device_id, char* error_utf8,
                          uint32_t error_utf8_capacity) {
  if (input_uid == nil || input_uid.length == 0 || out_device_id == nullptr) {
    WriteError("Invalid macOS input device identifier.", error_utf8, error_utf8_capacity);
    return false;
  }

  AudioObjectPropertyAddress devices_addr{
      kAudioHardwarePropertyDevices, kAudioObjectPropertyScopeGlobal,
      kAudioObjectPropertyElementMain};

  UInt32 devices_size = 0;
  OSStatus status = AudioObjectGetPropertyDataSize(kAudioObjectSystemObject, &devices_addr, 0,
                                                   nullptr, &devices_size);
  if (status != noErr || devices_size == 0) {
    WriteError(OsStatusToString("Failed to enumerate CoreAudio devices", status), error_utf8,
               error_utf8_capacity);
    return false;
  }

  const std::size_t device_count =
      static_cast<std::size_t>(devices_size / static_cast<UInt32>(sizeof(AudioDeviceID)));
  std::vector<AudioDeviceID> device_ids(device_count, kAudioObjectUnknown);

  status = AudioObjectGetPropertyData(kAudioObjectSystemObject, &devices_addr, 0, nullptr,
                                      &devices_size, device_ids.data());
  if (status != noErr) {
    WriteError(OsStatusToString("Failed to read CoreAudio device list", status), error_utf8,
               error_utf8_capacity);
    return false;
  }

  AudioObjectPropertyAddress uid_addr{
      kAudioDevicePropertyDeviceUID, kAudioObjectPropertyScopeGlobal,
      kAudioObjectPropertyElementMain};
  AudioObjectPropertyAddress streams_addr{
      kAudioDevicePropertyStreams, kAudioDevicePropertyScopeInput,
      kAudioObjectPropertyElementMain};

  for (AudioDeviceID candidate : device_ids) {
    CFStringRef candidate_uid_ref = nullptr;
    UInt32 uid_size = static_cast<UInt32>(sizeof(candidate_uid_ref));
    status = AudioObjectGetPropertyData(candidate, &uid_addr, 0, nullptr, &uid_size,
                                        &candidate_uid_ref);
    if (status != noErr || candidate_uid_ref == nullptr) {
      if (candidate_uid_ref != nullptr) {
        CFRelease(candidate_uid_ref);
      }
      continue;
    }

    NSString* candidate_uid = (__bridge NSString*)candidate_uid_ref;
    const bool uid_match = [candidate_uid isEqualToString:input_uid];
    const bool device_id_match =
        [input_uid isEqualToString:[NSString stringWithFormat:@"%u", candidate]];
    const bool match = uid_match || device_id_match;
    CFRelease(candidate_uid_ref);
    if (!match) {
      continue;
    }

    UInt32 streams_size = 0;
    status = AudioObjectGetPropertyDataSize(candidate, &streams_addr, 0, nullptr, &streams_size);
    if (status != noErr) {
      WriteError(OsStatusToString("Failed to inspect selected input device streams", status),
                 error_utf8, error_utf8_capacity);
      return false;
    }
    if (streams_size == 0) {
      WriteError("Selected macOS device has no input stream.", error_utf8,
                 error_utf8_capacity);
      return false;
    }

    *out_device_id = candidate;
    return true;
  }

  WriteError("Selected macOS input device is not available.", error_utf8,
             error_utf8_capacity);
  return false;
}

}  // namespace
#endif

bool SetMacosInputDevice(AVAudioInputNode* input_node, NSString* input_uid, char* error_utf8,
                         uint32_t error_utf8_capacity) {
#if TARGET_OS_IPHONE
  (void)input_node;
  (void)input_uid;
  (void)error_utf8;
  (void)error_utf8_capacity;
  return true;
#else
  if (input_uid == nil || input_uid.length == 0) {
    return true;
  }
  if (input_node == nil) {
    WriteError("AVAudioEngine input node is unavailable.", error_utf8, error_utf8_capacity);
    return false;
  }

  if (IsDefaultInputDeviceUid(input_uid)) {
    return true;
  }

  AudioDeviceID resolved_device_id = kAudioObjectUnknown;
  if (!ResolveInputDeviceId(input_uid, &resolved_device_id, error_utf8, error_utf8_capacity)) {
    return false;
  }

  AUAudioUnit* input_au_audio_unit = input_node.AUAudioUnit;
  if (input_au_audio_unit == nil) {
    WriteError("AVAudioEngine input AUAudioUnit is unavailable.", error_utf8,
               error_utf8_capacity);
    return false;
  }

  if ([input_au_audio_unit respondsToSelector:@selector(setDeviceID:error:)]) {
    NSError* set_device_error = nil;
    if (![input_au_audio_unit setDeviceID:resolved_device_id error:&set_device_error]) {
      WriteNSError(set_device_error, "Failed to route AVAudioEngine input device", error_utf8,
                   error_utf8_capacity);
      return false;
    }
    return true;
  }

  AudioUnit input_audio_unit = input_node.audioUnit;
  if (input_audio_unit == nullptr) {
    WriteError("AVAudioEngine input audio unit is unavailable.", error_utf8,
               error_utf8_capacity);
    return false;
  }

  const OSStatus status = AudioUnitSetProperty(
      input_audio_unit, kAudioOutputUnitProperty_CurrentDevice, kAudioUnitScope_Global, 0,
      &resolved_device_id, static_cast<UInt32>(sizeof(resolved_device_id)));
  if (status != noErr) {
    WriteError(OsStatusToString("Failed to route AVAudioEngine input device", status),
               error_utf8, error_utf8_capacity);
    return false;
  }

  return true;
#endif
}

}  // namespace speech_utils::apple_recorder
