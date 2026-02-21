#include "windows_aac_transcoder.h"

#include <algorithm>
#include <cerrno>
#include <cstdint>
#include <cstdlib>

#include "windows_ffmpeg_common.h"

extern "C" {
#include "libavcodec/avcodec.h"
#include "libavformat/avformat.h"
#include "libavutil/audio_fifo.h"
#include "libavutil/channel_layout.h"
#include "libavutil/samplefmt.h"
#include "libswresample/swresample.h"
}

namespace speech_utils::windows_encoding {
namespace {

int SelectBestSampleRate(const AVCodec* encoder, int requested_sample_rate) {
  if (requested_sample_rate <= 0) {
    requested_sample_rate = 48000;
  }
  if (encoder == nullptr || encoder->supported_samplerates == nullptr) {
    return requested_sample_rate;
  }

  int best = encoder->supported_samplerates[0];
  int best_distance = std::abs(requested_sample_rate - best);
  for (const int* sample_rate = encoder->supported_samplerates; *sample_rate != 0; sample_rate++) {
    if (*sample_rate == requested_sample_rate) {
      return requested_sample_rate;
    }

    const int distance = std::abs(requested_sample_rate - *sample_rate);
    if (distance < best_distance) {
      best = *sample_rate;
      best_distance = distance;
    }
  }

  return best;
}

int SelectBestChannelLayout(const AVCodec* encoder, int requested_channels,
                            AVChannelLayout* out_layout) {
  if (out_layout == nullptr) {
    return AVERROR(EINVAL);
  }

  av_channel_layout_uninit(out_layout);
  if (requested_channels <= 0) {
    requested_channels = 1;
  }

  if (encoder == nullptr || encoder->ch_layouts == nullptr || encoder->ch_layouts->nb_channels == 0) {
    av_channel_layout_default(out_layout, requested_channels);
    return 0;
  }

  const AVChannelLayout* best_layout = encoder->ch_layouts;
  for (const AVChannelLayout* layout = encoder->ch_layouts; layout->nb_channels != 0; layout++) {
    if (layout->nb_channels == requested_channels) {
      best_layout = layout;
      break;
    }
  }

  return av_channel_layout_copy(out_layout, best_layout);
}

int DrainEncoderPackets(AVCodecContext* encoder_context, AVFormatContext* output_context,
                        AVStream* output_stream, AVPacket* packet) {
  while (true) {
    const int receive_result = avcodec_receive_packet(encoder_context, packet);
    if (receive_result == AVERROR(EAGAIN) || receive_result == AVERROR_EOF) {
      return 0;
    }
    if (receive_result < 0) {
      return receive_result;
    }

    av_packet_rescale_ts(packet, encoder_context->time_base, output_stream->time_base);
    packet->stream_index = output_stream->index;

    const int write_result = av_interleaved_write_frame(output_context, packet);
    av_packet_unref(packet);
    if (write_result < 0) {
      return write_result;
    }
  }
}

int PushConvertedSamplesToFifo(AVFrame* decoded_frame, AVCodecContext* decoder_context,
                               AVCodecContext* encoder_context, SwrContext* swr_context,
                               AVAudioFifo* fifo) {
  const int dst_sample_count = av_rescale_rnd(
      swr_get_delay(swr_context, decoder_context->sample_rate) + decoded_frame->nb_samples,
      encoder_context->sample_rate, decoder_context->sample_rate, AV_ROUND_UP);
  if (dst_sample_count <= 0) {
    return AVERROR(EINVAL);
  }

  uint8_t** converted_data = nullptr;
  int result = av_samples_alloc_array_and_samples(
      &converted_data, nullptr, encoder_context->ch_layout.nb_channels, dst_sample_count,
      encoder_context->sample_fmt, 0);
  if (result < 0) {
    return result;
  }

  result = swr_convert(swr_context, converted_data, dst_sample_count,
                       const_cast<const uint8_t**>(decoded_frame->extended_data),
                       decoded_frame->nb_samples);
  if (result < 0) {
    av_freep(&converted_data[0]);
    av_freep(&converted_data);
    return result;
  }

  const int converted_samples = result;
  result = av_audio_fifo_realloc(fifo, av_audio_fifo_size(fifo) + converted_samples);
  if (result < 0) {
    av_freep(&converted_data[0]);
    av_freep(&converted_data);
    return result;
  }

  const int written_samples =
      av_audio_fifo_write(fifo, reinterpret_cast<void**>(converted_data), converted_samples);
  av_freep(&converted_data[0]);
  av_freep(&converted_data);

  if (written_samples < converted_samples) {
    return AVERROR(EIO);
  }

  return 0;
}

int EncodeFrameFromFifo(AVAudioFifo* fifo, AVCodecContext* encoder_context,
                        AVFormatContext* output_context, AVStream* output_stream,
                        AVPacket* output_packet, int read_samples, int frame_samples,
                        int64_t* next_pts) {
  AVFrame* frame = av_frame_alloc();
  if (frame == nullptr) {
    return AVERROR(ENOMEM);
  }

  frame->nb_samples = frame_samples;
  int result = av_channel_layout_copy(&frame->ch_layout, &encoder_context->ch_layout);
  if (result < 0) {
    av_frame_free(&frame);
    return result;
  }
  frame->format = encoder_context->sample_fmt;
  frame->sample_rate = encoder_context->sample_rate;

  result = av_frame_get_buffer(frame, 0);
  if (result < 0) {
    av_frame_free(&frame);
    return result;
  }

  if (frame_samples > read_samples) {
    result = av_samples_set_silence(frame->data, read_samples, frame_samples - read_samples,
                                    encoder_context->ch_layout.nb_channels, encoder_context->sample_fmt);
    if (result < 0) {
      av_frame_free(&frame);
      return result;
    }
  }

  const int fifo_read_count =
      av_audio_fifo_read(fifo, reinterpret_cast<void**>(frame->data), read_samples);
  if (fifo_read_count < read_samples) {
    av_frame_free(&frame);
    return AVERROR(EIO);
  }

  frame->pts = *next_pts;
  *next_pts += frame_samples;

  result = avcodec_send_frame(encoder_context, frame);
  av_frame_free(&frame);
  if (result < 0) {
    return result;
  }

  return DrainEncoderPackets(encoder_context, output_context, output_stream, output_packet);
}

int EncodeFifoToAac(AVAudioFifo* fifo, AVCodecContext* encoder_context,
                    AVFormatContext* output_context, AVStream* output_stream,
                    AVPacket* output_packet, int64_t* next_pts, bool flush) {
  const bool variable_frame_size =
      encoder_context->codec != nullptr &&
      (encoder_context->codec->capabilities & AV_CODEC_CAP_VARIABLE_FRAME_SIZE) != 0;
  const int codec_frame_size = encoder_context->frame_size > 0 ? encoder_context->frame_size : 1024;

  while (av_audio_fifo_size(fifo) >= (encoder_context->frame_size > 0 ? codec_frame_size : 1)) {
    const int read_samples =
        encoder_context->frame_size > 0 ? codec_frame_size : av_audio_fifo_size(fifo);
    const int result =
        EncodeFrameFromFifo(fifo, encoder_context, output_context, output_stream, output_packet,
                            read_samples, read_samples, next_pts);
    if (result < 0) {
      return result;
    }
  }

  if (flush && av_audio_fifo_size(fifo) > 0) {
    const int remaining_samples = av_audio_fifo_size(fifo);
    const bool needs_padding =
        encoder_context->frame_size > 0 && !variable_frame_size &&
        remaining_samples < codec_frame_size;
    const int frame_samples = needs_padding ? codec_frame_size : remaining_samples;

    const int result =
        EncodeFrameFromFifo(fifo, encoder_context, output_context, output_stream, output_packet,
                            remaining_samples, frame_samples, next_pts);
    if (result < 0) {
      return result;
    }
  }

  if (!flush) {
    return 0;
  }

  const int send_result = avcodec_send_frame(encoder_context, nullptr);
  if (send_result < 0 && send_result != AVERROR_EOF) {
    return send_result;
  }

  return DrainEncoderPackets(encoder_context, output_context, output_stream, output_packet);
}

}  // namespace

int32_t EncodeAudioFileToAac(const char* input_path_utf8, const char* output_path_utf8,
                             uint32_t bitrate_bps, char* error_utf8,
                             uint32_t error_utf8_capacity) {
  if (input_path_utf8 == nullptr || input_path_utf8[0] == '\0') {
    WriteError("Input path is null or empty.", error_utf8, error_utf8_capacity);
    return -1;
  }
  if (output_path_utf8 == nullptr || output_path_utf8[0] == '\0') {
    WriteError("Output path is null or empty.", error_utf8, error_utf8_capacity);
    return -2;
  }
  if (bitrate_bps == 0) {
    WriteError("Bitrate must be > 0.", error_utf8, error_utf8_capacity);
    return -3;
  }

  AVFormatContext* input_context = nullptr;
  AVCodecContext* decoder_context = nullptr;
  AVFormatContext* output_context = nullptr;
  AVCodecContext* encoder_context = nullptr;
  SwrContext* swr_context = nullptr;
  AVAudioFifo* fifo = nullptr;
  AVPacket* input_packet = nullptr;
  AVPacket* output_packet = nullptr;
  AVFrame* decoded_frame = nullptr;

  int audio_stream_index = -1;
  int ffmpeg_code = 0;
  int32_t result_code = 0;

  do {
    ffmpeg_code = avformat_open_input(&input_context, input_path_utf8, nullptr, nullptr);
    if (ffmpeg_code < 0) {
      WriteError("Failed to open input file: " + AvErrorToString(ffmpeg_code), error_utf8,
                 error_utf8_capacity);
      result_code = -10;
      break;
    }

    ffmpeg_code = avformat_find_stream_info(input_context, nullptr);
    if (ffmpeg_code < 0) {
      WriteError("Failed to read input stream info: " + AvErrorToString(ffmpeg_code), error_utf8,
                 error_utf8_capacity);
      result_code = -11;
      break;
    }

    ffmpeg_code = av_find_best_stream(input_context, AVMEDIA_TYPE_AUDIO, -1, -1, nullptr, 0);
    if (ffmpeg_code < 0) {
      WriteError("No audio stream found in input file.", error_utf8, error_utf8_capacity);
      result_code = -12;
      break;
    }
    audio_stream_index = ffmpeg_code;

    AVStream* input_stream = input_context->streams[audio_stream_index];
    const AVCodec* decoder = avcodec_find_decoder(input_stream->codecpar->codec_id);
    if (decoder == nullptr) {
      WriteError("No decoder available for input audio stream.", error_utf8, error_utf8_capacity);
      result_code = -13;
      break;
    }

    decoder_context = avcodec_alloc_context3(decoder);
    if (decoder_context == nullptr) {
      WriteError("Failed to allocate decoder context.", error_utf8, error_utf8_capacity);
      result_code = -14;
      break;
    }

    ffmpeg_code = avcodec_parameters_to_context(decoder_context, input_stream->codecpar);
    if (ffmpeg_code < 0) {
      WriteError("Failed to apply decoder parameters: " + AvErrorToString(ffmpeg_code),
                 error_utf8, error_utf8_capacity);
      result_code = -15;
      break;
    }

    ffmpeg_code = avcodec_open2(decoder_context, decoder, nullptr);
    if (ffmpeg_code < 0) {
      WriteError("Failed to open input decoder: " + AvErrorToString(ffmpeg_code), error_utf8,
                 error_utf8_capacity);
      result_code = -16;
      break;
    }

    const AVCodec* encoder = avcodec_find_encoder(AV_CODEC_ID_AAC);
    if (encoder == nullptr) {
      WriteError("AAC encoder (libavcodec) is not available.", error_utf8, error_utf8_capacity);
      result_code = -17;
      break;
    }

    ffmpeg_code = avformat_alloc_output_context2(&output_context, nullptr, nullptr, output_path_utf8);
    if (ffmpeg_code < 0 || output_context == nullptr) {
      WriteError("Failed to create output context: " + AvErrorToString(ffmpeg_code), error_utf8,
                 error_utf8_capacity);
      result_code = -18;
      break;
    }

    AVStream* output_stream = avformat_new_stream(output_context, nullptr);
    if (output_stream == nullptr) {
      WriteError("Failed to create output audio stream.", error_utf8, error_utf8_capacity);
      result_code = -19;
      break;
    }

    encoder_context = avcodec_alloc_context3(encoder);
    if (encoder_context == nullptr) {
      WriteError("Failed to allocate encoder context.", error_utf8, error_utf8_capacity);
      result_code = -20;
      break;
    }

    encoder_context->sample_rate = SelectBestSampleRate(encoder, decoder_context->sample_rate);
    const int requested_channels =
        decoder_context->ch_layout.nb_channels > 0 ? decoder_context->ch_layout.nb_channels : 1;
    ffmpeg_code = SelectBestChannelLayout(encoder, requested_channels, &encoder_context->ch_layout);
    if (ffmpeg_code < 0 || encoder_context->ch_layout.nb_channels <= 0) {
      WriteError("Failed to resolve output channel layout.", error_utf8, error_utf8_capacity);
      result_code = -21;
      break;
    }

    encoder_context->sample_fmt =
        encoder->sample_fmts != nullptr ? encoder->sample_fmts[0] : AV_SAMPLE_FMT_FLTP;
    encoder_context->bit_rate = static_cast<int64_t>(bitrate_bps);
    encoder_context->time_base = AVRational{1, encoder_context->sample_rate};
    encoder_context->profile = AV_PROFILE_AAC_LOW;

    if ((output_context->oformat->flags & AVFMT_GLOBALHEADER) != 0) {
      encoder_context->flags |= AV_CODEC_FLAG_GLOBAL_HEADER;
    }

    ffmpeg_code = avcodec_open2(encoder_context, encoder, nullptr);
    if (ffmpeg_code < 0) {
      WriteError("Failed to open AAC encoder: " + AvErrorToString(ffmpeg_code), error_utf8,
                 error_utf8_capacity);
      result_code = -22;
      break;
    }

    ffmpeg_code = avcodec_parameters_from_context(output_stream->codecpar, encoder_context);
    if (ffmpeg_code < 0) {
      WriteError("Failed to apply output stream parameters: " + AvErrorToString(ffmpeg_code),
                 error_utf8, error_utf8_capacity);
      result_code = -23;
      break;
    }
    output_stream->time_base = encoder_context->time_base;

    AVChannelLayout input_channel_layout = {};
    if (decoder_context->ch_layout.nb_channels > 0) {
      ffmpeg_code = av_channel_layout_copy(&input_channel_layout, &decoder_context->ch_layout);
      if (ffmpeg_code < 0) {
        WriteError("Failed to resolve input channel layout: " + AvErrorToString(ffmpeg_code),
                   error_utf8, error_utf8_capacity);
        result_code = -24;
        break;
      }
    } else {
      av_channel_layout_default(&input_channel_layout, 1);
    }

    ffmpeg_code = swr_alloc_set_opts2(
        &swr_context, &encoder_context->ch_layout, encoder_context->sample_fmt,
        encoder_context->sample_rate, &input_channel_layout, decoder_context->sample_fmt,
        decoder_context->sample_rate, 0, nullptr);
    av_channel_layout_uninit(&input_channel_layout);
    if (ffmpeg_code < 0 || swr_context == nullptr) {
      WriteError("Failed to allocate sample-rate converter.", error_utf8, error_utf8_capacity);
      result_code = -24;
      break;
    }

    ffmpeg_code = swr_init(swr_context);
    if (ffmpeg_code < 0) {
      WriteError("Failed to initialize sample-rate converter: " + AvErrorToString(ffmpeg_code),
                 error_utf8, error_utf8_capacity);
      result_code = -25;
      break;
    }

    fifo = av_audio_fifo_alloc(encoder_context->sample_fmt, encoder_context->ch_layout.nb_channels, 1);
    if (fifo == nullptr) {
      WriteError("Failed to allocate audio FIFO.", error_utf8, error_utf8_capacity);
      result_code = -26;
      break;
    }

    if ((output_context->oformat->flags & AVFMT_NOFILE) == 0) {
      ffmpeg_code = avio_open(&output_context->pb, output_path_utf8, AVIO_FLAG_WRITE);
      if (ffmpeg_code < 0) {
        WriteError("Failed to open output file: " + AvErrorToString(ffmpeg_code), error_utf8,
                   error_utf8_capacity);
        result_code = -27;
        break;
      }
    }

    ffmpeg_code = avformat_write_header(output_context, nullptr);
    if (ffmpeg_code < 0) {
      WriteError("Failed to write output header: " + AvErrorToString(ffmpeg_code), error_utf8,
                 error_utf8_capacity);
      result_code = -28;
      break;
    }

    input_packet = av_packet_alloc();
    output_packet = av_packet_alloc();
    decoded_frame = av_frame_alloc();
    if (input_packet == nullptr || output_packet == nullptr || decoded_frame == nullptr) {
      WriteError("Failed to allocate FFmpeg packet/frame state.", error_utf8, error_utf8_capacity);
      result_code = -29;
      break;
    }

    int64_t next_pts = 0;

    while (true) {
      ffmpeg_code = av_read_frame(input_context, input_packet);
      if (ffmpeg_code == AVERROR_EOF) {
        break;
      }
      if (ffmpeg_code < 0) {
        WriteError("Failed to read input audio frame: " + AvErrorToString(ffmpeg_code),
                   error_utf8, error_utf8_capacity);
        result_code = -30;
        break;
      }

      if (input_packet->stream_index != audio_stream_index) {
        av_packet_unref(input_packet);
        continue;
      }

      ffmpeg_code = avcodec_send_packet(decoder_context, input_packet);
      av_packet_unref(input_packet);
      if (ffmpeg_code < 0) {
        WriteError("Failed to send packet to decoder: " + AvErrorToString(ffmpeg_code),
                   error_utf8, error_utf8_capacity);
        result_code = -31;
        break;
      }

      while (true) {
        ffmpeg_code = avcodec_receive_frame(decoder_context, decoded_frame);
        if (ffmpeg_code == AVERROR(EAGAIN) || ffmpeg_code == AVERROR_EOF) {
          break;
        }
        if (ffmpeg_code < 0) {
          WriteError("Failed to decode audio frame: " + AvErrorToString(ffmpeg_code),
                     error_utf8, error_utf8_capacity);
          result_code = -32;
          break;
        }

        ffmpeg_code = PushConvertedSamplesToFifo(decoded_frame, decoder_context, encoder_context,
                                                 swr_context, fifo);
        av_frame_unref(decoded_frame);
        if (ffmpeg_code < 0) {
          WriteError("Failed to convert audio samples: " + AvErrorToString(ffmpeg_code),
                     error_utf8, error_utf8_capacity);
          result_code = -33;
          break;
        }

        ffmpeg_code = EncodeFifoToAac(fifo, encoder_context, output_context, output_stream,
                                      output_packet, &next_pts, false);
        if (ffmpeg_code < 0) {
          WriteError("Failed to encode AAC frame: " + AvErrorToString(ffmpeg_code), error_utf8,
                     error_utf8_capacity);
          result_code = -34;
          break;
        }
      }

      if (result_code != 0) {
        break;
      }
    }

    if (result_code != 0) {
      break;
    }

    ffmpeg_code = avcodec_send_packet(decoder_context, nullptr);
    if (ffmpeg_code < 0) {
      WriteError("Failed to flush decoder: " + AvErrorToString(ffmpeg_code), error_utf8,
                 error_utf8_capacity);
      result_code = -35;
      break;
    }

    while (true) {
      ffmpeg_code = avcodec_receive_frame(decoder_context, decoded_frame);
      if (ffmpeg_code == AVERROR(EAGAIN) || ffmpeg_code == AVERROR_EOF) {
        break;
      }
      if (ffmpeg_code < 0) {
        WriteError("Failed while draining decoder: " + AvErrorToString(ffmpeg_code), error_utf8,
                   error_utf8_capacity);
        result_code = -36;
        break;
      }

      ffmpeg_code = PushConvertedSamplesToFifo(decoded_frame, decoder_context, encoder_context,
                                               swr_context, fifo);
      av_frame_unref(decoded_frame);
      if (ffmpeg_code < 0) {
        WriteError("Failed to convert tail audio samples: " + AvErrorToString(ffmpeg_code),
                   error_utf8, error_utf8_capacity);
        result_code = -37;
        break;
      }
    }

    if (result_code != 0) {
      break;
    }

    ffmpeg_code = EncodeFifoToAac(fifo, encoder_context, output_context, output_stream,
                                  output_packet, &next_pts, true);
    if (ffmpeg_code < 0) {
      WriteError("Failed to flush AAC encoder: " + AvErrorToString(ffmpeg_code), error_utf8,
                 error_utf8_capacity);
      result_code = -38;
      break;
    }

    ffmpeg_code = av_write_trailer(output_context);
    if (ffmpeg_code < 0) {
      WriteError("Failed to write output trailer: " + AvErrorToString(ffmpeg_code), error_utf8,
                 error_utf8_capacity);
      result_code = -39;
      break;
    }
  } while (false);

  if (decoded_frame != nullptr) {
    av_frame_free(&decoded_frame);
  }
  if (input_packet != nullptr) {
    av_packet_free(&input_packet);
  }
  if (output_packet != nullptr) {
    av_packet_free(&output_packet);
  }
  if (fifo != nullptr) {
    av_audio_fifo_free(fifo);
  }
  if (swr_context != nullptr) {
    swr_free(&swr_context);
  }
  if (decoder_context != nullptr) {
    avcodec_free_context(&decoder_context);
  }
  if (encoder_context != nullptr) {
    avcodec_free_context(&encoder_context);
  }
  if (input_context != nullptr) {
    avformat_close_input(&input_context);
  }
  if (output_context != nullptr) {
    if ((output_context->oformat->flags & AVFMT_NOFILE) == 0 && output_context->pb != nullptr) {
      avio_closep(&output_context->pb);
    }
    avformat_free_context(output_context);
  }

  return result_code;
}

int32_t AacEncoderHealthcheck(char* error_utf8, uint32_t error_utf8_capacity) {
  const AVCodec* encoder = avcodec_find_encoder(AV_CODEC_ID_AAC);
  if (encoder == nullptr) {
    WriteError("AAC encoder (libavcodec) is unavailable.", error_utf8, error_utf8_capacity);
    return -1;
  }

  return 0;
}

}  // namespace speech_utils::windows_encoding
