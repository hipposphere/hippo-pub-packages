import 'dart:async';
import 'dart:io';

import 'package:hippo_auth/hippo_auth.dart';

class OAuth2RedirectPageConfig {
  final String? title;
  final String? documentTitle;
  final String? message;
  final String? logoUrl;

  const OAuth2RedirectPageConfig({
    this.title,
    this.documentTitle,
    this.message,
    this.logoUrl,
  });
}

class OAuth2RedirectServerConfig {
  final String? logoUrl;
  final OAuth2RedirectPageConfig success;
  final OAuth2RedirectPageConfig error;

  const OAuth2RedirectServerConfig({
    this.logoUrl,
    this.success = const OAuth2RedirectPageConfig(),
    this.error = const OAuth2RedirectPageConfig(),
  });
}

/// A small loopback HTTP server that waits for an OAuth2 redirect
/// and captures the `code` and `state` query parameters.
class OAuth2RedirectServer {
  OAuth2RedirectServer({this._config = const OAuth2RedirectServerConfig()});

  HttpServer? _server;
  final Completer<AuthSession> _completer = Completer<AuthSession>();
  final OAuth2RedirectServerConfig _config;

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
          await _writeHtmlResponse(
            request,
            _buildErrorPage(errorDetail: error),
          );
          _completeWithError(StateError('OAuth2 error: $error'));
          return;
        }

        if (sessionId != null && token != null && expiresAt != null) {
          await _writeHtmlResponse(request, _buildSuccessPage());

          await Future.delayed(const Duration(milliseconds: 500));

          _completeWithSession(
            AuthSession(
              id: sessionId,
              token: token,
              expiresAt: DateTime.parse(expiresAt),
            ),
          );
        } else {
          await _writeHtmlResponse(
            request,
            _buildErrorPage(errorDetail: 'Missing session parameters'),
            statusCode: HttpStatus.badRequest,
          );
        }
      } else {
        request.response
          ..statusCode = HttpStatus.notFound
          ..write('Not Found')
          ..close();
      }
    });
  }

  Future<void> _writeHtmlResponse(
    HttpRequest request,
    String html, {
    int statusCode = HttpStatus.ok,
  }) async {
    request.response
      ..statusCode = statusCode
      ..headers.contentType = ContentType.html
      ..write(html);
    await request.response.close();
  }

  String _buildSuccessPage() {
    final config = _config.success;
    final title = config.title ?? 'Login successful';
    final documentTitle = config.documentTitle ?? title;
    final message = config.message ?? 'You can close this window.';
    final logoUrl = config.logoUrl ?? _config.logoUrl;

    return _buildPage(
      documentTitle: documentTitle,
      title: title,
      message: message,
      logoUrl: logoUrl,
      accentColor: '#16a34a',
      showCloseButton: true,
      autoClose: true,
    );
  }

  String _buildErrorPage({String? errorDetail}) {
    final config = _config.error;
    final title = config.title ?? 'Login failed';
    final documentTitle = config.documentTitle ?? title;
    final message =
        config.message ?? 'Something went wrong while signing you in.';
    final logoUrl = config.logoUrl ?? _config.logoUrl;

    return _buildPage(
      documentTitle: documentTitle,
      title: title,
      message: message,
      logoUrl: logoUrl,
      accentColor: '#dc2626',
      detail: errorDetail,
      showCloseButton: true,
    );
  }

  String _buildPage({
    required String documentTitle,
    required String title,
    required String message,
    required String accentColor,
    String? logoUrl,
    String? detail,
    bool showCloseButton = false,
    bool autoClose = false,
  }) {
    final escapedDocumentTitle = _escapeHtml(documentTitle);
    final escapedTitle = _escapeHtml(title);
    final escapedMessage = _escapeHtml(message);
    final escapedLogoUrl = logoUrl == null ? null : _escapeHtml(logoUrl);
    final escapedDetail = detail == null ? null : _escapeHtml(detail);
    final logoMarkup = escapedLogoUrl == null
        ? ''
        : '<img class="logo" src="$escapedLogoUrl" alt="Logo" />';
    final detailMarkup = escapedDetail == null
        ? ''
        : '<div class="detail">Details: $escapedDetail</div>';
    final closeMarkup = showCloseButton
        ? '<button class="button" type="button" onclick="window.close()">Close window</button>'
        : '';
    final autoCloseScript = autoClose
        ? '<script>setTimeout(() => window.close(), 200);</script>'
        : '';

    return '''
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>$escapedDocumentTitle</title>
    <style>
      :root { color-scheme: light; }
      * { box-sizing: border-box; }
      body {
        margin: 0;
        min-height: 100vh;
        font-family: "Inter", "Segoe UI", "Helvetica Neue", Arial, sans-serif;
        background: radial-gradient(circle at top, #f8fafc 0%, #eef2ff 100%);
        color: #0f172a;
      }
      .container {
        min-height: 100vh;
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 28px;
      }
      .card {
        width: 100%;
        max-width: 460px;
        background: #ffffff;
        border-radius: 18px;
        padding: 32px 36px;
        border: 1px solid #e2e8f0;
        box-shadow: 0 22px 60px rgba(15, 23, 42, 0.18);
        text-align: center;
      }
      .accent {
        width: 56px;
        height: 6px;
        border-radius: 999px;
        margin: 0 auto 20px;
        background: $accentColor;
      }
      .logo {
        width: 72px;
        height: 72px;
        margin: 0 auto 16px;
        object-fit: contain;
      }
      h1 {
        margin: 0 0 12px;
        font-size: 22px;
        letter-spacing: -0.01em;
      }
      p {
        margin: 0;
        font-size: 15px;
        line-height: 1.6;
        color: #475569;
      }
      .detail {
        margin-top: 18px;
        padding: 12px 14px;
        border-radius: 12px;
        background: #f8fafc;
        border: 1px solid #e2e8f0;
        color: #64748b;
        font-size: 12px;
        word-break: break-word;
      }
      .button {
        margin-top: 22px;
        border: 0;
        border-radius: 999px;
        background: $accentColor;
        color: #ffffff;
        padding: 10px 18px;
        font-size: 14px;
        font-weight: 600;
        cursor: pointer;
      }
      .button:active { transform: translateY(1px); }
    </style>
  </head>
  <body>
    <div class="container">
      <div class="card">
        <div class="accent"></div>
        $logoMarkup
        <h1>$escapedTitle</h1>
        <p>$escapedMessage</p>
        $detailMarkup
        $closeMarkup
      </div>
    </div>
    $autoCloseScript
  </body>
</html>
''';
  }

  String _escapeHtml(String value) {
    return value
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
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
