#ifndef SPEECH_UTILS_LINUX_AUDIO_RECORDER_API_H_
#define SPEECH_UTILS_LINUX_AUDIO_RECORDER_API_H_

#include <cstdint>
#include <string>

#include "../../include/speech_utils/recorder/recorder_start_config.h"

namespace speech_utils::linux_recorder {

void WriteError(const std::string& message, char* out_error_utf8, uint32_t out_error_capacity);

int32_t HasPermission(int32_t* out_has_permission, char* error_utf8, uint32_t error_utf8_capacity);

int32_t RequestPermission(int32_t* out_has_permission, char* error_utf8,
                          uint32_t error_utf8_capacity);

int32_t ListInputDevicesJson(char* out_json_utf8, uint32_t out_json_capacity, char* error_utf8,
                             uint32_t error_utf8_capacity);

int32_t StartFile(const speech_utils::recorder::RecorderStartConfig* start_config,
                  char* error_utf8,
                  uint32_t error_utf8_capacity);

int32_t StartStream(const speech_utils::recorder::RecorderStartConfig* start_config,
                    char* error_utf8,
                    uint32_t error_utf8_capacity);

int32_t SetContinousCapture(int32_t enabled,
                            const speech_utils::recorder::RecorderStartConfig* start_config,
                            char* error_utf8,
                            uint32_t error_utf8_capacity);

int32_t ReadStreamPcm16(int16_t* out_samples, uint32_t out_sample_capacity,
                        uint32_t* out_samples_written, char* error_utf8,
                        uint32_t error_utf8_capacity);

int32_t Stop(char* error_utf8, uint32_t error_utf8_capacity);
int32_t Reset(char* error_utf8, uint32_t error_utf8_capacity);

int32_t IsRecording(int32_t* out_is_recording, char* error_utf8, uint32_t error_utf8_capacity);

int32_t GetAmplitude(double* out_current_dbfs, double* out_max_dbfs, char* error_utf8,
                     uint32_t error_utf8_capacity);

}  // namespace speech_utils::linux_recorder

#endif  // SPEECH_UTILS_LINUX_AUDIO_RECORDER_API_H_
