# dart_axum example

This example starts a small `dart_axum` server with:

- `GET /` for a plain-text hello world response
- `GET /playground` for an in-browser SSE, websocket, and multipart demo
- `GET /hello/:name?uppercase=true` for JSON with a path and query parameter
- `GET /users` and `GET /users/:userId` from a mounted users router in its own file
- `POST /users` for a typed JSON route definition backed by reusable OpenAPI components
- `GET /realtime/events/ticks` for a live SSE endpoint
- `WS /realtime/chat/:roomId` for websocket echo traffic
- `POST /uploads` for multipart form-data parsing and upload summaries
- `GET /openapi.json` for the generated OpenAPI document
- `GET /docs` for the built-in ReDoc UI

## Structure

- `bin/main.dart` only boots the app
- `lib/app.dart` wires the app and mounts routers
- `lib/routes/root_router.dart` contains top-level routes
- `lib/routes/realtime_router.dart` contains SSE and websocket endpoints
- `lib/routes/uploads_router.dart` contains multipart upload handling
- `lib/routes/users_router.dart` contains the `/users` subtree
- `lib/models/user_models.dart` contains the request/response types and typed route definition

## Run

From the monorepo root:

```bash
(cd packages/dart_axum/example && dart run bin/main.dart)
```

Or from this directory:

```bash
dart run bin/main.dart
```

## Try It

```bash
curl http://127.0.0.1:3000/
curl "http://127.0.0.1:3000/hello/Ada?uppercase=true"
curl http://127.0.0.1:3000/users
curl http://127.0.0.1:3000/users/ada
curl -N http://127.0.0.1:3000/realtime/events/ticks
curl \
  -X POST \
  -H "content-type: application/json" \
  -d '{"name":"Linus"}' \
  http://127.0.0.1:3000/users
curl \
  -F "owner=Ada" \
  -F "notes=Uploaded from curl" \
  -F "file=@README.md;type=text/plain" \
  http://127.0.0.1:3000/uploads
# Then open http://127.0.0.1:3000/docs in your browser.
# Or open http://127.0.0.1:3000/playground to exercise SSE, websockets, and multipart in one place.
```
