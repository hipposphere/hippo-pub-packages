/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited 
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
import 'dart:async';
import 'dart:typed_data';
import 'dart:js_interop';
import 'package:web/web.dart' as web;

extension type FileWriterMessage._(JSObject o) implements JSObject {
  external FileWriterMessage({required JSString path, required JSArrayBuffer buffer});
  external JSString get path;
  external JSArrayBuffer get buffer;
}

class FileWriterService {
  final web.Worker _worker;

  FileWriterService() : _worker = web.Worker('file_writer_worker.js'.toJS);

  Future<void> writeFile(String path, Uint8List buffer) async {
    // 1) Grab the underlying JS ArrayBuffer
    final arrayBuf = buffer.buffer.toJS;

    // 2) Create our JS message object
    final msg = FileWriterMessage(path: path.toJS, buffer: arrayBuf);

    // 3) Send it, transferring the ArrayBuffer so it’s _moved_ not cloned
    _worker.postMessage(msg as JSAny);

    await Future.delayed(const Duration(milliseconds: 25));
  }

  void dispose() => _worker.terminate();
}
