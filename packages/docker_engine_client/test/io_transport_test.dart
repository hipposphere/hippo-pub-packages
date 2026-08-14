import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:docker_engine_client/docker_engine_client.dart';
import 'package:test/test.dart';

void main() {
  test('Unix socket transport performs an HTTP request', () async {
    final directory = await Directory.systemTemp.createTemp('docker_engine_client_');
    final socketPath = '${directory.path}/docker.sock';
    final server = await ServerSocket.bind(
      InternetAddress(socketPath, type: InternetAddressType.unix),
      0,
    );
    final requestSeen = Completer<void>();
    server.listen((socket) {
      final requestBytes = <int>[];
      socket.listen((bytes) {
        requestBytes.addAll(bytes);
        if (!utf8.decode(requestBytes, allowMalformed: true).contains('\r\n\r\n')) return;
        if (!requestSeen.isCompleted) requestSeen.complete();
        socket.add(
          utf8.encode('HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nContent-Length: 2\r\n\r\nOK'),
        );
        unawaited(socket.close());
      });
    });
    final transport = DockerIoTransport.unixSocket(socketPath: socketPath);

    try {
      final response = await transport.send(const DockerRequest(method: 'GET', path: '/_ping'));
      await requestSeen.future;
      expect(response.statusCode, 200);
      expect(utf8.decode(response.body), 'OK');
    } finally {
      await transport.close();
      await server.close();
      await directory.delete(recursive: true);
    }
  }, skip: Platform.isWindows);
}
