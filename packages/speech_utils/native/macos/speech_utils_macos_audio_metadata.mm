#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreMedia/CoreMedia.h>
#import <Foundation/Foundation.h>

#include <algorithm>
#include <climits>
#include <cmath>
#include <cstdint>
#include <cstring>
#include <string>

namespace {
void WriteError(const std::string& message, char* out_error_utf8, uint32_t out_error_capacity) {
  if (out_error_utf8 == nullptr || out_error_capacity == 0) {
    return;
  }
  const auto copy_length = static_cast<uint32_t>(
      std::min<std::size_t>(message.size(), static_cast<std::size_t>(out_error_capacity - 1)));
  std::memcpy(out_error_utf8, message.data(), copy_length);
  out_error_utf8[copy_length] = '\0';
}

bool ResolveAudioParams(AVAssetTrack* track, double* out_sample_rate, int* out_channels) {
  if (track == nil || out_sample_rate == nullptr || out_channels == nullptr) {
    return false;
  }

  *out_sample_rate = 0.0;
  *out_channels = 0;

  for (id format_description in track.formatDescriptions) {
    CMAudioFormatDescriptionRef audio_desc =
        (__bridge CMAudioFormatDescriptionRef)format_description;
    const AudioStreamBasicDescription* asbd =
        CMAudioFormatDescriptionGetStreamBasicDescription(audio_desc);
    if (asbd != nullptr) {
      if (asbd->mSampleRate > 0) {
        *out_sample_rate = asbd->mSampleRate;
      }
      if (asbd->mChannelsPerFrame > 0) {
        *out_channels = static_cast<int>(asbd->mChannelsPerFrame);
      }
      return true;
    }
  }
  return true;
}

int32_t ReadAudioMetadata(const char* input_path_utf8, int64_t* out_duration_micros,
                          int32_t* out_sample_rate_hz, int32_t* out_channel_count,
                          int32_t* out_bitrate_bps, char* error_utf8,
                          uint32_t error_utf8_capacity) {
  if (input_path_utf8 == nullptr || out_duration_micros == nullptr ||
      out_sample_rate_hz == nullptr || out_channel_count == nullptr ||
      out_bitrate_bps == nullptr) {
    WriteError("Invalid arguments for speech_utils_macos_read_audio_metadata.", error_utf8,
               error_utf8_capacity);
    return -1;
  }

  *out_duration_micros = -1;
  *out_sample_rate_hz = -1;
  *out_channel_count = -1;
  *out_bitrate_bps = -1;

  NSString* input_path = [NSString stringWithUTF8String:input_path_utf8];
  if (input_path.length == 0) {
    WriteError("Input path UTF-8 decoding failed.", error_utf8, error_utf8_capacity);
    return -2;
  }

  NSURL* input_url = [NSURL fileURLWithPath:input_path];
  AVURLAsset* asset = [AVURLAsset URLAssetWithURL:input_url options:nil];
  NSArray<AVAssetTrack*>* audio_tracks = [asset tracksWithMediaType:AVMediaTypeAudio];
  if (audio_tracks.count == 0) {
    WriteError("Input file does not contain an audio track.", error_utf8, error_utf8_capacity);
    return -3;
  }

  CMTime duration = asset.duration;
  if (!CMTIME_IS_VALID(duration) || duration.timescale <= 0 || duration.value < 0) {
    WriteError("Input audio duration is invalid or unavailable.", error_utf8, error_utf8_capacity);
    return -4;
  }
  *out_duration_micros = static_cast<int64_t>((duration.value * 1000000LL) / duration.timescale);

  AVAssetTrack* audio_track = audio_tracks.firstObject;
  double sample_rate = 0.0;
  int channels = 0;
  ResolveAudioParams(audio_track, &sample_rate, &channels);

  if (sample_rate > 0 && sample_rate <= static_cast<double>(INT32_MAX)) {
    *out_sample_rate_hz = static_cast<int32_t>(llround(sample_rate));
  }
  if (channels > 0) {
    *out_channel_count = channels;
  }

  const float estimated_data_rate = audio_track.estimatedDataRate;
  if (estimated_data_rate > 0 && estimated_data_rate <= static_cast<float>(INT32_MAX)) {
    *out_bitrate_bps = static_cast<int32_t>(llround(estimated_data_rate));
  }

  return 0;
}
}  // namespace

extern "C" __attribute__((visibility("default"))) int32_t
speech_utils_macos_audio_metadata_healthcheck(char* error_utf8, uint32_t error_utf8_capacity) {
  WriteError("", error_utf8, error_utf8_capacity);
  @autoreleasepool {
    if (NSClassFromString(@"AVURLAsset") == nil || NSClassFromString(@"AVAssetTrack") == nil) {
      WriteError("AVFoundation metadata classes are not available.", error_utf8,
                 error_utf8_capacity);
      return -1;
    }
  }
  return 0;
}

extern "C" __attribute__((visibility("default"))) int32_t
speech_utils_macos_read_audio_metadata(const char* input_path_utf8, int64_t* out_duration_micros,
                                       int32_t* out_sample_rate_hz, int32_t* out_channel_count,
                                       int32_t* out_bitrate_bps, char* error_utf8,
                                       uint32_t error_utf8_capacity) {
  WriteError("", error_utf8, error_utf8_capacity);
  @autoreleasepool {
    return ReadAudioMetadata(input_path_utf8, out_duration_micros, out_sample_rate_hz,
                             out_channel_count, out_bitrate_bps, error_utf8,
                             error_utf8_capacity);
  }
}
