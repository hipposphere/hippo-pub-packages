// ignore_for_file: camel_case_types, non_constant_identifier_names

@ffi.DefaultAsset('package:dart_axum/src/ffi/dart_axum_bindings.dart')
library;

import 'dart:ffi' as ffi;

@ffi.Native<ffi.Pointer<ffi.Char> Function()>()
external ffi.Pointer<ffi.Char> dart_axum_version();

typedef dart_axum_dispatch_callback_t = ffi.Void Function(ffi.Pointer<ffi.Char>);

@ffi.Native<
  ffi.Pointer<ffi.Char> Function(ffi.Pointer<ffi.NativeFunction<dart_axum_dispatch_callback_t>>)
>()
external ffi.Pointer<ffi.Char> dart_axum_set_dispatch_callback(
  ffi.Pointer<ffi.NativeFunction<dart_axum_dispatch_callback_t>> callback,
);

@ffi.Native<
  ffi.Pointer<ffi.Char> Function(
    ffi.Pointer<ffi.Char>,
    ffi.Pointer<ffi.Int64>,
    ffi.Pointer<ffi.Uint16>,
  )
>()
external ffi.Pointer<ffi.Char> dart_axum_start_server(
  ffi.Pointer<ffi.Char> config_json_utf8,
  ffi.Pointer<ffi.Int64> out_server_id,
  ffi.Pointer<ffi.Uint16> out_port,
);

@ffi.Native<ffi.Pointer<ffi.Char> Function(ffi.Int64)>()
external ffi.Pointer<ffi.Char> dart_axum_stop_server(int server_id);

@ffi.Native<ffi.Pointer<ffi.Char> Function(ffi.Int64, ffi.Int64, ffi.Pointer<ffi.Char>)>()
external ffi.Pointer<ffi.Char> dart_axum_complete_http_request(
  int server_id,
  int request_id,
  ffi.Pointer<ffi.Char> response_json_utf8,
);

@ffi.Native<ffi.Pointer<ffi.Char> Function(ffi.Int64, ffi.Int64, ffi.Pointer<ffi.Char>)>()
external ffi.Pointer<ffi.Char> dart_axum_start_sse_response(
  int server_id,
  int request_id,
  ffi.Pointer<ffi.Char> response_json_utf8,
);

@ffi.Native<ffi.Pointer<ffi.Char> Function(ffi.Int64, ffi.Int64, ffi.Pointer<ffi.Char>)>()
external ffi.Pointer<ffi.Char> dart_axum_sse_send(
  int server_id,
  int stream_id,
  ffi.Pointer<ffi.Char> chunk_utf8,
);

@ffi.Native<ffi.Pointer<ffi.Char> Function(ffi.Int64, ffi.Int64)>()
external ffi.Pointer<ffi.Char> dart_axum_sse_close(int server_id, int stream_id);

@ffi.Native<ffi.Pointer<ffi.Char> Function(ffi.Int64, ffi.Int64, ffi.Pointer<ffi.Char>)>()
external ffi.Pointer<ffi.Char> dart_axum_websocket_send(
  int server_id,
  int socket_id,
  ffi.Pointer<ffi.Char> outbound_json_utf8,
);

@ffi.Native<ffi.Void Function(ffi.Pointer<ffi.Char>)>()
external void dart_axum_string_free(ffi.Pointer<ffi.Char> ptr);
