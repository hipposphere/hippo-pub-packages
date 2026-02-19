#include <windows.h>

#include <mfapi.h>
#include <mferror.h>
#include <mfidl.h>
#include <mfreadwrite.h>
#include <propvarutil.h>
#include <wmcodecdsp.h>
#include <wrl/client.h>

#include <algorithm>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <cwctype>
#include <iomanip>
#include <limits>
#include <sstream>
#include <string>
#include <vector>

namespace {
using Microsoft::WRL::ComPtr;

void WriteError(const std::string& message, char* out_error_utf8, uint32_t out_error_capacity) {
  if (out_error_utf8 == nullptr || out_error_capacity == 0) {
    return;
  }

  const auto copy_length = static_cast<uint32_t>(
      std::min<std::size_t>(message.size(), static_cast<std::size_t>(out_error_capacity - 1)));
  std::memcpy(out_error_utf8, message.data(), copy_length);
  out_error_utf8[copy_length] = '\0';
}

void WriteOutputText(const std::string& value, char* out_utf8, uint32_t out_capacity) {
  if (out_utf8 == nullptr || out_capacity == 0) {
    return;
  }

  const auto copy_length = static_cast<uint32_t>(
      std::min<std::size_t>(value.size(), static_cast<std::size_t>(out_capacity - 1)));
  std::memcpy(out_utf8, value.data(), copy_length);
  out_utf8[copy_length] = '\0';
}

std::wstring Utf8ToWide(const char* utf8) {
  if (utf8 == nullptr) {
    return {};
  }

  const auto required =
      MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS, utf8, -1, nullptr, 0);
  if (required <= 0) {
    return {};
  }

  std::wstring wide(static_cast<std::size_t>(required), L'\0');
  const auto converted =
      MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS, utf8, -1, wide.data(), required);
  if (converted <= 0) {
    return {};
  }

  if (!wide.empty() && wide.back() == L'\0') {
    wide.pop_back();
  }
  return wide;
}

std::string WideToUtf8(const std::wstring& wide) {
  if (wide.empty()) {
    return {};
  }

  const auto required =
      WideCharToMultiByte(CP_UTF8, 0, wide.c_str(), -1, nullptr, 0, nullptr, nullptr);
  if (required <= 0) {
    return {};
  }

  std::string utf8(static_cast<std::size_t>(required), '\0');
  const auto converted = WideCharToMultiByte(
      CP_UTF8, 0, wide.c_str(), -1, utf8.data(), required, nullptr, nullptr);
  if (converted <= 0) {
    return {};
  }

  if (!utf8.empty() && utf8.back() == '\0') {
    utf8.pop_back();
  }
  return utf8;
}

std::string ExtractContainerFormatFromPath(const std::wstring& path) {
  if (path.empty()) {
    return {};
  }

  const auto slash_index = path.find_last_of(L"\\/");
  const auto dot_index = path.find_last_of(L'.');
  if (dot_index == std::wstring::npos || dot_index + 1 >= path.size()) {
    return {};
  }
  if (slash_index != std::wstring::npos && dot_index < slash_index) {
    return {};
  }

  std::wstring extension = path.substr(dot_index + 1);
  std::transform(extension.begin(), extension.end(), extension.begin(),
                 [](wchar_t ch) { return std::towlower(ch); });
  return WideToUtf8(extension);
}

std::string GuidToString(const GUID& guid) {
  wchar_t buffer[64] = {0};
  const int length =
      StringFromGUID2(guid, buffer, static_cast<int>(sizeof(buffer) / sizeof(buffer[0])));
  if (length <= 1) {
    return {};
  }
  return WideToUtf8(std::wstring(buffer, static_cast<std::size_t>(length - 1)));
}

std::string CodecNameFromSubtype(const GUID& subtype) {
  if (subtype == MFAudioFormat_AAC) {
    return "aac";
  }
  if (subtype == MFAudioFormat_MP3) {
    return "mp3";
  }
  if (subtype == MFAudioFormat_PCM) {
    return "pcm";
  }
  if (subtype == MFAudioFormat_Float) {
    return "pcm_float";
  }
  return GuidToString(subtype);
}

std::string AacProfileLevelIndicationToString(UINT32 profile_level_indication) {
  switch (profile_level_indication) {
    case 0x29:
      return "AAC-LC";
    default: {
      std::ostringstream ss;
      ss << "AAC-profile-level-0x" << std::uppercase << std::hex
         << profile_level_indication;
      return ss.str();
    }
  }
}

std::string HResultMessage(HRESULT hr, const char* context) {
  wchar_t* system_message = nullptr;
  const auto flags = FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM |
                     FORMAT_MESSAGE_IGNORE_INSERTS;
  const auto len =
      FormatMessageW(flags, nullptr, static_cast<DWORD>(hr), 0,
                     reinterpret_cast<LPWSTR>(&system_message), 0, nullptr);

  std::wstringstream ws;
  ws << L"[" << (context == nullptr ? "error" : context) << L"] HRESULT=0x" << std::hex
     << std::setw(8) << std::setfill(L'0') << static_cast<uint32_t>(hr);
  if (len > 0 && system_message != nullptr) {
    ws << L" " << system_message;
  }

  if (system_message != nullptr) {
    LocalFree(system_message);
  }

  return WideToUtf8(ws.str());
}

HRESULT ConfigureSourceReader(IMFSourceReader* reader, UINT32* out_sample_rate,
                              UINT32* out_channels, UINT32* out_bits_per_sample) {
  if (reader == nullptr || out_sample_rate == nullptr || out_channels == nullptr ||
      out_bits_per_sample == nullptr) {
    return E_INVALIDARG;
  }

  HRESULT hr = reader->SetStreamSelection(MF_SOURCE_READER_ALL_STREAMS, FALSE);
  if (FAILED(hr)) {
    return hr;
  }
  hr = reader->SetStreamSelection(MF_SOURCE_READER_FIRST_AUDIO_STREAM, TRUE);
  if (FAILED(hr)) {
    return hr;
  }

  ComPtr<IMFMediaType> pcm_media_type;
  hr = MFCreateMediaType(&pcm_media_type);
  if (FAILED(hr)) {
    return hr;
  }
  hr = pcm_media_type->SetGUID(MF_MT_MAJOR_TYPE, MFMediaType_Audio);
  if (FAILED(hr)) {
    return hr;
  }
  hr = pcm_media_type->SetGUID(MF_MT_SUBTYPE, MFAudioFormat_PCM);
  if (FAILED(hr)) {
    return hr;
  }
  // Prefer 16-bit PCM for downstream AAC encoder compatibility.
  hr = pcm_media_type->SetUINT32(MF_MT_AUDIO_BITS_PER_SAMPLE, 16);
  if (FAILED(hr)) {
    return hr;
  }

  hr = reader->SetCurrentMediaType(MF_SOURCE_READER_FIRST_AUDIO_STREAM, nullptr,
                                   pcm_media_type.Get());
  if (FAILED(hr)) {
    return hr;
  }

  ComPtr<IMFMediaType> actual_media_type;
  hr = reader->GetCurrentMediaType(MF_SOURCE_READER_FIRST_AUDIO_STREAM, &actual_media_type);
  if (FAILED(hr)) {
    return hr;
  }

  UINT32 sample_rate = 0;
  UINT32 channels = 0;
  UINT32 bits_per_sample = 16;
  hr = actual_media_type->GetUINT32(MF_MT_AUDIO_SAMPLES_PER_SECOND, &sample_rate);
  if (FAILED(hr)) {
    return hr;
  }
  hr = actual_media_type->GetUINT32(MF_MT_AUDIO_NUM_CHANNELS, &channels);
  if (FAILED(hr)) {
    return hr;
  }
  hr = actual_media_type->GetUINT32(MF_MT_AUDIO_BITS_PER_SAMPLE, &bits_per_sample);
  if (FAILED(hr)) {
    bits_per_sample = 16;
  }

  *out_sample_rate = sample_rate;
  *out_channels = channels;
  *out_bits_per_sample = bits_per_sample;
  return S_OK;
}

bool IsRetryableMediaTypeError(HRESULT hr) {
  return hr == MF_E_INVALIDMEDIATYPE || hr == MF_E_INVALIDTYPE || hr == MF_E_TOPO_CODEC_NOT_FOUND;
}

std::vector<UINT32> BuildBitrateCandidates(UINT32 requested_bps) {
  std::vector<UINT32> candidates;
  if (requested_bps > 0) {
    candidates.push_back(requested_bps);
  }

  // Common AAC bitrates that the Windows encoder usually accepts.
  const UINT32 defaults[] = {48000, 64000, 96000, 128000, 192000};
  for (const auto bps : defaults) {
    candidates.push_back(bps);
  }

  std::sort(candidates.begin(), candidates.end());
  candidates.erase(std::unique(candidates.begin(), candidates.end()), candidates.end());
  return candidates;
}

HRESULT BuildAacOutputMediaType(UINT32 sample_rate, UINT32 channels, UINT32 bitrate_bps,
                                bool set_payload_type, bool set_profile,
                                IMFMediaType** out_media_type) {
  if (out_media_type == nullptr || sample_rate == 0 || channels == 0 || bitrate_bps == 0) {
    return E_INVALIDARG;
  }

  ComPtr<IMFMediaType> output_media_type;
  HRESULT hr = MFCreateMediaType(&output_media_type);
  if (FAILED(hr)) {
    return hr;
  }
  hr = output_media_type->SetGUID(MF_MT_MAJOR_TYPE, MFMediaType_Audio);
  if (FAILED(hr)) {
    return hr;
  }
  hr = output_media_type->SetGUID(MF_MT_SUBTYPE, MFAudioFormat_AAC);
  if (FAILED(hr)) {
    return hr;
  }
  hr = output_media_type->SetUINT32(MF_MT_AUDIO_SAMPLES_PER_SECOND, sample_rate);
  if (FAILED(hr)) {
    return hr;
  }
  hr = output_media_type->SetUINT32(MF_MT_AUDIO_NUM_CHANNELS, channels);
  if (FAILED(hr)) {
    return hr;
  }
  hr = output_media_type->SetUINT32(MF_MT_AUDIO_AVG_BYTES_PER_SECOND, bitrate_bps / 8);
  if (FAILED(hr)) {
    return hr;
  }
  if (set_payload_type) {
    hr = output_media_type->SetUINT32(MF_MT_AAC_PAYLOAD_TYPE, 0);
    if (FAILED(hr)) {
      return hr;
    }
  }
  if (set_profile) {
    hr = output_media_type->SetUINT32(MF_MT_AAC_AUDIO_PROFILE_LEVEL_INDICATION, 0x29);
    if (FAILED(hr)) {
      return hr;
    }
  }

  *out_media_type = output_media_type.Detach();
  return S_OK;
}

HRESULT ConfigureSinkWriter(IMFSinkWriter* writer, UINT32 sample_rate, UINT32 channels,
                            UINT32 bits_per_sample, UINT32 bitrate_bps,
                            DWORD* out_stream_index) {
  if (writer == nullptr || out_stream_index == nullptr || sample_rate == 0 || channels == 0 ||
      bits_per_sample == 0 || bitrate_bps == 0) {
    return E_INVALIDARG;
  }

  HRESULT hr = S_OK;
  DWORD stream_index = 0;
  HRESULT last_add_stream_hr = E_FAIL;
  const auto bitrate_candidates = BuildBitrateCandidates(bitrate_bps);
  for (const auto candidate_bps : bitrate_candidates) {
    for (const bool set_profile : {false, true}) {
      for (const bool set_payload_type : {true, false}) {
        ComPtr<IMFMediaType> output_media_type;
        hr = BuildAacOutputMediaType(sample_rate, channels, candidate_bps, set_payload_type,
                                     set_profile, &output_media_type);
        if (FAILED(hr)) {
          return hr;
        }

        hr = writer->AddStream(output_media_type.Get(), &stream_index);
        if (SUCCEEDED(hr)) {
          last_add_stream_hr = S_OK;
          break;
        }
        last_add_stream_hr = hr;
        if (!IsRetryableMediaTypeError(hr)) {
          return hr;
        }
      }
      if (SUCCEEDED(last_add_stream_hr)) {
        break;
      }
    }
    if (SUCCEEDED(last_add_stream_hr)) {
      break;
    }
  }
  if (FAILED(last_add_stream_hr)) {
    return last_add_stream_hr;
  }

  ComPtr<IMFMediaType> input_media_type;
  hr = MFCreateMediaType(&input_media_type);
  if (FAILED(hr)) {
    return hr;
  }
  hr = input_media_type->SetGUID(MF_MT_MAJOR_TYPE, MFMediaType_Audio);
  if (FAILED(hr)) {
    return hr;
  }
  hr = input_media_type->SetGUID(MF_MT_SUBTYPE, MFAudioFormat_PCM);
  if (FAILED(hr)) {
    return hr;
  }
  hr = input_media_type->SetUINT32(MF_MT_AUDIO_SAMPLES_PER_SECOND, sample_rate);
  if (FAILED(hr)) {
    return hr;
  }
  hr = input_media_type->SetUINT32(MF_MT_AUDIO_NUM_CHANNELS, channels);
  if (FAILED(hr)) {
    return hr;
  }
  const UINT32 input_bits_per_sample = 16;
  hr = input_media_type->SetUINT32(MF_MT_AUDIO_BITS_PER_SAMPLE, input_bits_per_sample);
  if (FAILED(hr)) {
    return hr;
  }

  const UINT32 bytes_per_sample = input_bits_per_sample / 8;
  const UINT32 block_align = channels * bytes_per_sample;
  const UINT32 pcm_bytes_per_second = sample_rate * block_align;
  hr = input_media_type->SetUINT32(MF_MT_AUDIO_BLOCK_ALIGNMENT, block_align);
  if (FAILED(hr)) {
    return hr;
  }
  hr = input_media_type->SetUINT32(MF_MT_AUDIO_AVG_BYTES_PER_SECOND, pcm_bytes_per_second);
  if (FAILED(hr)) {
    return hr;
  }

  hr = writer->SetInputMediaType(stream_index, input_media_type.Get(), nullptr);
  if (FAILED(hr)) {
    return hr;
  }

  *out_stream_index = stream_index;
  return S_OK;
}

HRESULT EncodeAudioFileToAac(const std::wstring& input_path, const std::wstring& output_path,
                             UINT32 bitrate_bps) {
  HRESULT hr = S_OK;
  const HRESULT co_init_hr = CoInitializeEx(nullptr, COINIT_MULTITHREADED);
  const bool should_uninitialize =
      SUCCEEDED(co_init_hr) || co_init_hr == S_FALSE;
  if (FAILED(co_init_hr) && co_init_hr != RPC_E_CHANGED_MODE) {
    return co_init_hr;
  }

  hr = MFStartup(MF_VERSION, MFSTARTUP_FULL);
  if (FAILED(hr)) {
    if (should_uninitialize) {
      CoUninitialize();
    }
    return hr;
  }

  DeleteFileW(output_path.c_str());

  ComPtr<IMFSourceReader> source_reader;
  hr = MFCreateSourceReaderFromURL(input_path.c_str(), nullptr, &source_reader);
  if (SUCCEEDED(hr)) {
    UINT32 sample_rate = 0;
    UINT32 channels = 0;
    UINT32 bits_per_sample = 16;
    hr = ConfigureSourceReader(source_reader.Get(), &sample_rate, &channels, &bits_per_sample);

    ComPtr<IMFSinkWriter> sink_writer;
    DWORD sink_stream_index = 0;
    if (SUCCEEDED(hr)) {
      hr = MFCreateSinkWriterFromURL(output_path.c_str(), nullptr, nullptr, &sink_writer);
    }
    if (SUCCEEDED(hr)) {
      hr = ConfigureSinkWriter(sink_writer.Get(), sample_rate, channels, bits_per_sample,
                               bitrate_bps, &sink_stream_index);
    }
    if (SUCCEEDED(hr)) {
      hr = sink_writer->BeginWriting();
    }

    while (SUCCEEDED(hr)) {
      DWORD stream_index = 0;
      DWORD stream_flags = 0;
      LONGLONG timestamp = 0;
      ComPtr<IMFSample> sample;
      hr = source_reader->ReadSample(MF_SOURCE_READER_FIRST_AUDIO_STREAM, 0, &stream_index,
                                     &stream_flags, &timestamp, &sample);
      if (FAILED(hr)) {
        break;
      }

      if (sample != nullptr) {
        hr = sink_writer->WriteSample(sink_stream_index, sample.Get());
      }
      if (FAILED(hr)) {
        break;
      }

      if ((stream_flags & MF_SOURCE_READERF_ENDOFSTREAM) != 0) {
        break;
      }
    }

    if (SUCCEEDED(hr)) {
      hr = sink_writer->Finalize();
    }
  }

  const HRESULT shutdown_hr = MFShutdown();
  if (SUCCEEDED(hr) && FAILED(shutdown_hr)) {
    hr = shutdown_hr;
  }
  if (should_uninitialize) {
    CoUninitialize();
  }
  return hr;
}

HRESULT StartupAndShutdownMediaFoundation() {
  const HRESULT co_init_hr = CoInitializeEx(nullptr, COINIT_MULTITHREADED);
  const bool should_uninitialize =
      SUCCEEDED(co_init_hr) || co_init_hr == S_FALSE;
  if (FAILED(co_init_hr) && co_init_hr != RPC_E_CHANGED_MODE) {
    return co_init_hr;
  }

  HRESULT hr = MFStartup(MF_VERSION, MFSTARTUP_FULL);
  if (SUCCEEDED(hr)) {
    const HRESULT shutdown_hr = MFShutdown();
    if (FAILED(shutdown_hr)) {
      hr = shutdown_hr;
    }
  }

  if (should_uninitialize) {
    CoUninitialize();
  }
  return hr;
}

int32_t ToInt32OrSentinel(UINT32 value, int32_t sentinel) {
  if (value > static_cast<UINT32>(std::numeric_limits<int32_t>::max())) {
    return sentinel;
  }
  return static_cast<int32_t>(value);
}

HRESULT ReadAudioMetadata(const std::wstring& input_path, int64_t* out_duration_micros,
                          int32_t* out_sample_rate_hz, int32_t* out_channel_count,
                          int32_t* out_bitrate_bps, std::string* out_container_format,
                          std::string* out_codec, std::string* out_codec_profile) {
  if (out_duration_micros == nullptr || out_sample_rate_hz == nullptr ||
      out_channel_count == nullptr || out_bitrate_bps == nullptr ||
      out_container_format == nullptr || out_codec == nullptr ||
      out_codec_profile == nullptr) {
    return E_INVALIDARG;
  }

  *out_duration_micros = -1;
  *out_sample_rate_hz = -1;
  *out_channel_count = -1;
  *out_bitrate_bps = -1;
  out_container_format->clear();
  out_codec->clear();
  out_codec_profile->clear();
  *out_container_format = ExtractContainerFormatFromPath(input_path);

  HRESULT hr = S_OK;
  const HRESULT co_init_hr = CoInitializeEx(nullptr, COINIT_MULTITHREADED);
  const bool should_uninitialize = SUCCEEDED(co_init_hr) || co_init_hr == S_FALSE;
  if (FAILED(co_init_hr) && co_init_hr != RPC_E_CHANGED_MODE) {
    return co_init_hr;
  }

  hr = MFStartup(MF_VERSION, MFSTARTUP_FULL);
  if (FAILED(hr)) {
    if (should_uninitialize) {
      CoUninitialize();
    }
    return hr;
  }

  ComPtr<IMFSourceReader> source_reader;
  hr = MFCreateSourceReaderFromURL(input_path.c_str(), nullptr, &source_reader);
  if (SUCCEEDED(hr) && out_container_format->empty()) {
    PROPVARIANT mime_value;
    PropVariantInit(&mime_value);
    const HRESULT mime_hr = source_reader->GetPresentationAttribute(
        MF_SOURCE_READER_MEDIASOURCE, MF_PD_MIME_TYPE, &mime_value);
    if (SUCCEEDED(mime_hr) && mime_value.vt == VT_LPWSTR && mime_value.pwszVal != nullptr) {
      *out_container_format = WideToUtf8(mime_value.pwszVal);
    }
    PropVariantClear(&mime_value);
  }

  if (SUCCEEDED(hr)) {
    PROPVARIANT duration_value;
    PropVariantInit(&duration_value);
    const HRESULT duration_hr =
        source_reader->GetPresentationAttribute(MF_SOURCE_READER_MEDIASOURCE, MF_PD_DURATION,
                                                &duration_value);
    if (FAILED(duration_hr)) {
      hr = duration_hr;
    } else if (duration_value.vt != VT_UI8) {
      hr = E_FAIL;
    } else {
      *out_duration_micros = static_cast<int64_t>(duration_value.uhVal.QuadPart / 10ULL);
    }
    PropVariantClear(&duration_value);
  }

  if (SUCCEEDED(hr)) {
    ComPtr<IMFMediaType> native_media_type;
    if (SUCCEEDED(source_reader->GetNativeMediaType(MF_SOURCE_READER_FIRST_AUDIO_STREAM, 0,
                                                    &native_media_type))) {
      UINT32 avg_bytes_per_second = 0;
      if (SUCCEEDED(native_media_type->GetUINT32(MF_MT_AUDIO_AVG_BYTES_PER_SECOND,
                                                 &avg_bytes_per_second))) {
        const uint64_t bitrate = static_cast<uint64_t>(avg_bytes_per_second) * 8ULL;
        if (bitrate <= static_cast<uint64_t>(std::numeric_limits<int32_t>::max())) {
          *out_bitrate_bps = static_cast<int32_t>(bitrate);
        }
      }
      GUID subtype = GUID_NULL;
      if (SUCCEEDED(native_media_type->GetGUID(MF_MT_SUBTYPE, &subtype))) {
        *out_codec = CodecNameFromSubtype(subtype);
      }
      UINT32 profile_level_indication = 0;
      if (SUCCEEDED(native_media_type->GetUINT32(MF_MT_AAC_AUDIO_PROFILE_LEVEL_INDICATION,
                                                 &profile_level_indication))) {
        *out_codec_profile = AacProfileLevelIndicationToString(profile_level_indication);
        if (out_codec->empty()) {
          *out_codec = "aac";
        }
      }
    }
  }

  if (SUCCEEDED(hr)) {
    UINT32 sample_rate = 0;
    UINT32 channels = 0;
    UINT32 bits_per_sample = 16;
    hr = ConfigureSourceReader(source_reader.Get(), &sample_rate, &channels, &bits_per_sample);
    if (SUCCEEDED(hr)) {
      *out_sample_rate_hz = ToInt32OrSentinel(sample_rate, -1);
      *out_channel_count = ToInt32OrSentinel(channels, -1);
    }
  }

  const HRESULT shutdown_hr = MFShutdown();
  if (SUCCEEDED(hr) && FAILED(shutdown_hr)) {
    hr = shutdown_hr;
  }
  if (should_uninitialize) {
    CoUninitialize();
  }

  return hr;
}
}  // namespace

extern "C" __declspec(dllexport) int32_t speech_utils_windows_aac_encoder_healthcheck(
    char* error_utf8, uint32_t error_utf8_capacity) {
  WriteError("", error_utf8, error_utf8_capacity);
  const HRESULT hr = StartupAndShutdownMediaFoundation();
  if (FAILED(hr)) {
    WriteError(HResultMessage(hr, "Media Foundation healthcheck failed"), error_utf8,
               error_utf8_capacity);
  }
  return static_cast<int32_t>(hr);
}

extern "C" __declspec(dllexport) int32_t speech_utils_windows_encode_audio_file_to_aac(
    const char* input_path_utf8, const char* output_path_utf8, uint32_t bitrate_bps,
    char* error_utf8, uint32_t error_utf8_capacity) {
  WriteError("", error_utf8, error_utf8_capacity);

  if (input_path_utf8 == nullptr || output_path_utf8 == nullptr || bitrate_bps == 0) {
    WriteError("Invalid arguments for speech_utils_windows_encode_audio_file_to_aac", error_utf8,
               error_utf8_capacity);
    return static_cast<int32_t>(E_INVALIDARG);
  }

  const std::wstring input_path = Utf8ToWide(input_path_utf8);
  const std::wstring output_path = Utf8ToWide(output_path_utf8);
  if (input_path.empty() || output_path.empty()) {
    WriteError("Failed to decode UTF-8 path argument(s).", error_utf8, error_utf8_capacity);
    return static_cast<int32_t>(E_INVALIDARG);
  }

  const HRESULT hr = EncodeAudioFileToAac(input_path, output_path, bitrate_bps);
  if (FAILED(hr)) {
    WriteError(HResultMessage(hr, "Windows AAC transcode failed"), error_utf8,
               error_utf8_capacity);
  }
  return static_cast<int32_t>(hr);
}

extern "C" __declspec(dllexport) int32_t speech_utils_windows_audio_metadata_healthcheck(
    char* error_utf8, uint32_t error_utf8_capacity) {
  WriteError("", error_utf8, error_utf8_capacity);
  const HRESULT hr = StartupAndShutdownMediaFoundation();
  if (FAILED(hr)) {
    WriteError(HResultMessage(hr, "Windows audio metadata healthcheck failed"), error_utf8,
               error_utf8_capacity);
  }
  return static_cast<int32_t>(hr);
}

extern "C" __declspec(dllexport) int32_t speech_utils_windows_read_audio_metadata(
    const char* input_path_utf8, int64_t* out_duration_micros, int32_t* out_sample_rate_hz,
    int32_t* out_channel_count, int32_t* out_bitrate_bps, char* out_container_format_utf8,
    uint32_t out_container_format_utf8_capacity, char* out_codec_utf8,
    uint32_t out_codec_utf8_capacity, char* out_codec_profile_utf8,
    uint32_t out_codec_profile_utf8_capacity, char* error_utf8,
    uint32_t error_utf8_capacity) {
  WriteError("", error_utf8, error_utf8_capacity);
  WriteOutputText("", out_container_format_utf8, out_container_format_utf8_capacity);
  WriteOutputText("", out_codec_utf8, out_codec_utf8_capacity);
  WriteOutputText("", out_codec_profile_utf8, out_codec_profile_utf8_capacity);

  if (input_path_utf8 == nullptr || out_duration_micros == nullptr || out_sample_rate_hz == nullptr ||
      out_channel_count == nullptr || out_bitrate_bps == nullptr ||
      out_container_format_utf8 == nullptr || out_codec_utf8 == nullptr ||
      out_codec_profile_utf8 == nullptr) {
    WriteError("Invalid arguments for speech_utils_windows_read_audio_metadata", error_utf8,
               error_utf8_capacity);
    return static_cast<int32_t>(E_INVALIDARG);
  }

  const std::wstring input_path = Utf8ToWide(input_path_utf8);
  if (input_path.empty()) {
    WriteError("Failed to decode UTF-8 input path.", error_utf8, error_utf8_capacity);
    return static_cast<int32_t>(E_INVALIDARG);
  }

  std::string container_format;
  std::string codec;
  std::string codec_profile;
  const HRESULT hr = ReadAudioMetadata(input_path, out_duration_micros, out_sample_rate_hz,
                                       out_channel_count, out_bitrate_bps,
                                       &container_format, &codec, &codec_profile);
  WriteOutputText(container_format, out_container_format_utf8,
                  out_container_format_utf8_capacity);
  WriteOutputText(codec, out_codec_utf8, out_codec_utf8_capacity);
  WriteOutputText(codec_profile, out_codec_profile_utf8, out_codec_profile_utf8_capacity);
  if (FAILED(hr)) {
    WriteError(HResultMessage(hr, "Windows audio metadata read failed"), error_utf8,
               error_utf8_capacity);
  }
  return static_cast<int32_t>(hr);
}
