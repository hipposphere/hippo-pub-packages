import 'package:dart_axum/dart_axum.dart';

final AxumSchemaComponent _greetingComponent = AxumSchemaComponent.object(
  name: 'GreetingResponse',
  description: 'Greeting response payload.',
  properties: <String, AxumSchema>{
    'message': AxumSchema.string(description: 'Resolved greeting text.'),
    'uppercase': AxumSchema.boolean(description: 'Whether the greeting was uppercased.'),
  },
  required: const <String>{'message', 'uppercase'},
);

AxumRouter buildRootRouter() {
  return AxumRouter(
    build: (router) {
      router.get(
        '/',
        handler: (_) => AxumResponse.text(
          'Hello from dart_axum!\n'
          'Visit /docs for the generated API documentation.\n',
        ),
        docs: const AxumRouteDocs(
          summary: 'Hello world',
          description: 'A plain-text landing route.',
          responses: <int, AxumResponseDocs>{
            200: AxumResponseDocs(
              description: 'Plain-text welcome message.',
              schema: AxumSchema.string(description: 'Welcome message.'),
              contentType: 'text/plain; charset=utf-8',
            ),
          },
        ),
      );

      router.get('/playground', handler: (_) => AxumResponse.html(_playgroundHtml));

      router.get(
        '/hello/:name',
        handler: (context) {
          final uppercase = context.query('uppercase') == 'true';
          final name = context.params['name'] ?? 'world';
          final message = uppercase ? 'HELLO, ${name.toUpperCase()}!' : 'Hello, $name!';
          return AxumResponse.json(<String, Object?>{'message': message, 'uppercase': uppercase});
        },
        docs: AxumRouteDocs(
          summary: 'Greet a person',
          description: 'Demonstrates path parameters and a documented query parameter.',
          parameters: const <AxumParameterDocs>[
            AxumParameterDocs.query(
              'uppercase',
              description: 'Return the greeting in uppercase when true.',
              schema: AxumSchema.boolean(),
            ),
          ],
          responses: <int, AxumResponseDocs>{
            200: AxumResponseDocs(
              description: 'Greeting payload.',
              schema: _greetingComponent.reference,
              components: <AxumSchemaComponent>[_greetingComponent],
            ),
          },
        ),
      );
    },
  );
}

const String _playgroundHtml = '''
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>dart_axum Playground</title>
    <style>
      :root {
        color-scheme: light;
        font-family: "IBM Plex Sans", "Helvetica Neue", sans-serif;
        background: linear-gradient(160deg, #f5f0e8 0%, #d9efe6 100%);
        color: #14231d;
      }
      body {
        margin: 0;
        padding: 24px;
      }
      main {
        max-width: 1080px;
        margin: 0 auto;
        display: grid;
        gap: 20px;
      }
      .hero {
        background: rgba(255, 255, 255, 0.82);
        border: 1px solid rgba(20, 35, 29, 0.12);
        border-radius: 24px;
        padding: 24px;
        backdrop-filter: blur(14px);
        box-shadow: 0 20px 40px rgba(20, 35, 29, 0.08);
      }
      .grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
        gap: 20px;
      }
      .panel {
        background: rgba(255, 255, 255, 0.9);
        border-radius: 20px;
        padding: 20px;
        box-shadow: 0 16px 30px rgba(20, 35, 29, 0.08);
      }
      h1, h2 {
        margin-top: 0;
      }
      button, input, textarea {
        font: inherit;
      }
      button {
        border: none;
        border-radius: 999px;
        padding: 10px 16px;
        background: #194d3f;
        color: white;
        cursor: pointer;
      }
      input[type="text"], textarea {
        width: 100%;
        box-sizing: border-box;
        border-radius: 12px;
        border: 1px solid rgba(20, 35, 29, 0.2);
        padding: 10px 12px;
        background: rgba(255, 255, 255, 0.95);
      }
      pre {
        min-height: 180px;
        background: #14231d;
        color: #d9efe6;
        border-radius: 14px;
        padding: 14px;
        overflow: auto;
        white-space: pre-wrap;
      }
      form {
        display: grid;
        gap: 12px;
      }
      .row {
        display: flex;
        gap: 10px;
        align-items: center;
        flex-wrap: wrap;
      }
    </style>
  </head>
  <body>
    <main>
      <section class="hero">
        <h1>dart_axum Playground</h1>
        <p>This page exercises three server features from the example app: websocket chat, server-sent events, and multipart uploads.</p>
        <p>OpenAPI docs stay available at <a href="/docs">/docs</a>.</p>
      </section>
      <section class="grid">
        <article class="panel">
          <h2>SSE</h2>
          <p>Connects to <code>/realtime/events/ticks</code> and appends live events.</p>
          <div class="row">
            <button id="connect-sse" type="button">Connect SSE</button>
            <button id="disconnect-sse" type="button">Disconnect</button>
          </div>
          <pre id="sse-log"></pre>
        </article>
        <article class="panel">
          <h2>WebSocket</h2>
          <p>Connects to <code>/realtime/chat/playground</code> and echoes messages back.</p>
          <div class="row">
            <button id="connect-ws" type="button">Connect WebSocket</button>
            <button id="disconnect-ws" type="button">Disconnect</button>
          </div>
          <div class="row">
            <input id="ws-input" type="text" value="ping from browser" />
            <button id="send-ws" type="button">Send</button>
          </div>
          <pre id="ws-log"></pre>
        </article>
        <article class="panel">
          <h2>Multipart</h2>
          <p>Submits a multipart form to <code>/uploads</code>.</p>
          <form id="upload-form">
            <label>
              Owner
              <input name="owner" type="text" value="Ada" />
            </label>
            <label>
              Notes
              <textarea name="notes" rows="4">File uploaded from the built-in playground.</textarea>
            </label>
            <label>
              File
              <input name="file" type="file" />
            </label>
            <button type="submit">Upload</button>
          </form>
          <pre id="upload-log"></pre>
        </article>
      </section>
    </main>
    <script>
      const sseLog = document.getElementById('sse-log');
      const wsLog = document.getElementById('ws-log');
      const uploadLog = document.getElementById('upload-log');
      let source;
      let socket;

      const append = (target, value) => {
        target.textContent += value + "\\n";
        target.scrollTop = target.scrollHeight;
      };

      document.getElementById('connect-sse').addEventListener('click', () => {
        if (source) return;
        source = new EventSource('/realtime/events/ticks');
        append(sseLog, 'connecting...');
        source.addEventListener('tick', (event) => append(sseLog, `tick => \${event.data}`));
        source.addEventListener('heartbeat', (event) => append(sseLog, `heartbeat => \${event.data}`));
        source.onerror = () => append(sseLog, 'sse disconnected');
      });

      document.getElementById('disconnect-sse').addEventListener('click', () => {
        if (!source) return;
        source.close();
        source = null;
        append(sseLog, 'closed by browser');
      });

      document.getElementById('connect-ws').addEventListener('click', () => {
        if (socket && socket.readyState <= 1) return;
        socket = new WebSocket(`\${location.protocol === 'https:' ? 'wss' : 'ws'}://\${location.host}/realtime/chat/playground`);
        socket.onopen = () => append(wsLog, 'connected');
        socket.onmessage = (event) => append(wsLog, `recv => \${event.data}`);
        socket.onclose = () => append(wsLog, 'closed');
      });

      document.getElementById('disconnect-ws').addEventListener('click', () => {
        socket?.close();
      });

      document.getElementById('send-ws').addEventListener('click', () => {
        if (!socket || socket.readyState !== WebSocket.OPEN) {
          append(wsLog, 'socket is not open');
          return;
        }
        const value = document.getElementById('ws-input').value;
        socket.send(JSON.stringify({ kind: 'say', text: value }));
        append(wsLog, `sent => \${value}`);
      });

      document.getElementById('upload-form').addEventListener('submit', async (event) => {
        event.preventDefault();
        const formData = new FormData(event.currentTarget);
        const response = await fetch('/uploads', {
          method: 'POST',
          body: formData,
        });
        const text = await response.text();
        uploadLog.textContent = text;
      });
    </script>
  </body>
</html>
''';
