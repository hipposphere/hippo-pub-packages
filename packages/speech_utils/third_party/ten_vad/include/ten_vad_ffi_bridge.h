// Thin TEN VAD bridge header for ffigen.
//
// We intentionally map `size_t` parameters to 64-bit unsigned integers so the
// generated Dart bindings stay small and predictable. TEN VAD supports the
// targets we bundle here (macOS + Windows x64), where `size_t` is 64-bit.

#ifndef TEN_VAD_FFI_BRIDGE_H
#define TEN_VAD_FFI_BRIDGE_H

#ifdef __cplusplus
extern "C" {
#endif

typedef void* ten_vad_handle_t;

int ten_vad_create(ten_vad_handle_t* handle, unsigned long long hop_size, float threshold);

int ten_vad_process(
    ten_vad_handle_t handle,
    const short* audio_data,
    unsigned long long audio_data_length,
    float* out_probability,
    int* out_flag);

int ten_vad_destroy(ten_vad_handle_t* handle);

const char* ten_vad_get_version(void);

#ifdef __cplusplus
}
#endif

#endif
