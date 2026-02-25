#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreAudio/CoreAudio.h>
#import <TargetConditionals.h>
#import <dispatch/dispatch.h>

#include <algorithm>
#include <cctype>
#include <cmath>
#include <cstddef>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <deque>
#include <limits>
#include <mutex>
#include <string>
#include <vector>

#include "speech_utils_apple_audio_recorder_api.h"

typedef void (*SpeechUtilsSampleBufferCallback)(void* context, CMSampleBufferRef sample_buffer);

#if TARGET_OS_IPHONE
typedef AVCaptureFileOutput SpeechUtilsCaptureFileOutput;
#else
typedef AVCaptureAudioFileOutput SpeechUtilsCaptureFileOutput;
#endif
@class SpeechUtilsCaptureFileOutputDelegate;

@interface SpeechUtilsCaptureOutputDelegate : NSObject <AVCaptureAudioDataOutputSampleBufferDelegate>
- (instancetype)initWithContext:(void*)context callback:(SpeechUtilsSampleBufferCallback)callback;
@end

@implementation SpeechUtilsCaptureOutputDelegate {
  void* context_;
  SpeechUtilsSampleBufferCallback callback_;
}

- (instancetype)initWithContext:(void*)context callback:(SpeechUtilsSampleBufferCallback)callback {
  self = [super init];
  if (self != nil) {
    context_ = context;
    callback_ = callback;
  }
  return self;
}

- (void)captureOutput:(AVCaptureOutput*)output
    didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
           fromConnection:(AVCaptureConnection*)connection {
  (void)output;
  (void)connection;
  if (callback_ != nullptr && sampleBuffer != nullptr) {
    callback_(context_, sampleBuffer);
  }
}

@end

#if !TARGET_OS_IPHONE
@interface SpeechUtilsCaptureFileOutputDelegate : NSObject <AVCaptureFileOutputRecordingDelegate>
- (instancetype)init;
@property(nonatomic, strong, nullable) NSError* recordingError;
@end

@implementation SpeechUtilsCaptureFileOutputDelegate

- (instancetype)init {
  self = [super init];
  if (self != nil) {
    _recordingError = nil;
  }
  return self;
}

- (void)captureOutput:(AVCaptureFileOutput*)output
    didStartRecordingToOutputFileAtURL:(NSURL*)fileURL
                       fromConnections:(NSArray<AVCaptureConnection*>*)connections {
  (void)output;
  (void)fileURL;
  (void)connections;
}

- (void)captureOutput:(AVCaptureFileOutput*)output
    didFinishRecordingToOutputFileAtURL:(NSURL*)outputFileURL
                         fromConnections:(NSArray<AVCaptureConnection*>*)connections
                                   error:(NSError*)error {
  (void)output;
  (void)outputFileURL;
  (void)connections;
  _recordingError = error;
}

@end
#endif

namespace speech_utils::apple_recorder {

constexpr int32_t kProcessingFlagNoiseSuppression = 1 << 0;
constexpr int32_t kProcessingFlagEchoCancellation = 1 << 1;
constexpr int32_t kProcessingFlagAutomaticGainControl = 1 << 2;
constexpr int32_t kProcessingFlagPresetVoiceIsolation = 1 << 5;
constexpr int32_t kProcessingFlagPresetRaw = 1 << 6;

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

#if !TARGET_OS_IPHONE
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

bool SetVoiceProcessingInputDeviceOnMacos(AVAudioInputNode* input_node, NSString* uid,
                                          char* error_utf8, uint32_t error_utf8_capacity) {
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
}
#endif

bool ConfigureIosAudioSession(uint32_t sample_rate_hz, int32_t processing_flags,
                              int32_t apple_session_mode_code,
                              uint32_t apple_category_options_flags,
                              double preferred_latency_seconds,
                              double apple_preferred_io_buffer_duration_seconds,
                              double apple_preferred_input_gain, char* error_utf8,
                              uint32_t error_utf8_capacity) {
#if TARGET_OS_IPHONE
  AVAudioSession* audio_session = [AVAudioSession sharedInstance];
  NSError* session_error = nil;
  NSString* mode = ResolveAppleSessionMode(apple_session_mode_code, processing_flags);
  const AVAudioSessionCategoryOptions options =
      ResolveAppleCategoryOptions(apple_category_options_flags);
  if (![audio_session setCategory:AVAudioSessionCategoryPlayAndRecord
                         mode:mode
                      options:options
                        error:&session_error]) {
    WriteNSError(session_error, "Failed to configure AVAudioSession category", error_utf8,
                 error_utf8_capacity);
    return false;
  }

  if (apple_preferred_io_buffer_duration_seconds > 0.0) {
    [audio_session setPreferredIOBufferDuration:apple_preferred_io_buffer_duration_seconds
                                          error:nil];
  } else if (preferred_latency_seconds > 0.0) {
    [audio_session setPreferredIOBufferDuration:preferred_latency_seconds error:nil];
  }

  [audio_session setPreferredSampleRate:static_cast<double>(sample_rate_hz) error:nil];

  if (std::isfinite(apple_preferred_input_gain) && apple_preferred_input_gain >= 0.0 &&
      apple_preferred_input_gain <= 1.0 && audio_session.inputGainSettable) {
    [audio_session setInputGain:static_cast<float>(apple_preferred_input_gain) error:nil];
  }

  if (![audio_session setActive:YES error:&session_error]) {
    WriteNSError(session_error, "Failed to activate AVAudioSession", error_utf8,
                 error_utf8_capacity);
    return false;
  }
  return true;
#else
  (void)sample_rate_hz;
  (void)processing_flags;
  (void)apple_session_mode_code;
  (void)apple_category_options_flags;
  (void)preferred_latency_seconds;
  (void)apple_preferred_io_buffer_duration_seconds;
  (void)apple_preferred_input_gain;
  (void)error_utf8;
  (void)error_utf8_capacity;
  return true;
#endif
}

struct WavHeader {
  char riff[4];
  uint32_t chunk_size;
  char wave[4];
  char fmt[4];
  uint32_t subchunk1_size;
  uint16_t audio_format;
  uint16_t channel_count;
  uint32_t sample_rate;
  uint32_t byte_rate;
  uint16_t block_align;
  uint16_t bits_per_sample;
  char data[4];
  uint32_t data_size;
};

bool WriteInitialWavHeader(FILE* file, uint32_t sample_rate_hz, uint32_t channel_count) {
  if (file == nullptr) {
    return false;
  }

  WavHeader header{};
  std::memcpy(header.riff, "RIFF", 4);
  header.chunk_size = 36;
  std::memcpy(header.wave, "WAVE", 4);
  std::memcpy(header.fmt, "fmt ", 4);
  header.subchunk1_size = 16;
  header.audio_format = 1;
  header.channel_count = static_cast<uint16_t>(channel_count);
  header.sample_rate = sample_rate_hz;
  header.bits_per_sample = 16;
  header.block_align = static_cast<uint16_t>(header.channel_count * (header.bits_per_sample / 8));
  header.byte_rate = header.sample_rate * header.block_align;
  std::memcpy(header.data, "data", 4);
  header.data_size = 0;

  return std::fwrite(&header, sizeof(header), 1, file) == 1;
}

bool FinalizeWavHeader(FILE* file, uint32_t data_bytes_written, uint32_t sample_rate_hz,
                       uint32_t channel_count) {
  if (file == nullptr) {
    return false;
  }

  WavHeader header{};
  std::memcpy(header.riff, "RIFF", 4);
  std::memcpy(header.wave, "WAVE", 4);
  std::memcpy(header.fmt, "fmt ", 4);
  std::memcpy(header.data, "data", 4);
  header.subchunk1_size = 16;
  header.audio_format = 1;
  header.channel_count = static_cast<uint16_t>(channel_count);
  header.sample_rate = sample_rate_hz;
  header.bits_per_sample = 16;
  header.block_align = static_cast<uint16_t>(header.channel_count * (header.bits_per_sample / 8));
  header.byte_rate = header.sample_rate * header.block_align;
  header.data_size = data_bytes_written;
  header.chunk_size = 36 + data_bytes_written;

  if (std::fseek(file, 0, SEEK_SET) != 0) {
    return false;
  }
  if (std::fwrite(&header, sizeof(header), 1, file) != 1) {
    return false;
  }
  return true;
}

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

enum class RecorderMode { kStopped, kFile, kStream };
enum class RecorderBackend { kNone, kCaptureSession, kVoiceProcessingEngine };

class AppleAudioRecorderState {
 public:
  AppleAudioRecorderState() = default;

  ~AppleAudioRecorderState() {
    char ignore_error[1] = {0};
    Stop(ignore_error, sizeof(ignore_error));
  }

  int32_t ListInputDevicesJson(char* out_json_utf8, uint32_t out_json_capacity,
                               char* error_utf8, uint32_t error_utf8_capacity) {
    NSMutableArray<NSDictionary<NSString*, id>*>* devices = [NSMutableArray array];

#if TARGET_OS_IPHONE
    AVAudioSession* audio_session = [AVAudioSession sharedInstance];
    AVAudioSessionPortDescription* current_input = audio_session.currentRoute.inputs.firstObject;
    NSString* default_uid = current_input.UID;
    NSString* default_label = current_input.portName;

    NSArray<AVAudioSessionPortDescription*>* available_inputs = audio_session.availableInputs;
    for (AVAudioSessionPortDescription* port in available_inputs) {
      NSString* uid = port.UID;
      if (uid.length == 0) {
        continue;
      }
      NSString* label = port.portName.length > 0 ? port.portName : uid;
      const BOOL is_default = (default_uid != nil && [uid isEqualToString:default_uid]);
      [devices addObject:@{
        @"id" : uid,
        @"label" : label,
        @"isDefault" : @(is_default),
      }];
    }

    if (devices.count == 0 && default_uid.length > 0) {
      [devices addObject:@{
        @"id" : default_uid,
        @"label" : (default_label.length > 0 ? default_label : default_uid),
        @"isDefault" : @YES,
      }];
    }
#else
    AVCaptureDevice* default_device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    NSString* default_uid = default_device.uniqueID;

    for (AVCaptureDevice* device in ListAudioCaptureDevices()) {
      NSString* uid = device.uniqueID;
      if (uid.length == 0) {
        continue;
      }

      NSString* label = device.localizedName.length > 0 ? device.localizedName : uid;
      const BOOL is_default = (default_uid != nil && [uid isEqualToString:default_uid]);
      [devices addObject:@{
        @"id" : uid,
        @"label" : label,
        @"isDefault" : @(is_default),
      }];
    }
    if (devices.count == 0 && default_uid.length > 0) {
      [devices addObject:@{
        @"id" : default_uid,
        @"label" : (default_device.localizedName.length > 0 ? default_device.localizedName
                                                            : default_uid),
        @"isDefault" : @YES,
      }];
    }
#endif

    if (!WriteJsonArray(devices, out_json_utf8, out_json_capacity, error_utf8,
                        error_utf8_capacity)) {
      return -1;
    }

    return 0;
  }

  int32_t StartFile(const speech_utils::recorder::RecorderStartConfig& start_config,
                    char* error_utf8,
                    uint32_t error_utf8_capacity) {
    const char* output_path_utf8 = start_config.output_path_utf8;
    const uint32_t sample_rate_hz = start_config.sample_rate_hz;
    const uint32_t channel_count = start_config.channel_count;
    const char* input_device_id_utf8 = start_config.input_device_id_utf8;
    const int32_t processing_flags = start_config.runtime.processing_flags;
    const int32_t apple_session_mode_code = start_config.runtime.apple_session_mode_code;
    const uint32_t apple_category_options_flags =
        start_config.runtime.apple_category_options_flags;
    const double preferred_latency_seconds = start_config.runtime.preferred_latency_seconds;
    const double apple_preferred_io_buffer_duration_seconds =
        start_config.runtime.apple_preferred_io_buffer_duration_seconds;
    const double apple_preferred_input_gain = start_config.runtime.apple_preferred_input_gain;
    const uint32_t windows_preferred_period_frames =
        start_config.runtime.windows_preferred_period_frames;
    const uint32_t windows_flags = start_config.runtime.windows_flags;
    const int32_t windows_capture_category_code =
        start_config.runtime.windows_capture_category_code;
    const int32_t windows_use_communications_device =
        start_config.runtime.windows_use_communications_device;
    (void)windows_preferred_period_frames;
    (void)windows_flags;
    (void)windows_capture_category_code;
    (void)windows_use_communications_device;
    if (output_path_utf8 == nullptr) {
      WriteError("Output path is null.", error_utf8, error_utf8_capacity);
      return -1;
    }
    if (sample_rate_hz == 0 || channel_count == 0) {
      WriteError("Sample rate and channel count must be > 0.", error_utf8, error_utf8_capacity);
      return -2;
    }

    NSString* output_path = [NSString stringWithUTF8String:output_path_utf8];
    if (output_path.length == 0) {
      WriteError("Output path UTF-8 decoding failed.", error_utf8, error_utf8_capacity);
      return -3;
    }

    const NSString* output_extension = [[output_path pathExtension] lowercaseString];
    if (output_extension.length > 0 && [output_extension isEqualToString:@"m4a"]) {
      return StartAacFile(
          output_path, sample_rate_hz, channel_count, input_device_id_utf8, processing_flags,
          apple_session_mode_code, apple_category_options_flags, preferred_latency_seconds,
          apple_preferred_io_buffer_duration_seconds, apple_preferred_input_gain, error_utf8,
          error_utf8_capacity);
    }

    return StartInternal(sample_rate_hz, channel_count, 1024, RecorderMode::kFile, output_path,
                         input_device_id_utf8, processing_flags, apple_session_mode_code,
                         apple_category_options_flags, preferred_latency_seconds,
                         apple_preferred_io_buffer_duration_seconds, apple_preferred_input_gain,
                         error_utf8, error_utf8_capacity);
  }

  int32_t StartStream(const speech_utils::recorder::RecorderStartConfig& start_config,
                      char* error_utf8,
                      uint32_t error_utf8_capacity) {
    const uint32_t sample_rate_hz = start_config.sample_rate_hz;
    const uint32_t channel_count = start_config.channel_count;
    const uint32_t frames_per_chunk = start_config.frames_per_chunk;
    const char* input_device_id_utf8 = start_config.input_device_id_utf8;
    const int32_t processing_flags = start_config.runtime.processing_flags;
    const int32_t apple_session_mode_code = start_config.runtime.apple_session_mode_code;
    const uint32_t apple_category_options_flags =
        start_config.runtime.apple_category_options_flags;
    const double preferred_latency_seconds = start_config.runtime.preferred_latency_seconds;
    const double apple_preferred_io_buffer_duration_seconds =
        start_config.runtime.apple_preferred_io_buffer_duration_seconds;
    const double apple_preferred_input_gain = start_config.runtime.apple_preferred_input_gain;
    const uint32_t windows_preferred_period_frames =
        start_config.runtime.windows_preferred_period_frames;
    const uint32_t windows_flags = start_config.runtime.windows_flags;
    const int32_t windows_capture_category_code =
        start_config.runtime.windows_capture_category_code;
    const int32_t windows_use_communications_device =
        start_config.runtime.windows_use_communications_device;
    (void)windows_preferred_period_frames;
    (void)windows_flags;
    (void)windows_capture_category_code;
    (void)windows_use_communications_device;
    if (sample_rate_hz == 0 || channel_count == 0 || frames_per_chunk == 0) {
      WriteError("Sample rate, channel count and frames_per_chunk must be > 0.", error_utf8,
                 error_utf8_capacity);
      return -1;
    }
    return StartInternal(sample_rate_hz, channel_count, frames_per_chunk, RecorderMode::kStream,
                         nil, input_device_id_utf8, processing_flags, apple_session_mode_code,
                         apple_category_options_flags, preferred_latency_seconds,
                         apple_preferred_io_buffer_duration_seconds, apple_preferred_input_gain,
                         error_utf8, error_utf8_capacity);
  }

  int32_t ReadStreamPcm16(int16_t* out_samples, uint32_t out_sample_capacity,
                          uint32_t* out_samples_written, char* error_utf8,
                          uint32_t error_utf8_capacity) {
    if (out_samples == nullptr || out_samples_written == nullptr) {
      WriteError("Output sample pointers must not be null.", error_utf8, error_utf8_capacity);
      return -1;
    }

    *out_samples_written = 0;

    std::lock_guard<std::mutex> lock(mutex_);
    if (mode_ != RecorderMode::kStream) {
      return 0;
    }

    const uint32_t readable =
        static_cast<uint32_t>(std::min<std::size_t>(stream_samples_.size(), out_sample_capacity));
    for (uint32_t i = 0; i < readable; i++) {
      out_samples[i] = stream_samples_.front();
      stream_samples_.pop_front();
    }
    *out_samples_written = readable;
    return 0;
  }

  int32_t Stop(char* error_utf8, uint32_t error_utf8_capacity) {
    AVCaptureSession* capture_session = nil;
    AVCaptureDeviceInput* capture_input = nil;
    AVCaptureAudioDataOutput* capture_output = nil;
    SpeechUtilsCaptureFileOutput* capture_file_output = nil;
    SpeechUtilsCaptureFileOutputDelegate* capture_file_delegate = nil;
    AVAudioEngine* audio_engine = nil;
    AVAudioInputNode* audio_engine_input_node = nil;
    RecorderBackend recorder_backend = RecorderBackend::kNone;
    FILE* wav_file = nullptr;
    uint32_t wav_data_bytes_written = 0;
    uint32_t wav_sample_rate_hz = 0;
    uint32_t wav_channel_count = 0;
    int32_t deferred_error_code = 0;
    std::string deferred_error;

    {
      std::lock_guard<std::mutex> lock(mutex_);
      if (mode_ == RecorderMode::kStopped) {
        return 0;
      }

      mode_ = RecorderMode::kStopped;
      stream_samples_.clear();
      stream_sample_limit_ = 0;
      target_channel_count_ = 1;
      target_format_ = nil;
      wav_file = wav_file_;
      wav_data_bytes_written = wav_data_bytes_written_;
      wav_sample_rate_hz = wav_sample_rate_hz_;
      wav_channel_count = wav_channel_count_;
      wav_file_ = nullptr;
      wav_data_bytes_written_ = 0;
      wav_sample_rate_hz_ = 0;
      wav_channel_count_ = 0;
      current_amplitude_dbfs_ = -90.0;
      max_amplitude_dbfs_ = -90.0;
      recorder_backend = recorder_backend_;

      capture_session = capture_session_;
      capture_input = capture_input_;
      capture_output = capture_output_;
      capture_file_output = capture_file_output_;
      capture_file_delegate = capture_file_delegate_;
      audio_engine = audio_engine_;
      audio_engine_input_node = audio_engine_input_node_;

      capture_session_ = nil;
      capture_input_ = nil;
      capture_output_ = nil;
      capture_delegate_ = nil;
      capture_queue_ = nil;
      capture_file_output_ = nil;
      capture_file_delegate_ = nil;
      audio_engine_ = nil;
      audio_engine_input_node_ = nil;
      recorder_backend_ = RecorderBackend::kNone;
    }

    if (recorder_backend == RecorderBackend::kVoiceProcessingEngine) {
      if (audio_engine_input_node != nil) {
        [audio_engine_input_node removeTapOnBus:0];
      }
      if (audio_engine != nil) {
        [audio_engine stop];
        if (audio_engine_input_node != nil) {
          if (@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)) {
            (void)[audio_engine_input_node setVoiceProcessingEnabled:NO error:nil];
          }
        }
      }
    } else {
      if (capture_output != nil) {
        [capture_output setSampleBufferDelegate:nil queue:nil];
      }

#if !TARGET_OS_IPHONE
      if (capture_file_output != nil && [capture_file_output isRecording]) {
        [capture_file_output stopRecording];
        if (capture_file_delegate != nil && capture_file_delegate.recordingError != nil &&
            deferred_error_code == 0) {
          deferred_error_code = -25;
          deferred_error = std::string("Direct AAC recording failed: ") +
                           [[capture_file_delegate.recordingError localizedDescription] UTF8String];
        }
      }
#endif

      if (capture_session != nil) {
        [capture_session stopRunning];
        [capture_session beginConfiguration];
        if (capture_output != nil && [capture_session.outputs containsObject:capture_output]) {
          [capture_session removeOutput:capture_output];
        }
        if (capture_file_output != nil &&
            [capture_session.outputs containsObject:capture_file_output]) {
          [capture_session removeOutput:capture_file_output];
        }
        if (capture_input != nil && [capture_session.inputs containsObject:capture_input]) {
          [capture_session removeInput:capture_input];
        }
        [capture_session commitConfiguration];
      }
    }

    if (wav_file != nullptr) {
      uint32_t finalized_data_bytes = wav_data_bytes_written;
      std::fflush(wav_file);
      if (std::fseek(wav_file, 0, SEEK_END) == 0) {
        const long file_size = std::ftell(wav_file);
        if (file_size > 44) {
          const auto computed_data_bytes = static_cast<uint64_t>(file_size - 44);
          finalized_data_bytes = static_cast<uint32_t>(
              std::min<uint64_t>(computed_data_bytes, std::numeric_limits<uint32_t>::max()));
        } else {
          finalized_data_bytes = 0;
        }
      }
      (void)FinalizeWavHeader(wav_file, finalized_data_bytes, wav_sample_rate_hz,
                              wav_channel_count);
      std::fclose(wav_file);
    }

#if TARGET_OS_IPHONE
    AVAudioSession* audio_session = [AVAudioSession sharedInstance];
    [audio_session setActive:NO error:nil];
#endif

    if (deferred_error_code != 0) {
      WriteError(deferred_error, error_utf8, error_utf8_capacity);
      return deferred_error_code;
    }
    return 0;
  }

  int32_t Reset(char* error_utf8, uint32_t error_utf8_capacity) {
    char ignored_error[1] = {0};
    (void)error_utf8;
    (void)error_utf8_capacity;
    (void)Stop(ignored_error, sizeof(ignored_error));
    return 0;
  }

  int32_t IsRecording(int32_t* out_is_recording, char* error_utf8,
                      uint32_t error_utf8_capacity) {
    if (out_is_recording == nullptr) {
      WriteError("State output pointer is null.", error_utf8, error_utf8_capacity);
      return -1;
    }

    std::lock_guard<std::mutex> lock(mutex_);
    *out_is_recording = mode_ == RecorderMode::kStopped ? 0 : 1;
    return 0;
  }

 int32_t GetAmplitude(double* out_current_dbfs, double* out_max_dbfs, char* error_utf8,
                       uint32_t error_utf8_capacity) {
    if (out_current_dbfs == nullptr || out_max_dbfs == nullptr) {
      WriteError("Amplitude output pointers must not be null.", error_utf8, error_utf8_capacity);
      return -1;
    }

    std::lock_guard<std::mutex> lock(mutex_);
    *out_current_dbfs = current_amplitude_dbfs_;
    *out_max_dbfs = max_amplitude_dbfs_;
    return 0;
  }

 private:
  int32_t StartAacFile(NSString* output_path, uint32_t sample_rate_hz, uint32_t channel_count,
                       const char* input_device_id_utf8, int32_t processing_flags,
                       int32_t apple_session_mode_code, uint32_t apple_category_options_flags,
                       double preferred_latency_seconds,
                       double apple_preferred_io_buffer_duration_seconds,
                       double apple_preferred_input_gain, char* error_utf8,
                       uint32_t error_utf8_capacity) {
#if TARGET_OS_IPHONE
    (void)output_path;
    (void)sample_rate_hz;
    (void)channel_count;
    (void)input_device_id_utf8;
    (void)processing_flags;
    (void)apple_session_mode_code;
    (void)apple_category_options_flags;
    (void)preferred_latency_seconds;
    (void)apple_preferred_io_buffer_duration_seconds;
    (void)apple_preferred_input_gain;
    WriteError(
        "Direct AAC capture is unavailable on iOS in this backend. "
        "Use WAV capture with recorder finalization to AAC.",
        error_utf8, error_utf8_capacity);
    return -30;
#else
    int32_t has_permission = 0;
    if (!EnsureAudioInputPermission(&has_permission, false, error_utf8, error_utf8_capacity)) {
      return -4;
    }
    if (has_permission == 0) {
      WriteError("Microphone permission not granted.", error_utf8, error_utf8_capacity);
      return -5;
    }

    std::lock_guard<std::mutex> lock(mutex_);
    if (mode_ != RecorderMode::kStopped) {
      WriteError("Recorder is already running.", error_utf8, error_utf8_capacity);
      return -6;
    }

    const std::string effective_input_device_id = TrimAscii(input_device_id_utf8);
    AVCaptureDevice* capture_device = nil;

#if TARGET_OS_IPHONE
    if (!ConfigureIosAudioSession(sample_rate_hz, processing_flags, apple_session_mode_code,
                                  apple_category_options_flags, preferred_latency_seconds,
                                  apple_preferred_io_buffer_duration_seconds,
                                  apple_preferred_input_gain, error_utf8,
                                  error_utf8_capacity)) {
      return -8;
    }
    AVAudioSession* audio_session = [AVAudioSession sharedInstance];
    NSError* session_error = nil;

    NSString* requested_uid = nil;
    if (!effective_input_device_id.empty()) {
      requested_uid = [NSString stringWithUTF8String:effective_input_device_id.c_str()];
      if (requested_uid == nil || requested_uid.length == 0) {
        WriteError("Input device id UTF-8 decoding failed.", error_utf8, error_utf8_capacity);
        return -9;
      }
    }

    AVAudioSessionPortDescription* preferred_input = nil;
    if (requested_uid != nil) {
      NSArray<AVAudioSessionPortDescription*>* available_inputs = audio_session.availableInputs;
      for (AVAudioSessionPortDescription* port in available_inputs) {
        if ([port.UID isEqualToString:requested_uid]) {
          preferred_input = port;
          break;
        }
      }
      if (preferred_input == nil) {
        WriteError("Selected iOS input device is not available.", error_utf8,
                   error_utf8_capacity);
        return -10;
      }
    }

    if (![audio_session setPreferredInput:preferred_input error:&session_error]) {
      WriteNSError(session_error, "Failed to set preferred iOS input device", error_utf8,
                   error_utf8_capacity);
      return -11;
    }
#else
    if (!effective_input_device_id.empty()) {
      NSString* requested_uid = [NSString stringWithUTF8String:effective_input_device_id.c_str()];
      if (requested_uid == nil || requested_uid.length == 0) {
        WriteError("Input device id UTF-8 decoding failed.", error_utf8, error_utf8_capacity);
        return -13;
      }
      capture_device = FindAudioCaptureDeviceByUniqueId(requested_uid);
      if (capture_device == nil) {
        WriteError("Selected macOS input device is not available.", error_utf8,
                   error_utf8_capacity);
        return -14;
      }
    }
#endif

    if (capture_device == nil) {
      capture_device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    }
    if (capture_device == nil) {
      WriteError("Audio capture device is unavailable.", error_utf8, error_utf8_capacity);
      return -15;
    }

    NSError* input_error = nil;
    AVCaptureDeviceInput* capture_input =
        [AVCaptureDeviceInput deviceInputWithDevice:capture_device error:&input_error];
    if (capture_input == nil) {
      WriteNSError(input_error, "Failed to create AVCaptureDeviceInput", error_utf8,
                   error_utf8_capacity);
      return -16;
    }

    AVCaptureSession* capture_session = [[AVCaptureSession alloc] init];
    AVCaptureAudioDataOutput* capture_output = [[AVCaptureAudioDataOutput alloc] init];
    SpeechUtilsCaptureFileOutput* capture_file_output = [[AVCaptureAudioFileOutput alloc] init];
    if (capture_session == nil || capture_file_output == nil || capture_output == nil) {
      WriteError("Failed to initialize AVCaptureSession objects.", error_utf8,
                 error_utf8_capacity);
      return -17;
    }

    AVAudioFormat* target_format =
        [[AVAudioFormat alloc] initWithCommonFormat:AVAudioPCMFormatInt16
                                          sampleRate:static_cast<double>(sample_rate_hz)
                                            channels:channel_count
                                         interleaved:YES];
    if (target_format == nil) {
      WriteError("Failed to create target PCM16 format.", error_utf8, error_utf8_capacity);
      return -17;
    }

    NSDictionary<NSString*, id>* data_output_settings = @{
      AVFormatIDKey : @(kAudioFormatLinearPCM),
      AVSampleRateKey : @(static_cast<double>(sample_rate_hz)),
      AVNumberOfChannelsKey : @(channel_count),
      AVLinearPCMBitDepthKey : @16,
      AVLinearPCMIsFloatKey : @NO,
      AVLinearPCMIsBigEndianKey : @NO,
      AVLinearPCMIsNonInterleaved : @NO,
    };
    capture_output.audioSettings = data_output_settings;

    dispatch_queue_t capture_queue =
        dispatch_queue_create("org.hippolabs.speech_utils.audio_recorder.capture",
                             DISPATCH_QUEUE_SERIAL);
    SpeechUtilsCaptureOutputDelegate* capture_delegate =
        [[SpeechUtilsCaptureOutputDelegate alloc] initWithContext:this
                                                         callback:&AppleAudioRecorderState::OnCapturedSampleBufferThunk];
    [capture_output setSampleBufferDelegate:capture_delegate queue:capture_queue];

    NSFileManager* file_manager = [NSFileManager defaultManager];
    if ([file_manager fileExistsAtPath:output_path]) {
      NSError* remove_error = nil;
      if (![file_manager removeItemAtPath:output_path error:&remove_error]) {
        WriteNSError(remove_error, "Failed to remove existing output file", error_utf8,
                     error_utf8_capacity);
        return -21;
      }
    }

    NSDictionary<NSString*, id>* audio_settings = @{
      AVFormatIDKey : @(kAudioFormatMPEG4AAC),
      AVSampleRateKey : @(static_cast<double>(sample_rate_hz)),
      AVNumberOfChannelsKey : @(channel_count),
      AVEncoderBitRateKey : @64000,
    };
    capture_file_output.audioSettings = audio_settings;

    SpeechUtilsCaptureFileOutputDelegate* file_delegate =
        [[SpeechUtilsCaptureFileOutputDelegate alloc] init];

    [capture_session beginConfiguration];
    if (![capture_session canAddInput:capture_input]) {
      [capture_output setSampleBufferDelegate:nil queue:nil];
      [capture_session commitConfiguration];
      WriteError("Failed to add audio input to AVCaptureSession.", error_utf8,
                 error_utf8_capacity);
      return -18;
    }
    [capture_session addInput:capture_input];

    if (![capture_session canAddOutput:capture_output]) {
      [capture_session removeInput:capture_input];
      [capture_output setSampleBufferDelegate:nil queue:nil];
      [capture_session commitConfiguration];
      WriteError("Failed to add audio data output to AVCaptureSession.", error_utf8,
                 error_utf8_capacity);
      return -19;
    }
    [capture_session addOutput:capture_output];

    if (![capture_session canAddOutput:capture_file_output]) {
      [capture_session removeInput:capture_input];
      [capture_session removeOutput:capture_output];
      [capture_output setSampleBufferDelegate:nil queue:nil];
      [capture_session commitConfiguration];
      WriteError("Failed to add audio file output to AVCaptureSession.", error_utf8,
                 error_utf8_capacity);
      return -20;
    }
    [capture_session addOutput:capture_file_output];
    [capture_session commitConfiguration];

    [capture_session startRunning];
    if (![capture_session isRunning]) {
      [capture_session beginConfiguration];
      [capture_session removeOutput:capture_file_output];
      [capture_session removeOutput:capture_output];
      [capture_session removeInput:capture_input];
      [capture_session commitConfiguration];
      [capture_output setSampleBufferDelegate:nil queue:nil];
      WriteError("Failed to start AVCaptureSession.", error_utf8, error_utf8_capacity);
      return -24;
    }

    NSURL* output_url = [NSURL fileURLWithPath:output_path];
    [capture_file_output startRecordingToOutputFileURL:output_url
                                        outputFileType:AVFileTypeAppleM4A
                                       recordingDelegate:file_delegate];

    stream_samples_.clear();
    stream_sample_limit_ = std::max<std::size_t>(sample_rate_hz * channel_count * 5, 1024 * channel_count * 16);
    target_channel_count_ = channel_count;
    target_format_ = target_format;
    wav_file_ = nullptr;
    wav_data_bytes_written_ = 0;
    wav_sample_rate_hz_ = 0;
    wav_channel_count_ = 0;

    capture_session_ = capture_session;
    capture_input_ = capture_input;
    capture_output_ = capture_output;
    capture_delegate_ = capture_delegate;
    capture_queue_ = capture_queue;
    capture_file_output_ = capture_file_output;
    capture_file_delegate_ = file_delegate;
    audio_engine_ = nil;
    audio_engine_input_node_ = nil;
    recorder_backend_ = RecorderBackend::kCaptureSession;
    current_amplitude_dbfs_ = -90.0;
    max_amplitude_dbfs_ = -90.0;
    mode_ = RecorderMode::kFile;
    return 0;
#endif
  }

  int32_t StartInternalWithVoiceProcessing(
      uint32_t sample_rate_hz, uint32_t channel_count, uint32_t frames_per_chunk, RecorderMode mode,
      NSString* output_path, const char* input_device_id_utf8, int32_t processing_flags,
      int32_t apple_session_mode_code, uint32_t apple_category_options_flags,
      double preferred_latency_seconds, double apple_preferred_io_buffer_duration_seconds,
      double apple_preferred_input_gain, char* error_utf8, uint32_t error_utf8_capacity) {
    int32_t has_permission = 0;
    if (!EnsureAudioInputPermission(&has_permission, false, error_utf8, error_utf8_capacity)) {
      return -4;
    }
    if (has_permission == 0) {
      WriteError("Microphone permission not granted.", error_utf8, error_utf8_capacity);
      return -5;
    }

    std::lock_guard<std::mutex> lock(mutex_);
    if (mode_ != RecorderMode::kStopped) {
      WriteError("Recorder is already running.", error_utf8, error_utf8_capacity);
      return -6;
    }

    const std::string effective_input_device_id = TrimAscii(input_device_id_utf8);
    NSString* requested_input_uid = nil;

#if TARGET_OS_IPHONE
    if (!ConfigureIosAudioSession(sample_rate_hz, processing_flags, apple_session_mode_code,
                                  apple_category_options_flags, preferred_latency_seconds,
                                  apple_preferred_io_buffer_duration_seconds,
                                  apple_preferred_input_gain, error_utf8,
                                  error_utf8_capacity)) {
      return -8;
    }
    AVAudioSession* audio_session = [AVAudioSession sharedInstance];
    NSError* session_error = nil;

    NSString* preferred_uid = nil;
    if (!effective_input_device_id.empty()) {
      preferred_uid = [NSString stringWithUTF8String:effective_input_device_id.c_str()];
      if (preferred_uid == nil || preferred_uid.length == 0) {
        WriteError("Input device id UTF-8 decoding failed.", error_utf8, error_utf8_capacity);
        return -9;
      }
    }

    AVAudioSessionPortDescription* preferred_input = nil;
    if (preferred_uid != nil) {
      NSArray<AVAudioSessionPortDescription*>* available_inputs = audio_session.availableInputs;
      for (AVAudioSessionPortDescription* port in available_inputs) {
        if ([port.UID isEqualToString:preferred_uid]) {
          preferred_input = port;
          break;
        }
      }
      if (preferred_input == nil) {
        WriteError("Selected iOS input device is not available.", error_utf8,
                   error_utf8_capacity);
        return -10;
      }
    }

    if (![audio_session setPreferredInput:preferred_input error:&session_error]) {
      WriteNSError(session_error, "Failed to set preferred iOS input device", error_utf8,
                   error_utf8_capacity);
      return -11;
    }
#else
    if (!effective_input_device_id.empty()) {
      requested_input_uid = [NSString stringWithUTF8String:effective_input_device_id.c_str()];
      if (requested_input_uid == nil || requested_input_uid.length == 0) {
        WriteError("Input device id UTF-8 decoding failed.", error_utf8, error_utf8_capacity);
        return -13;
      }
    }
#endif

    AVAudioFormat* target_format =
        [[AVAudioFormat alloc] initWithCommonFormat:AVAudioPCMFormatInt16
                                          sampleRate:static_cast<double>(sample_rate_hz)
                                            channels:channel_count
                                         interleaved:YES];
    if (target_format == nil) {
      WriteError("Failed to create target PCM16 format.", error_utf8, error_utf8_capacity);
      return -12;
    }

    FILE* wav_file = nullptr;
    if (mode == RecorderMode::kFile) {
      if (output_path == nil || output_path.length == 0) {
        WriteError("Output path is missing.", error_utf8, error_utf8_capacity);
        return -20;
      }

      NSFileManager* file_manager = [NSFileManager defaultManager];
      if ([file_manager fileExistsAtPath:output_path]) {
        NSError* remove_error = nil;
        if (![file_manager removeItemAtPath:output_path error:&remove_error]) {
          WriteNSError(remove_error, "Failed to remove existing output file", error_utf8,
                       error_utf8_capacity);
          return -21;
        }
      }

      const char* output_path_cstr = [output_path fileSystemRepresentation];
      if (output_path_cstr == nullptr || output_path_cstr[0] == '\0') {
        WriteError("Output path cannot be represented as a file-system path.", error_utf8,
                   error_utf8_capacity);
        return -22;
      }

      wav_file = std::fopen(output_path_cstr, "wb");
      if (wav_file == nullptr) {
        WriteError("Failed to create output WAV file.", error_utf8, error_utf8_capacity);
        return -22;
      }
      if (!WriteInitialWavHeader(wav_file, sample_rate_hz, channel_count)) {
        std::fclose(wav_file);
        WriteError("Failed to write WAV header.", error_utf8, error_utf8_capacity);
        return -22;
      }
    }

    AVAudioEngine* audio_engine = [[AVAudioEngine alloc] init];
    if (audio_engine == nil) {
      if (wav_file != nullptr) {
        std::fclose(wav_file);
      }
      WriteError("Failed to initialize AVAudioEngine.", error_utf8, error_utf8_capacity);
      return -17;
    }

    AVAudioInputNode* input_node = audio_engine.inputNode;
    if (input_node == nil) {
      if (wav_file != nullptr) {
        std::fclose(wav_file);
      }
      WriteError("Audio input node is unavailable.", error_utf8, error_utf8_capacity);
      return -18;
    }

#if !TARGET_OS_IPHONE
    if (!SetVoiceProcessingInputDeviceOnMacos(input_node, requested_input_uid, error_utf8,
                                              error_utf8_capacity)) {
      if (wav_file != nullptr) {
        std::fclose(wav_file);
      }
      return -18;
    }
#endif

    NSError* voice_processing_error = nil;
    if (@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)) {
      if (![input_node setVoiceProcessingEnabled:YES error:&voice_processing_error]) {
        if (wav_file != nullptr) {
          std::fclose(wav_file);
        }
        WriteNSError(voice_processing_error, "Failed to enable AVAudioEngine voice processing",
                     error_utf8, error_utf8_capacity);
        return -19;
      }
      input_node.voiceProcessingAGCEnabled =
          (processing_flags & kProcessingFlagAutomaticGainControl) != 0;
    } else {
      if (wav_file != nullptr) {
        std::fclose(wav_file);
      }
      WriteError("AVAudioEngine voice processing requires iOS 13.0/macOS 10.15 or newer.",
                 error_utf8, error_utf8_capacity);
      return -19;
    }

    const AVAudioFrameCount tap_buffer_frames =
        static_cast<AVAudioFrameCount>(std::max<uint32_t>(frames_per_chunk, 64));
    [input_node removeTapOnBus:0];
    AppleAudioRecorderState* const callback_state = this;
    [input_node installTapOnBus:0
                     bufferSize:tap_buffer_frames
                         format:nil
                          block:^(AVAudioPCMBuffer* buffer, AVAudioTime* when) {
                            (void)when;
                            if (callback_state == nullptr || buffer == nil) {
                              return;
                            }
                            callback_state->OnAudioEnginePcmBuffer(buffer);
                          }];

    [audio_engine prepare];
    NSError* start_error = nil;
    if (![audio_engine startAndReturnError:&start_error]) {
      [input_node removeTapOnBus:0];
      if (wav_file != nullptr) {
        std::fclose(wav_file);
      }
#if TARGET_OS_IPHONE
      [audio_session setActive:NO error:nil];
#endif
      WriteNSError(start_error, "Failed to start AVAudioEngine", error_utf8, error_utf8_capacity);
      return -23;
    }

    stream_samples_.clear();
    stream_sample_limit_ =
        std::max<std::size_t>(sample_rate_hz * channel_count * 5,
                              static_cast<std::size_t>(frames_per_chunk) * channel_count * 16);
    target_channel_count_ = channel_count;
    target_format_ = target_format;
    wav_file_ = wav_file;
    wav_data_bytes_written_ = 0;
    wav_sample_rate_hz_ = mode == RecorderMode::kFile ? sample_rate_hz : 0;
    wav_channel_count_ = mode == RecorderMode::kFile ? channel_count : 0;

    capture_session_ = nil;
    capture_input_ = nil;
    capture_output_ = nil;
    capture_delegate_ = nil;
    capture_queue_ = nil;
    capture_file_output_ = nil;
    capture_file_delegate_ = nil;
    audio_engine_ = audio_engine;
    audio_engine_input_node_ = input_node;
    recorder_backend_ = RecorderBackend::kVoiceProcessingEngine;
    current_amplitude_dbfs_ = -90.0;
    max_amplitude_dbfs_ = -90.0;
    mode_ = mode;
    return 0;
  }

  int32_t StartInternal(uint32_t sample_rate_hz, uint32_t channel_count, uint32_t frames_per_chunk,
                        RecorderMode mode, NSString* output_path, const char* input_device_id_utf8,
                        int32_t processing_flags, int32_t apple_session_mode_code,
                        uint32_t apple_category_options_flags, double preferred_latency_seconds,
                        double apple_preferred_io_buffer_duration_seconds,
                        double apple_preferred_input_gain, char* error_utf8,
                        uint32_t error_utf8_capacity) {
    const bool wants_voice_processing = ShouldUseVoiceProcessingBackend(processing_flags);
    if (wants_voice_processing) {
#if TARGET_OS_IPHONE
      return StartInternalWithVoiceProcessing(
          sample_rate_hz, channel_count, frames_per_chunk, mode, output_path, input_device_id_utf8,
          processing_flags, apple_session_mode_code, apple_category_options_flags,
          preferred_latency_seconds, apple_preferred_io_buffer_duration_seconds,
          apple_preferred_input_gain, error_utf8, error_utf8_capacity);
#else
      if (TrimAscii(input_device_id_utf8).empty()) {
        return StartInternalWithVoiceProcessing(
            sample_rate_hz, channel_count, frames_per_chunk, mode, output_path,
            input_device_id_utf8, processing_flags, apple_session_mode_code,
            apple_category_options_flags, preferred_latency_seconds,
            apple_preferred_io_buffer_duration_seconds, apple_preferred_input_gain, error_utf8,
            error_utf8_capacity);
      }
#endif
    }

    int32_t has_permission = 0;
    if (!EnsureAudioInputPermission(&has_permission, false, error_utf8, error_utf8_capacity)) {
      return -4;
    }
    if (has_permission == 0) {
      WriteError("Microphone permission not granted.", error_utf8, error_utf8_capacity);
      return -5;
    }

    std::lock_guard<std::mutex> lock(mutex_);
    if (mode_ != RecorderMode::kStopped) {
      WriteError("Recorder is already running.", error_utf8, error_utf8_capacity);
      return -6;
    }

    const std::string effective_input_device_id = TrimAscii(input_device_id_utf8);

#if TARGET_OS_IPHONE
    if (!ConfigureIosAudioSession(sample_rate_hz, processing_flags, apple_session_mode_code,
                                  apple_category_options_flags, preferred_latency_seconds,
                                  apple_preferred_io_buffer_duration_seconds,
                                  apple_preferred_input_gain, error_utf8,
                                  error_utf8_capacity)) {
      return -8;
    }
    AVAudioSession* audio_session = [AVAudioSession sharedInstance];
    NSError* session_error = nil;

    NSString* preferred_uid = nil;
    if (!effective_input_device_id.empty()) {
      preferred_uid = [NSString stringWithUTF8String:effective_input_device_id.c_str()];
      if (preferred_uid == nil || preferred_uid.length == 0) {
        WriteError("Input device id UTF-8 decoding failed.", error_utf8, error_utf8_capacity);
        return -9;
      }
    }

    AVAudioSessionPortDescription* preferred_input = nil;
    if (preferred_uid != nil) {
      NSArray<AVAudioSessionPortDescription*>* available_inputs = audio_session.availableInputs;
      for (AVAudioSessionPortDescription* port in available_inputs) {
        if ([port.UID isEqualToString:preferred_uid]) {
          preferred_input = port;
          break;
        }
      }
      if (preferred_input == nil) {
        WriteError("Selected iOS input device is not available.", error_utf8,
                   error_utf8_capacity);
        return -10;
      }
    }

    if (![audio_session setPreferredInput:preferred_input error:&session_error]) {
      WriteNSError(session_error, "Failed to set preferred iOS input device", error_utf8,
                   error_utf8_capacity);
      return -11;
    }
#endif

    AVAudioFormat* target_format =
        [[AVAudioFormat alloc] initWithCommonFormat:AVAudioPCMFormatInt16
                                          sampleRate:static_cast<double>(sample_rate_hz)
                                            channels:channel_count
                                         interleaved:YES];
    if (target_format == nil) {
      WriteError("Failed to create target PCM16 format.", error_utf8, error_utf8_capacity);
      return -12;
    }

    AVCaptureDevice* capture_device = nil;
    if (!effective_input_device_id.empty()) {
      NSString* requested_uid = [NSString stringWithUTF8String:effective_input_device_id.c_str()];
      if (requested_uid == nil || requested_uid.length == 0) {
        WriteError("Input device id UTF-8 decoding failed.", error_utf8, error_utf8_capacity);
        return -13;
      }
      capture_device = FindAudioCaptureDeviceByUniqueId(requested_uid);
#if !TARGET_OS_IPHONE
      if (capture_device == nil) {
        WriteError("Selected macOS input device is not available.", error_utf8,
                   error_utf8_capacity);
        return -14;
      }
#endif
    }

    if (capture_device == nil) {
      capture_device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    }
    if (capture_device == nil) {
      WriteError("Audio capture device is unavailable.", error_utf8, error_utf8_capacity);
      return -15;
    }

    NSError* input_error = nil;
    AVCaptureDeviceInput* capture_input =
        [AVCaptureDeviceInput deviceInputWithDevice:capture_device error:&input_error];
    if (capture_input == nil) {
      WriteNSError(input_error, "Failed to create AVCaptureDeviceInput", error_utf8,
                   error_utf8_capacity);
      return -16;
    }

    AVCaptureSession* capture_session = [[AVCaptureSession alloc] init];
    AVCaptureAudioDataOutput* capture_output = [[AVCaptureAudioDataOutput alloc] init];
    if (capture_session == nil || capture_output == nil) {
      WriteError("Failed to initialize AVCaptureSession objects.", error_utf8,
                 error_utf8_capacity);
      return -17;
    }

#if !TARGET_OS_IPHONE
    NSDictionary<NSString*, id>* audio_settings = @{
      AVFormatIDKey : @(kAudioFormatLinearPCM),
      AVSampleRateKey : @(static_cast<double>(sample_rate_hz)),
      AVNumberOfChannelsKey : @(channel_count),
      AVLinearPCMBitDepthKey : @16,
      AVLinearPCMIsFloatKey : @NO,
      AVLinearPCMIsBigEndianKey : @NO,
      AVLinearPCMIsNonInterleaved : @NO,
    };
    capture_output.audioSettings = audio_settings;
#endif

    dispatch_queue_t capture_queue =
        dispatch_queue_create("org.hippolabs.speech_utils.audio_recorder.capture", DISPATCH_QUEUE_SERIAL);
    SpeechUtilsCaptureOutputDelegate* capture_delegate =
        [[SpeechUtilsCaptureOutputDelegate alloc] initWithContext:this
                                                         callback:&AppleAudioRecorderState::OnCapturedSampleBufferThunk];
    [capture_output setSampleBufferDelegate:capture_delegate queue:capture_queue];

    [capture_session beginConfiguration];
    if (![capture_session canAddInput:capture_input]) {
      [capture_output setSampleBufferDelegate:nil queue:nil];
      [capture_session commitConfiguration];
      WriteError("Failed to add audio input to AVCaptureSession.", error_utf8,
                 error_utf8_capacity);
      return -18;
    }
    [capture_session addInput:capture_input];

    if (![capture_session canAddOutput:capture_output]) {
      [capture_session removeInput:capture_input];
      [capture_output setSampleBufferDelegate:nil queue:nil];
      [capture_session commitConfiguration];
      WriteError("Failed to add audio output to AVCaptureSession.", error_utf8,
                 error_utf8_capacity);
      return -19;
    }
    [capture_session addOutput:capture_output];
    [capture_session commitConfiguration];

    FILE* wav_file = nullptr;
    if (mode == RecorderMode::kFile) {
      if (output_path == nil || output_path.length == 0) {
        [capture_output setSampleBufferDelegate:nil queue:nil];
        [capture_session beginConfiguration];
        [capture_session removeOutput:capture_output];
        [capture_session removeInput:capture_input];
        [capture_session commitConfiguration];
        WriteError("Output path is missing.", error_utf8, error_utf8_capacity);
        return -20;
      }

      NSFileManager* file_manager = [NSFileManager defaultManager];
      if ([file_manager fileExistsAtPath:output_path]) {
        NSError* remove_error = nil;
        if (![file_manager removeItemAtPath:output_path error:&remove_error]) {
          [capture_output setSampleBufferDelegate:nil queue:nil];
          [capture_session beginConfiguration];
          [capture_session removeOutput:capture_output];
          [capture_session removeInput:capture_input];
          [capture_session commitConfiguration];
          WriteNSError(remove_error, "Failed to remove existing output file", error_utf8,
                       error_utf8_capacity);
          return -21;
        }
      }

      const char* output_path_cstr = [output_path fileSystemRepresentation];
      if (output_path_cstr == nullptr || output_path_cstr[0] == '\0') {
        [capture_output setSampleBufferDelegate:nil queue:nil];
        [capture_session beginConfiguration];
        [capture_session removeOutput:capture_output];
        [capture_session removeInput:capture_input];
        [capture_session commitConfiguration];
        WriteError("Output path cannot be represented as a file-system path.", error_utf8,
                   error_utf8_capacity);
        return -22;
      }

      wav_file = std::fopen(output_path_cstr, "wb");
      if (wav_file == nullptr) {
        [capture_output setSampleBufferDelegate:nil queue:nil];
        [capture_session beginConfiguration];
        [capture_session removeOutput:capture_output];
        [capture_session removeInput:capture_input];
        [capture_session commitConfiguration];
        WriteError("Failed to create output WAV file.", error_utf8, error_utf8_capacity);
        return -22;
      }
      if (!WriteInitialWavHeader(wav_file, sample_rate_hz, channel_count)) {
        std::fclose(wav_file);
        wav_file = nullptr;
        [capture_output setSampleBufferDelegate:nil queue:nil];
        [capture_session beginConfiguration];
        [capture_session removeOutput:capture_output];
        [capture_session removeInput:capture_input];
        [capture_session commitConfiguration];
        WriteError("Failed to write WAV header.", error_utf8, error_utf8_capacity);
        return -22;
      }
    }

    [capture_session startRunning];
    if (![capture_session isRunning]) {
      [capture_output setSampleBufferDelegate:nil queue:nil];
      [capture_session beginConfiguration];
      [capture_session removeOutput:capture_output];
      [capture_session removeInput:capture_input];
      [capture_session commitConfiguration];
      if (wav_file != nullptr) {
        std::fclose(wav_file);
      }
#if TARGET_OS_IPHONE
      [audio_session setActive:NO error:nil];
#endif
      WriteError("Failed to start AVCaptureSession.", error_utf8, error_utf8_capacity);
      return -23;
    }

    stream_samples_.clear();
    stream_sample_limit_ =
        std::max<std::size_t>(sample_rate_hz * channel_count * 5,
                              static_cast<std::size_t>(frames_per_chunk) * channel_count * 16);

    target_channel_count_ = channel_count;
    target_format_ = target_format;
    wav_file_ = wav_file;
    wav_data_bytes_written_ = 0;
    wav_sample_rate_hz_ = sample_rate_hz;
    wav_channel_count_ = channel_count;

    capture_session_ = capture_session;
    capture_input_ = capture_input;
    capture_output_ = capture_output;
    capture_delegate_ = capture_delegate;
    capture_queue_ = capture_queue;
    capture_file_output_ = nil;
    capture_file_delegate_ = nil;
    audio_engine_ = nil;
    audio_engine_input_node_ = nil;
    recorder_backend_ = RecorderBackend::kCaptureSession;
    current_amplitude_dbfs_ = -90.0;
    max_amplitude_dbfs_ = -90.0;

    mode_ = mode;
    return 0;
  }

  static void OnCapturedSampleBufferThunk(void* context, CMSampleBufferRef sample_buffer) {
    if (context == nullptr) {
      return;
    }
    auto* self = reinterpret_cast<AppleAudioRecorderState*>(context);
    self->OnCapturedSampleBuffer(sample_buffer);
  }

  void OnCapturedSampleBuffer(CMSampleBufferRef sample_buffer) {
    if (sample_buffer == nullptr) {
      return;
    }

    AVAudioFormat* target_format = nil;
    uint32_t target_channel_count = 0;
    {
      std::lock_guard<std::mutex> lock(mutex_);
      if (mode_ == RecorderMode::kStopped || target_format_ == nil || target_channel_count_ == 0) {
        return;
      }
      target_format = target_format_;
      target_channel_count = target_channel_count_;
    }

    AVAudioPCMBuffer* input_buffer = CopySampleBufferToAudioPcmBuffer(sample_buffer);
    if (input_buffer == nil) {
      return;
    }

    AVAudioPCMBuffer* pcm16_buffer = ConvertToTargetPcm16(input_buffer, target_format);
    if (pcm16_buffer == nil) {
      return;
    }

    const auto frame_length = pcm16_buffer.frameLength;
    const auto sample_channels = static_cast<uint32_t>(pcm16_buffer.format.channelCount);
    if (frame_length == 0 || sample_channels == 0 || sample_channels != target_channel_count) {
      return;
    }

    int16_t* interleaved = pcm16_buffer.int16ChannelData[0];
    if (interleaved == nullptr) {
      return;
    }
    const auto sample_count = static_cast<std::size_t>(frame_length) * sample_channels;

    std::lock_guard<std::mutex> lock(mutex_);
    if (mode_ == RecorderMode::kStopped) {
      return;
    }

    AppendPcm16SamplesLocked(interleaved, sample_count);
  }

  void OnAudioEnginePcmBuffer(AVAudioPCMBuffer* input_buffer) {
    if (input_buffer == nil) {
      return;
    }

    AVAudioFormat* target_format = nil;
    uint32_t target_channel_count = 0;
    {
      std::lock_guard<std::mutex> lock(mutex_);
      if (mode_ == RecorderMode::kStopped || target_format_ == nil || target_channel_count_ == 0) {
        return;
      }
      target_format = target_format_;
      target_channel_count = target_channel_count_;
    }

    AVAudioPCMBuffer* pcm16_buffer = ConvertToTargetPcm16(input_buffer, target_format);
    if (pcm16_buffer == nil) {
      return;
    }

    const auto frame_length = pcm16_buffer.frameLength;
    const auto sample_channels = static_cast<uint32_t>(pcm16_buffer.format.channelCount);
    if (frame_length == 0 || sample_channels == 0 || sample_channels != target_channel_count) {
      return;
    }

    int16_t* interleaved = pcm16_buffer.int16ChannelData[0];
    if (interleaved == nullptr) {
      return;
    }
    const auto sample_count = static_cast<std::size_t>(frame_length) * sample_channels;

    std::lock_guard<std::mutex> lock(mutex_);
    if (mode_ == RecorderMode::kStopped) {
      return;
    }

    AppendPcm16SamplesLocked(interleaved, sample_count);
  }

  AVAudioPCMBuffer* ConvertToTargetPcm16(AVAudioPCMBuffer* input_buffer, AVAudioFormat* target_format) {
    if (input_buffer == nil || target_format == nil) {
      return nil;
    }
    if (IsPcm16InterleavedMatchingTarget(input_buffer.format, target_format)) {
      return input_buffer;
    }

    AVAudioConverter* converter =
        [[AVAudioConverter alloc] initFromFormat:input_buffer.format toFormat:target_format];
    if (converter == nil) {
      return nil;
    }

    const double input_sample_rate = input_buffer.format.sampleRate;
    const double output_sample_rate = target_format.sampleRate;
    const double ratio = input_sample_rate > 0 ? (output_sample_rate / input_sample_rate) : 1.0;
    const auto estimated_capacity = static_cast<AVAudioFrameCount>(
        std::max<double>(64.0, std::ceil(static_cast<double>(input_buffer.frameLength) * ratio) + 8.0));

    AVAudioPCMBuffer* converted =
        [[AVAudioPCMBuffer alloc] initWithPCMFormat:target_format frameCapacity:estimated_capacity];
    if (converted == nil) {
      return nil;
    }

    __block bool did_provide_input = false;
    NSError* conversion_error = nil;
    const AVAudioConverterOutputStatus status = [converter
        convertToBuffer:converted
                 error:&conversion_error
      withInputFromBlock:^AVAudioBuffer*(AVAudioPacketCount in_number_of_packets,
                                         AVAudioConverterInputStatus* out_status) {
        (void)in_number_of_packets;
        if (did_provide_input) {
          *out_status = AVAudioConverterInputStatus_NoDataNow;
          return nil;
        }
        did_provide_input = true;
        *out_status = AVAudioConverterInputStatus_HaveData;
        return input_buffer;
      }];

    if (status == AVAudioConverterOutputStatus_Error || conversion_error != nil) {
      return nil;
    }
    return converted;
  }

  void AppendPcm16SamplesLocked(const int16_t* samples, std::size_t sample_count) {
    if (samples == nullptr || sample_count == 0) {
      return;
    }

    UpdateAmplitudeLocked(samples, sample_count);

    if (mode_ == RecorderMode::kFile && wav_file_ != nullptr && target_format_ != nil &&
        target_channel_count_ > 0) {
      const auto bytes_to_write = sample_count * sizeof(int16_t);
      if (bytes_to_write > 0) {
        const std::size_t bytes_written = std::fwrite(samples, 1, bytes_to_write, wav_file_);
        if (bytes_written == bytes_to_write) {
          const auto remaining = std::numeric_limits<uint32_t>::max() - wav_data_bytes_written_;
          const auto bounded_write = static_cast<uint32_t>(
              std::min<std::size_t>(bytes_written, static_cast<std::size_t>(remaining)));
          wav_data_bytes_written_ += bounded_write;
        }
      }
      return;
    }

    if (mode_ == RecorderMode::kStream) {
      stream_samples_.insert(stream_samples_.end(), samples, samples + sample_count);
      if (stream_samples_.size() > stream_sample_limit_) {
        const auto overflow = stream_samples_.size() - stream_sample_limit_;
        stream_samples_.erase(stream_samples_.begin(), stream_samples_.begin() + overflow);
      }
    }
  }

  static double ComputeDbfs(const int16_t* samples, std::size_t sample_count) {
    if (samples == nullptr || sample_count == 0) {
      return -90.0;
    }

    double sum_squares = 0.0;
    for (std::size_t i = 0; i < sample_count; i++) {
      const double normalized = static_cast<double>(samples[i]) / 32768.0;
      sum_squares += normalized * normalized;
    }
    if (sum_squares <= 0.0) {
      return -90.0;
    }

    const double rms = std::sqrt(sum_squares / static_cast<double>(sample_count));
    if (!(rms > 0.0)) {
      return -90.0;
    }

    const double dbfs = 20.0 * std::log10(rms);
    if (!std::isfinite(dbfs)) {
      return -90.0;
    }

    return std::clamp(dbfs, -90.0, 0.0);
  }

  void UpdateAmplitudeLocked(const int16_t* samples, std::size_t sample_count) {
    const double dbfs = ComputeDbfs(samples, sample_count);
    current_amplitude_dbfs_ = dbfs;
    if (dbfs > max_amplitude_dbfs_) {
      max_amplitude_dbfs_ = dbfs;
    }
  }

  std::mutex mutex_;
  RecorderMode mode_ = RecorderMode::kStopped;
  std::deque<int16_t> stream_samples_;
  std::size_t stream_sample_limit_ = 0;

  uint32_t target_channel_count_ = 1;
  AVAudioFormat* target_format_ = nil;
  FILE* wav_file_ = nullptr;
  uint32_t wav_data_bytes_written_ = 0;
  uint32_t wav_sample_rate_hz_ = 0;
  uint32_t wav_channel_count_ = 0;
  double current_amplitude_dbfs_ = -90.0;
  double max_amplitude_dbfs_ = -90.0;
  RecorderBackend recorder_backend_ = RecorderBackend::kNone;

  AVCaptureSession* capture_session_ = nil;
  AVCaptureDeviceInput* capture_input_ = nil;
  AVCaptureAudioDataOutput* capture_output_ = nil;
  SpeechUtilsCaptureOutputDelegate* capture_delegate_ = nil;
  dispatch_queue_t capture_queue_ = nil;
  SpeechUtilsCaptureFileOutput* capture_file_output_ = nil;
  SpeechUtilsCaptureFileOutputDelegate* capture_file_delegate_ = nil;
  AVAudioEngine* audio_engine_ = nil;
  AVAudioInputNode* audio_engine_input_node_ = nil;
};

AppleAudioRecorderState g_recorder;

int32_t HasPermission(int32_t* out_has_permission, char* error_utf8,
                      uint32_t error_utf8_capacity) {
  WriteError("", error_utf8, error_utf8_capacity);
  @autoreleasepool {
    if (!EnsureAudioInputPermission(out_has_permission, false, error_utf8, error_utf8_capacity)) {
      return -1;
    }
  }
  return 0;
}

int32_t RequestPermission(int32_t* out_has_permission, char* error_utf8,
                          uint32_t error_utf8_capacity) {
  WriteError("", error_utf8, error_utf8_capacity);
  @autoreleasepool {
    if (!EnsureAudioInputPermission(out_has_permission, true, error_utf8, error_utf8_capacity)) {
      return -1;
    }
  }
  return 0;
}

int32_t ListInputDevicesJson(char* out_json_utf8, uint32_t out_json_capacity, char* error_utf8,
                             uint32_t error_utf8_capacity) {
  WriteError("", error_utf8, error_utf8_capacity);
  @autoreleasepool {
    return g_recorder.ListInputDevicesJson(out_json_utf8, out_json_capacity, error_utf8,
                                           error_utf8_capacity);
  }
}

int32_t StartFile(const speech_utils::recorder::RecorderStartConfig* start_config,
                  char* error_utf8,
                  uint32_t error_utf8_capacity) {
  WriteError("", error_utf8, error_utf8_capacity);
  if (start_config == nullptr) {
    WriteError("Start config pointer is null.", error_utf8, error_utf8_capacity);
    return -1;
  }
  @autoreleasepool {
    return g_recorder.StartFile(*start_config, error_utf8, error_utf8_capacity);
  }
}

int32_t StartStream(const speech_utils::recorder::RecorderStartConfig* start_config,
                    char* error_utf8,
                    uint32_t error_utf8_capacity) {
  WriteError("", error_utf8, error_utf8_capacity);
  if (start_config == nullptr) {
    WriteError("Start config pointer is null.", error_utf8, error_utf8_capacity);
    return -1;
  }
  @autoreleasepool {
    return g_recorder.StartStream(*start_config, error_utf8, error_utf8_capacity);
  }
}

int32_t ReadStreamPcm16(int16_t* out_samples, uint32_t out_sample_capacity,
                        uint32_t* out_samples_written, char* error_utf8,
                        uint32_t error_utf8_capacity) {
  WriteError("", error_utf8, error_utf8_capacity);
  return g_recorder.ReadStreamPcm16(out_samples, out_sample_capacity, out_samples_written,
                                    error_utf8, error_utf8_capacity);
}

int32_t Stop(char* error_utf8, uint32_t error_utf8_capacity) {
  WriteError("", error_utf8, error_utf8_capacity);
  return g_recorder.Stop(error_utf8, error_utf8_capacity);
}

int32_t Reset(char* error_utf8, uint32_t error_utf8_capacity) {
  WriteError("", error_utf8, error_utf8_capacity);
  return g_recorder.Reset(error_utf8, error_utf8_capacity);
}

int32_t IsRecording(int32_t* out_is_recording, char* error_utf8,
                    uint32_t error_utf8_capacity) {
  WriteError("", error_utf8, error_utf8_capacity);
  return g_recorder.IsRecording(out_is_recording, error_utf8, error_utf8_capacity);
}

int32_t GetAmplitude(double* out_current_dbfs, double* out_max_dbfs, char* error_utf8,
                     uint32_t error_utf8_capacity) {
  WriteError("", error_utf8, error_utf8_capacity);
  return g_recorder.GetAmplitude(out_current_dbfs, out_max_dbfs, error_utf8,
                                error_utf8_capacity);
}

}  // namespace speech_utils::apple_recorder
