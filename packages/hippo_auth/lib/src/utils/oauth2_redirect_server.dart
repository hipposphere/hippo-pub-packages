import 'dart:async';
import 'dart:io';

import 'package:hippo_auth/hippo_auth.dart';

/// A small loopback HTTP server that waits for an OAuth2 redirect
/// and captures the `code` and `state` query parameters.
class OAuth2RedirectServer {
  HttpServer? _server;
  final Completer<AuthSession> _completer = Completer<AuthSession>();

  /// Starts the server on an ephemeral port (random free port).
  /// Returns the redirect URI you must register with your IdP.
  Future<Uri> start() async {
    if (_server != null) {
      throw StateError('Server already running');
    }

    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _handleRequests();
    return Uri.parse(
      'http://${_server!.address.address}:${_server!.port}/callback',
    );
  }

  Future<void> stop() async {
    await _close();
  }

  /// Future that completes when the server receives a valid session.
  Future<AuthSession> get onSessionReceived => _completer.future;

  void _handleRequests() {
    _server!.listen((HttpRequest request) async {
      if (request.uri.path == '/callback') {
        final params = request.uri.queryParameters;
        final sessionId = params['session_id'];
        final token = params['token'];
        final expiresAt = params['expires_at'];
        final error = params['error'];

        if (error != null) {
          request.response
            ..statusCode = HttpStatus.ok
            ..headers.contentType = ContentType.html
            ..write('<h2>Login failed</h2><p>$error</p>')
            ..close();
          _completeWithError(StateError('OAuth2 error: $error'));
          return;
        }

        if (sessionId != null && token != null && expiresAt != null) {
          request.response
            ..statusCode = HttpStatus.ok
            ..headers.contentType = ContentType.html
            ..write('''
<!DOCTYPE html>
<html>
  <body style="font-family: sans-serif">
    <h2>Login successful</h2>
    <p>You can close this window.</p>
    <script>window.close();</script>
  </body>
</html>
''')
            ..close();

          await Future.delayed(const Duration(milliseconds: 500));

          _completeWithSession(
            AuthSession(
              id: sessionId,
              token: token,
              expiresAt: DateTime.parse(expiresAt),
            ),
          );
        } else {
          request.response
            ..statusCode = HttpStatus.badRequest
            ..write('Missing code or state')
            ..close();
        }
      } else {
        request.response
          ..statusCode = HttpStatus.notFound
          ..write('Not Found')
          ..close();
      }
    });
  }

  void _completeWithSession(AuthSession session) {
    if (!_completer.isCompleted) {
      _completer.complete(session);
    }
    _close();
  }

  void _completeWithError(Object error) {
    if (!_completer.isCompleted) {
      _completer.completeError(error);
    }
    _close();
  }

  /// Stops the server.
  Future<void> _close() async {
    await _server?.close(force: true);
    _server = null;
  }
}
