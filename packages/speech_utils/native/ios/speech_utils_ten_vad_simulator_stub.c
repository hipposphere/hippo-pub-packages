#include "ten_vad_ffi_bridge.h"

static const char kTenVadSimulatorStubVersion[] = "ios-simulator-stub";

int ten_vad_create(ten_vad_handle_t* handle, unsigned long long hop_size, float threshold) {
  (void)hop_size;
  (void)threshold;
  if (handle != 0) {
    *handle = 0;
  }
  return -1;
}

int ten_vad_process(
    ten_vad_handle_t handle,
    const short* audio_data,
    unsigned long long audio_data_length,
    float* out_probability,
    int* out_flag) {
  (void)handle;
  (void)audio_data;
  (void)audio_data_length;
  if (out_probability != 0) {
    *out_probability = 0.0f;
  }
  if (out_flag != 0) {
    *out_flag = 0;
  }
  return -1;
}

int ten_vad_destroy(ten_vad_handle_t* handle) {
  if (handle != 0) {
    *handle = 0;
  }
  return 0;
}

const char* ten_vad_get_version(void) {
  return kTenVadSimulatorStubVersion;
}
