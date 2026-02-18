#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreMedia/CoreMedia.h>
#import <Foundation/Foundation.h>
#import <dispatch/dispatch.h>

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

void WriteNSError(NSError* error, const char* prefix, char* out_error_utf8,
                  uint32_t out_error_capacity) {
  if (error == nil) {
    WriteError(std::string(prefix) + ": unknown error", out_error_utf8, out_error_capacity);
    return;
  }
  const std::string error_message =
      std::string(prefix) + ": " + [[error localizedDescription] UTF8String];
  WriteError(error_message, out_error_utf8, out_error_capacity);
}

bool ResolveAudioParams(AVAssetTrack* track, double* out_sample_rate, int* out_channels) {
  if (track == nil || out_sample_rate == nullptr || out_channels == nullptr) {
    return false;
  }

  *out_sample_rate = 44100.0;
  *out_channels = 1;

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

bool ResolveAudioTrackMetadata(AVAssetTrack* track, int32_t* out_sample_rate_hz,
                               int32_t* out_channel_count, int32_t* out_bitrate_bps) {
  if (track == nil || out_sample_rate_hz == nullptr || out_channel_count == nullptr ||
      out_bitrate_bps == nullptr) {
    return false;
  }

  *out_sample_rate_hz = -1;
  *out_channel_count = -1;
  *out_bitrate_bps = -1;

  double sample_rate = 0.0;
  int channels = 0;
  ResolveAudioParams(track, &sample_rate, &channels);

  if (sample_rate > 0 && sample_rate <= static_cast<double>(INT32_MAX)) {
    *out_sample_rate_hz = static_cast<int32_t>(llround(sample_rate));
  }
  if (channels > 0) {
    *out_channel_count = channels;
  }

  const float estimated_data_rate = track.estimatedDataRate;
  if (estimated_data_rate > 0 && estimated_data_rate <= static_cast<float>(INT32_MAX)) {
    *out_bitrate_bps = static_cast<int32_t>(llround(estimated_data_rate));
  }

  return true;
}

int32_t ReadAudioMetadataFromFile(const char* input_path_utf8, int64_t* out_duration_micros,
                                  int32_t* out_sample_rate_hz, int32_t* out_channel_count,
                                  int32_t* out_bitrate_bps, char* error_utf8,
                                  uint32_t error_utf8_capacity) {
  if (input_path_utf8 == nullptr || out_duration_micros == nullptr ||
      out_sample_rate_hz == nullptr || out_channel_count == nullptr ||
      out_bitrate_bps == nullptr) {
    WriteError("Invalid arguments for ReadAudioMetadataFromFile.", error_utf8, error_utf8_capacity);
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
  if (!ResolveAudioTrackMetadata(audio_track, out_sample_rate_hz, out_channel_count,
                                 out_bitrate_bps)) {
    WriteError("Failed to resolve audio track metadata.", error_utf8, error_utf8_capacity);
    return -5;
  }

  return 0;
}
}  // namespace

extern "C" __attribute__((visibility("default"))) int32_t
speech_utils_ios_aac_encoder_healthcheck(char* error_utf8, uint32_t error_utf8_capacity) {
  WriteError("", error_utf8, error_utf8_capacity);
  @autoreleasepool {
    if (NSClassFromString(@"AVAssetReader") == nil || NSClassFromString(@"AVAssetWriter") == nil) {
      WriteError("AVFoundation encoder classes are not available.", error_utf8,
                 error_utf8_capacity);
      return -1;
    }
  }
  return 0;
}

extern "C" __attribute__((visibility("default"))) int32_t
speech_utils_ios_encode_audio_file_to_aac(const char* input_path_utf8, const char* output_path_utf8,
                                          uint32_t bitrate_bps, char* error_utf8,
                                          uint32_t error_utf8_capacity) {
  WriteError("", error_utf8, error_utf8_capacity);
  if (input_path_utf8 == nullptr || output_path_utf8 == nullptr || bitrate_bps == 0) {
    WriteError("Invalid arguments for speech_utils_ios_encode_audio_file_to_aac.", error_utf8,
               error_utf8_capacity);
    return -1;
  }

  @autoreleasepool {
    NSString* input_path = [NSString stringWithUTF8String:input_path_utf8];
    NSString* output_path = [NSString stringWithUTF8String:output_path_utf8];
    if (input_path.length == 0 || output_path.length == 0) {
      WriteError("Input/output path UTF-8 decoding failed.", error_utf8, error_utf8_capacity);
      return -2;
    }

    NSFileManager* file_manager = [NSFileManager defaultManager];
    if ([file_manager fileExistsAtPath:output_path]) {
      NSError* remove_error = nil;
      if (![file_manager removeItemAtPath:output_path error:&remove_error]) {
        WriteNSError(remove_error, "Failed to remove existing output file", error_utf8,
                     error_utf8_capacity);
        return -3;
      }
    }

    NSURL* input_url = [NSURL fileURLWithPath:input_path];
    NSURL* output_url = [NSURL fileURLWithPath:output_path];

    AVURLAsset* asset = [AVURLAsset URLAssetWithURL:input_url options:nil];
    NSArray<AVAssetTrack*>* audio_tracks = [asset tracksWithMediaType:AVMediaTypeAudio];
    if (audio_tracks.count == 0) {
      WriteError("Input file does not contain an audio track.", error_utf8, error_utf8_capacity);
      return -4;
    }
    AVAssetTrack* audio_track = audio_tracks.firstObject;

    NSError* read_error = nil;
    AVAssetReader* reader = [[AVAssetReader alloc] initWithAsset:asset error:&read_error];
    if (reader == nil) {
      WriteNSError(read_error, "Failed to create AVAssetReader", error_utf8, error_utf8_capacity);
      return -5;
    }

    NSDictionary* reader_settings = @{
      AVFormatIDKey : @(kAudioFormatLinearPCM),
      AVLinearPCMBitDepthKey : @16,
      AVLinearPCMIsFloatKey : @NO,
      AVLinearPCMIsBigEndianKey : @NO,
      AVLinearPCMIsNonInterleaved : @NO
    };
    AVAssetReaderTrackOutput* reader_output =
        [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:audio_track
                                                    outputSettings:reader_settings];
    reader_output.alwaysCopiesSampleData = NO;
    if (![reader canAddOutput:reader_output]) {
      WriteError("Cannot add reader output for input audio track.", error_utf8, error_utf8_capacity);
      return -6;
    }
    [reader addOutput:reader_output];

    double sample_rate = 44100.0;
    int channels = 1;
    ResolveAudioParams(audio_track, &sample_rate, &channels);

    NSError* write_error = nil;
    AVAssetWriter* writer =
        [[AVAssetWriter alloc] initWithURL:output_url fileType:AVFileTypeAppleM4A error:&write_error];
    if (writer == nil) {
      WriteNSError(write_error, "Failed to create AVAssetWriter", error_utf8, error_utf8_capacity);
      return -7;
    }

    NSDictionary* writer_settings = @{
      AVFormatIDKey : @(kAudioFormatMPEG4AAC),
      AVSampleRateKey : @(sample_rate),
      AVNumberOfChannelsKey : @(channels),
      AVEncoderBitRateKey : @(bitrate_bps)
    };
    AVAssetWriterInput* writer_input =
        [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio
                                            outputSettings:writer_settings];
    writer_input.expectsMediaDataInRealTime = NO;
    if (![writer canAddInput:writer_input]) {
      WriteError("Cannot add writer input for AAC output.", error_utf8, error_utf8_capacity);
      return -8;
    }
    [writer addInput:writer_input];

    if (![reader startReading]) {
      WriteNSError(reader.error, "AVAssetReader startReading failed", error_utf8,
                   error_utf8_capacity);
      return -9;
    }
    if (![writer startWriting]) {
      WriteNSError(writer.error, "AVAssetWriter startWriting failed", error_utf8,
                   error_utf8_capacity);
      [reader cancelReading];
      return -10;
    }
    [writer startSessionAtSourceTime:kCMTimeZero];

    dispatch_queue_t queue = dispatch_queue_create("speech_utils_ios_aac_encoder", DISPATCH_QUEUE_SERIAL);
    dispatch_semaphore_t done = dispatch_semaphore_create(0);
    __block NSError* block_error = nil;

    [writer_input requestMediaDataWhenReadyOnQueue:queue
                                        usingBlock:^{
                                          while ([writer_input isReadyForMoreMediaData]) {
                                            CMSampleBufferRef sample = [reader_output copyNextSampleBuffer];
                                            if (sample != nullptr) {
                                              const BOOL append_ok = [writer_input appendSampleBuffer:sample];
                                              CFRelease(sample);
                                              if (!append_ok) {
                                                block_error = writer.error;
                                                [writer_input markAsFinished];
                                                [reader cancelReading];
                                                [writer cancelWriting];
                                                dispatch_semaphore_signal(done);
                                                return;
                                              }
                                              continue;
                                            }

                                            [writer_input markAsFinished];
                                            [writer finishWritingWithCompletionHandler:^{
                                              if (writer.status != AVAssetWriterStatusCompleted) {
                                                block_error = writer.error;
                                              }
                                              dispatch_semaphore_signal(done);
                                            }];
                                            return;
                                          }
                                        }];

    dispatch_semaphore_wait(done, DISPATCH_TIME_FOREVER);

    if (block_error != nil) {
      WriteNSError(block_error, "iOS AAC transcode failed", error_utf8, error_utf8_capacity);
      return -11;
    }
    if (reader.status == AVAssetReaderStatusFailed) {
      WriteNSError(reader.error, "AVAssetReader failed during transcode", error_utf8,
                   error_utf8_capacity);
      return -12;
    }
    if (writer.status != AVAssetWriterStatusCompleted) {
      WriteNSError(writer.error, "AVAssetWriter did not complete transcode", error_utf8,
                   error_utf8_capacity);
      return -13;
    }
  }

  return 0;
}

extern "C" __attribute__((visibility("default"))) int32_t
speech_utils_ios_audio_metadata_healthcheck(char* error_utf8, uint32_t error_utf8_capacity) {
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
speech_utils_ios_read_audio_metadata(const char* input_path_utf8, int64_t* out_duration_micros,
                                     int32_t* out_sample_rate_hz, int32_t* out_channel_count,
                                     int32_t* out_bitrate_bps, char* error_utf8,
                                     uint32_t error_utf8_capacity) {
  WriteError("", error_utf8, error_utf8_capacity);
  @autoreleasepool {
    return ReadAudioMetadataFromFile(input_path_utf8, out_duration_micros, out_sample_rate_hz,
                                     out_channel_count, out_bitrate_bps, error_utf8,
                                     error_utf8_capacity);
  }
}
