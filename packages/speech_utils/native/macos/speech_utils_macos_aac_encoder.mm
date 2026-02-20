#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreMedia/CoreMedia.h>
#import <Foundation/Foundation.h>
#import <dispatch/dispatch.h>

#include <algorithm>
#include <cstdint>
#include <cstring>
#include <string>

namespace {
std::string NSErrorToString(NSError* error) {
  if (error == nil) {
    return "unknown error";
  }

  std::string message;
  if (error.domain != nil) {
    message += [[error.domain description] UTF8String];
    message += " (";
    message += std::to_string(static_cast<long long>(error.code));
    message += ")";
  } else {
    message += "code ";
    message += std::to_string(static_cast<long long>(error.code));
  }

  if (error.localizedDescription != nil) {
    message += ": ";
    message += [[error localizedDescription] UTF8String];
  }

  NSError* underlying = error.userInfo[NSUnderlyingErrorKey];
  if (underlying != nil && underlying != error) {
    message += " | underlying: ";
    message += NSErrorToString(underlying);
  }

  return message;
}

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
  const std::string error_message = std::string(prefix) + ": " + NSErrorToString(error);
  WriteError(error_message, out_error_utf8, out_error_capacity);
}

void ResolveAudioParams(AVAssetTrack* track, double* out_sample_rate, int* out_channels) {
  if (out_sample_rate == nullptr || out_channels == nullptr) {
    return;
  }
  *out_sample_rate = 44100.0;
  *out_channels = 1;
  if (track == nil) {
    return;
  }

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
      return;
    }
  }
}
}  // namespace

extern "C" __attribute__((visibility("default"))) int32_t
speech_utils_macos_aac_encoder_healthcheck(char* error_utf8, uint32_t error_utf8_capacity) {
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
speech_utils_macos_encode_audio_file_to_aac(const char* input_path_utf8, const char* output_path_utf8,
                                            uint32_t bitrate_bps, char* error_utf8,
                                            uint32_t error_utf8_capacity) {
  WriteError("", error_utf8, error_utf8_capacity);
  if (input_path_utf8 == nullptr || output_path_utf8 == nullptr || bitrate_bps == 0) {
    WriteError("Invalid arguments for speech_utils_macos_encode_audio_file_to_aac.", error_utf8,
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

    if (![reader startReading]) {
      WriteNSError(reader.error, "AVAssetReader startReading failed", error_utf8,
                   error_utf8_capacity);
      return -9;
    }

    CMSampleBufferRef first_sample = [reader_output copyNextSampleBuffer];
    if (first_sample == nullptr) {
      if (reader.status == AVAssetReaderStatusFailed) {
        WriteNSError(reader.error, "AVAssetReader failed before first sample", error_utf8,
                     error_utf8_capacity);
        return -11;
      }
      WriteError("Input file yielded no decodable audio samples.", error_utf8, error_utf8_capacity);
      return -11;
    }

    NSDictionary* writer_settings = @{
      AVFormatIDKey : @(kAudioFormatMPEG4AAC),
      AVSampleRateKey : @(sample_rate),
      AVNumberOfChannelsKey : @(channels),
      AVEncoderBitRateKey : @(bitrate_bps),
    };
    CMFormatDescriptionRef source_format = CMSampleBufferGetFormatDescription(first_sample);
    AVAssetWriterInput* writer_input = nil;
    if (source_format != nullptr) {
      writer_input = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio
                                                         outputSettings:writer_settings
                                                       sourceFormatHint:source_format];
    } else {
      writer_input = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio
                                                         outputSettings:writer_settings];
    }
    if (![writer canAddInput:writer_input]) {
      CFRelease(first_sample);
      WriteError("Cannot add writer input for AAC output.", error_utf8, error_utf8_capacity);
      return -8;
    }
    writer_input.expectsMediaDataInRealTime = NO;
    [writer addInput:writer_input];

    if (![writer startWriting]) {
      CFRelease(first_sample);
      WriteNSError(writer.error, "AVAssetWriter startWriting failed", error_utf8,
                   error_utf8_capacity);
      [reader cancelReading];
      return -10;
    }

    CMTime start_time = CMSampleBufferGetPresentationTimeStamp(first_sample);
    if (!CMTIME_IS_VALID(start_time)) {
      start_time = kCMTimeZero;
    }
    [writer startSessionAtSourceTime:start_time];

    CMSampleBufferRef sample = first_sample;
    while (sample != nullptr) {
      while (![writer_input isReadyForMoreMediaData]) {
        if (reader.status == AVAssetReaderStatusFailed) {
          CFRelease(sample);
          [reader cancelReading];
          [writer cancelWriting];
          WriteNSError(reader.error, "AVAssetReader failed during transcode", error_utf8,
                       error_utf8_capacity);
          return -12;
        }
        if (writer.status == AVAssetWriterStatusFailed || writer.status == AVAssetWriterStatusCancelled) {
          CFRelease(sample);
          [reader cancelReading];
          [writer cancelWriting];
          WriteNSError(writer.error, "macOS AAC transcode failed", error_utf8, error_utf8_capacity);
          return -11;
        }
        [NSThread sleepForTimeInterval:0.001];
      }

      const BOOL append_ok = [writer_input appendSampleBuffer:sample];
      CFRelease(sample);
      if (!append_ok) {
        [writer_input markAsFinished];
        [reader cancelReading];
        [writer cancelWriting];
        WriteNSError(writer.error, "macOS AAC transcode failed", error_utf8, error_utf8_capacity);
        return -11;
      }

      sample = [reader_output copyNextSampleBuffer];
    }

    [writer_input markAsFinished];
    dispatch_semaphore_t done = dispatch_semaphore_create(0);
    [writer finishWritingWithCompletionHandler:^{
      dispatch_semaphore_signal(done);
    }];
    dispatch_semaphore_wait(done, DISPATCH_TIME_FOREVER);

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
