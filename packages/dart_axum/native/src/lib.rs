use std::collections::HashMap;
use std::ffi::{CStr, CString, c_char};
use std::net::SocketAddr;
use std::ptr;
use std::sync::atomic::{AtomicI64, Ordering};
use std::sync::{Arc, Mutex, OnceLock};

use axum::Router;
use axum::body::{Body, to_bytes};
use axum::extract::ws::{CloseFrame, Message, WebSocket, WebSocketUpgrade};
use axum::extract::{ConnectInfo, FromRequestParts, Request, State};
use axum::http::header::{CONNECTION, UPGRADE};
use axum::http::{HeaderMap, HeaderName, HeaderValue, StatusCode};
use axum::response::{IntoResponse, Response};
use base64::Engine as _;
use base64::engine::general_purpose::STANDARD as BASE64;
use futures_util::{SinkExt, StreamExt};
use serde::{Deserialize, Serialize};
use tokio::net::TcpListener;
use tokio::runtime::{Builder, Runtime};
use tokio::sync::{mpsc, oneshot};

type DispatchCallback = extern "C" fn(*mut c_char);

static DISPATCH_CALLBACK: OnceLock<Mutex<Option<DispatchCallback>>> = OnceLock::new();
static SERVERS: OnceLock<Mutex<HashMap<i64, ServerRecord>>> = OnceLock::new();
static NEXT_SERVER_ID: AtomicI64 = AtomicI64::new(1);
static NEXT_REQUEST_ID: AtomicI64 = AtomicI64::new(1);
static NEXT_SOCKET_ID: AtomicI64 = AtomicI64::new(1);

struct ServerRecord {
    runtime: Runtime,
    shared: Arc<ServerShared>,
    shutdown_tx: Option<oneshot::Sender<()>>,
}

struct ServerShared {
    server_id: i64,
    max_body_bytes: usize,
    pending_requests: Mutex<HashMap<i64, oneshot::Sender<HttpResponsePayload>>>,
    sockets: Mutex<HashMap<i64, mpsc::UnboundedSender<Message>>>,
}

#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
struct StartServerConfig {
    host: String,
    port: u16,
    max_body_bytes: usize,
}

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
struct HttpRequestEvent {
    kind: &'static str,
    server_id: i64,
    request_id: i64,
    method: String,
    path: String,
    raw_query: String,
    headers: HashMap<String, Vec<String>>,
    body_base64: String,
    remote_address: String,
}

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
struct WebSocketOpenEvent {
    kind: &'static str,
    server_id: i64,
    socket_id: i64,
    path: String,
    raw_query: String,
    headers: HashMap<String, Vec<String>>,
    remote_address: String,
}

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
struct WebSocketTextEvent {
    kind: &'static str,
    server_id: i64,
    socket_id: i64,
    opcode: &'static str,
    text: String,
}

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
struct WebSocketBinaryEvent {
    kind: &'static str,
    server_id: i64,
    socket_id: i64,
    opcode: &'static str,
    data_base64: String,
}

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
struct WebSocketCloseEvent {
    kind: &'static str,
    server_id: i64,
    socket_id: i64,
    code: Option<u16>,
    reason: Option<String>,
}

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
struct ServerErrorEvent {
    kind: &'static str,
    server_id: i64,
    message: String,
}

#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
struct HttpResponsePayloadJson {
    status: u16,
    #[serde(default)]
    headers: HashMap<String, Vec<String>>,
    #[serde(default)]
    body_base64: String,
}

#[derive(Debug)]
struct HttpResponsePayload {
    status: u16,
    headers: HashMap<String, Vec<String>>,
    body: Vec<u8>,
}

#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
struct OutboundWebSocketFrame {
    kind: String,
    text: Option<String>,
    data_base64: Option<String>,
    code: Option<u16>,
    reason: Option<String>,
}

fn dispatch_callback_slot() -> &'static Mutex<Option<DispatchCallback>> {
    DISPATCH_CALLBACK.get_or_init(|| Mutex::new(None))
}

fn servers() -> &'static Mutex<HashMap<i64, ServerRecord>> {
    SERVERS.get_or_init(|| Mutex::new(HashMap::new()))
}

fn ok_ptr() -> *mut c_char {
    ptr::null_mut()
}

fn error_ptr(message: impl Into<String>) -> *mut c_char {
    let sanitized = message.into().replace('\0', "\\0");
    CString::new(sanitized)
        .map(CString::into_raw)
        .unwrap_or_else(|_| {
            CString::new("Failed to encode error message")
                .unwrap()
                .into_raw()
        })
}

fn c_str_to_string(pointer: *const c_char, argument_name: &str) -> Result<String, String> {
    if pointer.is_null() {
        return Err(format!("{argument_name} pointer was null"));
    }
    // SAFETY: The pointer is provided by Dart as a valid UTF-8 null-terminated string.
    let value = unsafe { CStr::from_ptr(pointer) };
    value
        .to_str()
        .map(|string| string.to_owned())
        .map_err(|error| format!("{argument_name} was not valid UTF-8: {error}"))
}

fn header_map_to_multimap(headers: &HeaderMap) -> HashMap<String, Vec<String>> {
    let mut map = HashMap::<String, Vec<String>>::new();
    for (name, value) in headers.iter() {
        map.entry(name.as_str().to_owned())
            .or_default()
            .push(value.to_str().unwrap_or_default().to_owned());
    }
    map
}

fn status_response(status: StatusCode, body: impl Into<String>) -> Response {
    let message = body.into();
    Response::builder()
        .status(status)
        .header("content-type", "text/plain; charset=utf-8")
        .body(Body::from(message))
        .unwrap_or_else(|_| {
            Response::builder()
                .status(StatusCode::INTERNAL_SERVER_ERROR)
                .body(Body::from("Failed to build response"))
                .unwrap()
        })
}

fn dispatch_event<T: Serialize>(event: &T) -> Result<(), String> {
    let callback = {
        let guard = dispatch_callback_slot()
            .lock()
            .map_err(|_| "Dispatch callback mutex was poisoned".to_owned())?;
        *guard
    };
    let callback = callback.ok_or_else(|| "Dispatch callback is not installed".to_owned())?;
    let payload = serde_json::to_string(event)
        .map_err(|error| format!("Failed to serialize event: {error}"))?;
    let payload =
        CString::new(payload).map_err(|error| format!("Invalid event payload: {error}"))?;
    callback(payload.into_raw());
    Ok(())
}

async fn dispatch_request(
    State(state): State<Arc<ServerShared>>,
    ConnectInfo(remote): ConnectInfo<SocketAddr>,
    request: Request,
) -> Response {
    if is_websocket_request(request.headers()) {
        let (mut parts, body) = request.into_parts();
        if let Ok(upgrade) = WebSocketUpgrade::from_request_parts(&mut parts, &state).await {
            let path = parts.uri.path().to_owned();
            let raw_query = parts.uri.query().unwrap_or_default().to_owned();
            let headers = header_map_to_multimap(&parts.headers);
            let remote_address = remote.to_string();
            return upgrade
                .on_upgrade(move |socket| {
                    handle_websocket(state, socket, path, raw_query, headers, remote_address)
                })
                .into_response();
        }
        return dispatch_http_request(state, remote, Request::from_parts(parts, body)).await;
    }

    dispatch_http_request(state, remote, request).await
}

async fn dispatch_http_request(
    state: Arc<ServerShared>,
    remote: SocketAddr,
    request: Request,
) -> Response {
    let (parts, body) = request.into_parts();
    let body_bytes = match to_bytes(body, state.max_body_bytes).await {
        Ok(bytes) => bytes,
        Err(error) => {
            return status_response(
                StatusCode::PAYLOAD_TOO_LARGE,
                format!("Failed to read request body: {error}"),
            );
        }
    };

    let request_id = NEXT_REQUEST_ID.fetch_add(1, Ordering::Relaxed);
    let (sender, receiver) = oneshot::channel::<HttpResponsePayload>();
    {
        let mut guard = match state.pending_requests.lock() {
            Ok(guard) => guard,
            Err(_) => {
                return status_response(
                    StatusCode::INTERNAL_SERVER_ERROR,
                    "Pending request map is unavailable",
                );
            }
        };
        guard.insert(request_id, sender);
    }

    let event = HttpRequestEvent {
        kind: "http_request",
        server_id: state.server_id,
        request_id,
        method: parts.method.as_str().to_owned(),
        path: parts.uri.path().to_owned(),
        raw_query: parts.uri.query().unwrap_or_default().to_owned(),
        headers: header_map_to_multimap(&parts.headers),
        body_base64: BASE64.encode(body_bytes),
        remote_address: remote.to_string(),
    };

    if let Err(error) = dispatch_event(&event) {
        if let Ok(mut guard) = state.pending_requests.lock() {
            guard.remove(&request_id);
        }
        return status_response(
            StatusCode::INTERNAL_SERVER_ERROR,
            format!("Failed to dispatch request to Dart: {error}"),
        );
    }

    let payload = match receiver.await {
        Ok(payload) => payload,
        Err(_) => {
            return status_response(
                StatusCode::INTERNAL_SERVER_ERROR,
                "Dart side dropped the request response channel",
            );
        }
    };

    let status = StatusCode::from_u16(payload.status).unwrap_or(StatusCode::INTERNAL_SERVER_ERROR);
    let mut builder = Response::builder().status(status);
    for (name, values) in payload.headers {
        let header_name = match HeaderName::from_bytes(name.as_bytes()) {
            Ok(value) => value,
            Err(_) => continue,
        };
        for value in values {
            let Ok(header_value) = HeaderValue::from_str(&value) else {
                continue;
            };
            builder = builder.header(header_name.clone(), header_value);
        }
    }

    builder
        .body(Body::from(payload.body))
        .unwrap_or_else(|error| {
            status_response(
                StatusCode::INTERNAL_SERVER_ERROR,
                format!("Failed to build HTTP response: {error}"),
            )
        })
}

async fn handle_websocket(
    state: Arc<ServerShared>,
    socket: WebSocket,
    path: String,
    raw_query: String,
    headers: HashMap<String, Vec<String>>,
    remote_address: String,
) {
    let socket_id = NEXT_SOCKET_ID.fetch_add(1, Ordering::Relaxed);
    let (tx, mut rx) = mpsc::unbounded_channel::<Message>();
    if let Ok(mut guard) = state.sockets.lock() {
        guard.insert(socket_id, tx);
    }

    let open_event = WebSocketOpenEvent {
        kind: "websocket_open",
        server_id: state.server_id,
        socket_id,
        path,
        raw_query,
        headers,
        remote_address,
    };
    if let Err(error) = dispatch_event(&open_event) {
        emit_server_error(
            state.server_id,
            format!("Failed to dispatch websocket open: {error}"),
        );
    }

    let (mut sender, mut receiver) = socket.split();
    let writer = tokio::spawn(async move {
        while let Some(message) = rx.recv().await {
            if sender.send(message).await.is_err() {
                break;
            }
        }
    });

    while let Some(message) = receiver.next().await {
        match message {
            Ok(Message::Text(text)) => {
                let event = WebSocketTextEvent {
                    kind: "websocket_message",
                    server_id: state.server_id,
                    socket_id,
                    opcode: "text",
                    text: text.to_string(),
                };
                if let Err(error) = dispatch_event(&event) {
                    emit_server_error(
                        state.server_id,
                        format!("Failed to dispatch websocket text frame: {error}"),
                    );
                    break;
                }
            }
            Ok(Message::Binary(bytes)) => {
                let event = WebSocketBinaryEvent {
                    kind: "websocket_message",
                    server_id: state.server_id,
                    socket_id,
                    opcode: "binary",
                    data_base64: BASE64.encode(bytes),
                };
                if let Err(error) = dispatch_event(&event) {
                    emit_server_error(
                        state.server_id,
                        format!("Failed to dispatch websocket binary frame: {error}"),
                    );
                    break;
                }
            }
            Ok(Message::Close(frame)) => {
                let event = WebSocketCloseEvent {
                    kind: "websocket_close",
                    server_id: state.server_id,
                    socket_id,
                    code: frame.as_ref().map(|frame| u16::from(frame.code)),
                    reason: frame.as_ref().map(|frame| frame.reason.to_string()),
                };
                let _ = dispatch_event(&event);
                break;
            }
            Ok(Message::Ping(_)) | Ok(Message::Pong(_)) => {}
            Err(error) => {
                emit_server_error(
                    state.server_id,
                    format!("Websocket receive loop failed: {error}"),
                );
                break;
            }
        }
    }

    if let Ok(mut guard) = state.sockets.lock() {
        guard.remove(&socket_id);
    }
    writer.abort();
}

fn emit_server_error(server_id: i64, message: impl Into<String>) {
    let event = ServerErrorEvent {
        kind: "server_error",
        server_id,
        message: message.into(),
    };
    let _ = dispatch_event(&event);
}

fn is_websocket_request(headers: &HeaderMap) -> bool {
    let has_connection_upgrade = headers
        .get(CONNECTION)
        .and_then(|value| value.to_str().ok())
        .map(|value| value.to_ascii_lowercase().contains("upgrade"))
        .unwrap_or(false);
    let has_upgrade_websocket = headers
        .get(UPGRADE)
        .and_then(|value| value.to_str().ok())
        .map(|value| value.eq_ignore_ascii_case("websocket"))
        .unwrap_or(false);
    has_connection_upgrade && has_upgrade_websocket
}

#[unsafe(no_mangle)]
pub extern "C" fn dart_axum_version() -> *mut c_char {
    static VERSION: &[u8] = b"0.1.0\0";
    VERSION.as_ptr().cast_mut().cast()
}

#[unsafe(no_mangle)]
pub extern "C" fn dart_axum_set_dispatch_callback(
    callback: Option<DispatchCallback>,
) -> *mut c_char {
    let Some(callback) = callback else {
        return error_ptr("Dispatch callback was null");
    };
    match dispatch_callback_slot().lock() {
        Ok(mut guard) => {
            *guard = Some(callback);
            ok_ptr()
        }
        Err(_) => error_ptr("Dispatch callback mutex was poisoned"),
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn dart_axum_start_server(
    config_json_utf8: *const c_char,
    out_server_id: *mut i64,
    out_port: *mut u16,
) -> *mut c_char {
    if out_server_id.is_null() || out_port.is_null() {
        return error_ptr("Output pointers must not be null");
    }
    {
        let callback_guard = match dispatch_callback_slot().lock() {
            Ok(guard) => guard,
            Err(_) => return error_ptr("Dispatch callback mutex was poisoned"),
        };
        if callback_guard.is_none() {
            return error_ptr("Dispatch callback must be installed before starting a server");
        }
    }

    let config_json = match c_str_to_string(config_json_utf8, "config_json_utf8") {
        Ok(value) => value,
        Err(error) => return error_ptr(error),
    };
    let config: StartServerConfig = match serde_json::from_str(&config_json) {
        Ok(value) => value,
        Err(error) => return error_ptr(format!("Invalid start config JSON: {error}")),
    };

    let runtime = match Builder::new_multi_thread().enable_all().build() {
        Ok(runtime) => runtime,
        Err(error) => return error_ptr(format!("Failed to build Tokio runtime: {error}")),
    };

    let address = format!("{}:{}", config.host, config.port);
    let listener = match runtime.block_on(async { TcpListener::bind(&address).await }) {
        Ok(listener) => listener,
        Err(error) => return error_ptr(format!("Failed to bind {address}: {error}")),
    };

    let bound_address = match listener.local_addr() {
        Ok(address) => address,
        Err(error) => return error_ptr(format!("Failed to read bound address: {error}")),
    };

    let server_id = NEXT_SERVER_ID.fetch_add(1, Ordering::Relaxed);
    let (shutdown_tx, shutdown_rx) = oneshot::channel::<()>();
    let shared = Arc::new(ServerShared {
        server_id,
        max_body_bytes: config.max_body_bytes,
        pending_requests: Mutex::new(HashMap::new()),
        sockets: Mutex::new(HashMap::new()),
    });

    let router = Router::new()
        .fallback(dispatch_request)
        .with_state(shared.clone());

    let server_state = shared.clone();
    runtime.spawn(async move {
        let result = axum::serve(
            listener,
            router.into_make_service_with_connect_info::<SocketAddr>(),
        )
        .with_graceful_shutdown(async {
            let _ = shutdown_rx.await;
        })
        .await;

        if let Err(error) = result {
            emit_server_error(
                server_state.server_id,
                format!("Server task failed: {error}"),
            );
        }
    });

    match servers().lock() {
        Ok(mut guard) => {
            guard.insert(
                server_id,
                ServerRecord {
                    runtime,
                    shared,
                    shutdown_tx: Some(shutdown_tx),
                },
            );
        }
        Err(_) => return error_ptr("Server registry mutex was poisoned"),
    }

    // SAFETY: Output pointers are checked for null above and point to writable memory from Dart.
    unsafe {
        *out_server_id = server_id;
        *out_port = bound_address.port();
    }

    ok_ptr()
}

#[unsafe(no_mangle)]
pub extern "C" fn dart_axum_stop_server(server_id: i64) -> *mut c_char {
    let mut record = match servers().lock() {
        Ok(mut guard) => guard.remove(&server_id),
        Err(_) => return error_ptr("Server registry mutex was poisoned"),
    };
    let Some(mut record) = record.take() else {
        return error_ptr(format!("Unknown server id {server_id}"));
    };
    if let Some(shutdown_tx) = record.shutdown_tx.take() {
        let _ = shutdown_tx.send(());
    }
    record
        .runtime
        .shutdown_timeout(std::time::Duration::from_millis(200));
    ok_ptr()
}

#[unsafe(no_mangle)]
pub extern "C" fn dart_axum_complete_http_request(
    server_id: i64,
    request_id: i64,
    response_json_utf8: *const c_char,
) -> *mut c_char {
    let response_json = match c_str_to_string(response_json_utf8, "response_json_utf8") {
        Ok(value) => value,
        Err(error) => return error_ptr(error),
    };
    let response: HttpResponsePayloadJson = match serde_json::from_str(&response_json) {
        Ok(value) => value,
        Err(error) => return error_ptr(format!("Invalid HTTP response JSON: {error}")),
    };
    let body = match BASE64.decode(response.body_base64.as_bytes()) {
        Ok(value) => value,
        Err(error) => return error_ptr(format!("Invalid response body base64: {error}")),
    };

    let sender =
        match servers().lock() {
            Ok(guard) => guard.get(&server_id).and_then(|record| {
                match record.shared.pending_requests.lock() {
                    Ok(mut pending) => pending.remove(&request_id),
                    Err(_) => None,
                }
            }),
            Err(_) => return error_ptr("Server registry mutex was poisoned"),
        };
    let Some(sender) = sender else {
        return error_ptr(format!(
            "Unknown pending request {request_id} for server {server_id}"
        ));
    };

    if sender
        .send(HttpResponsePayload {
            status: response.status,
            headers: response.headers,
            body,
        })
        .is_err()
    {
        return error_ptr(format!(
            "Failed to deliver response for request {request_id} on server {server_id}"
        ));
    }

    ok_ptr()
}

#[unsafe(no_mangle)]
pub extern "C" fn dart_axum_websocket_send(
    server_id: i64,
    socket_id: i64,
    outbound_json_utf8: *const c_char,
) -> *mut c_char {
    let outbound_json = match c_str_to_string(outbound_json_utf8, "outbound_json_utf8") {
        Ok(value) => value,
        Err(error) => return error_ptr(error),
    };
    let outbound: OutboundWebSocketFrame = match serde_json::from_str(&outbound_json) {
        Ok(value) => value,
        Err(error) => return error_ptr(format!("Invalid websocket frame JSON: {error}")),
    };

    let sender = match servers().lock() {
        Ok(guard) => guard
            .get(&server_id)
            .and_then(|record| match record.shared.sockets.lock() {
                Ok(sockets) => sockets.get(&socket_id).cloned(),
                Err(_) => None,
            }),
        Err(_) => return error_ptr("Server registry mutex was poisoned"),
    };
    let Some(sender) = sender else {
        return error_ptr(format!(
            "Unknown websocket {socket_id} for server {server_id}"
        ));
    };

    let message = match outbound.kind.as_str() {
        "text" => Message::Text(outbound.text.unwrap_or_default().into()),
        "binary" => {
            let data_base64 = outbound.data_base64.unwrap_or_default();
            let data = match BASE64.decode(data_base64.as_bytes()) {
                Ok(value) => value,
                Err(error) => {
                    return error_ptr(format!("Invalid websocket binary payload: {error}"));
                }
            };
            Message::Binary(data.into())
        }
        "close" => Message::Close(Some(CloseFrame {
            code: outbound.code.unwrap_or(1000).into(),
            reason: outbound.reason.unwrap_or_default().into(),
        })),
        other => return error_ptr(format!("Unsupported websocket frame kind: {other}")),
    };

    if sender.send(message).is_err() {
        return error_ptr(format!(
            "Failed to enqueue websocket frame for socket {socket_id} on server {server_id}"
        ));
    }

    ok_ptr()
}

#[unsafe(no_mangle)]
pub extern "C" fn dart_axum_string_free(pointer: *mut c_char) {
    if pointer.is_null() {
        return;
    }
    // SAFETY: The pointer was allocated with CString::into_raw on the Rust side.
    unsafe {
        let _ = CString::from_raw(pointer);
    }
}
