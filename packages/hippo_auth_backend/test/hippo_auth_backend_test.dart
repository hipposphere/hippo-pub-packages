import 'dart:convert';
import 'dart:io';

import 'package:dart_edge_auth/dart_edge_auth.dart';
import 'package:dart_edge_http_server/dart_edge_http_server.dart';
import 'package:dart_edge_sql/dart_edge_sql.dart';
import 'package:dart_edge_sql_pglite/dart_edge_sql_pglite.dart';
import 'package:hippo_auth_backend/hippo_auth_backend.dart';
import 'package:test/test.dart';

void main() {
  test('normalizes direct auth API errors to the public error envelope', () {
    final response = hippoAuthExceptionResponse(
      DartEdgeAuthApiException(
        DartEdgeAuthApiResponse(
          status: HttpStatus.unauthorized,
          contentType: 'application/json',
          headers: const <HttpHeader>[],
          body: jsonEncode({
            'error': {'code': 'SignInEmailFailed', 'message': 'Invalid credentials'},
          }),
        ),
      ),
      defaultStatus: HttpStatus.internalServerError,
      defaultCode: 'SignInEmailFailed',
      defaultMessage: 'Sign in failed.',
    );

    expect(response.status, HttpStatus.unauthorized);
    expect(response.body, {
      'error': {'code': 'SignInEmailFailed', 'message': 'Invalid credentials'},
    });
  });

  test('normalizes bearer tokens into better-auth session cookies', () {
    final headers = authHeadersForBetterAuth({
      HttpHeaders.authorizationHeader: 'Bearer session-token',
      HttpHeaders.cookieHeader: 'theme=dark; better-auth.session-token=stale-token',
    }, defaultHippoAuthSessionCookieName);

    expect(headers['authorization'], 'Bearer session-token');
    expect(headers['cookie'], 'theme=dark; better-auth.session-token=session-token');
  });

  test('disables auth-managed migrations by default', () {
    final database = SqliteDatabase.inMemory();
    addTearDown(database.close);

    final options = HippoAuthBackendOptions(
      database: database,
      secret: 'test-secret-key-that-is-at-least-32-characters-long',
      baseUrl: 'http://localhost:3000',
    );

    expect(options.manageMigrations, isFalse);
    expect(options.toDartEdgeAuthConfig().database.manageMigrations, isFalse);
  });

  test('passes explicit auth-managed migrations through', () {
    final database = SqliteDatabase.inMemory();
    addTearDown(database.close);

    final options = HippoAuthBackendOptions(
      database: database,
      secret: 'test-secret-key-that-is-at-least-32-characters-long',
      baseUrl: 'http://localhost:3000',
      manageMigrations: true,
    );

    expect(options.toDartEdgeAuthConfig().database.manageMigrations, isTrue);
  });

  test('normalizes and validates database schema options', () {
    final database = SqliteDatabase.inMemory();
    addTearDown(database.close);

    final options = HippoAuthBackendOptions(
      database: database,
      secret: 'test-secret-key-that-is-at-least-32-characters-long',
      baseUrl: 'http://localhost:3000',
      databaseSchema: ' auth ',
    );

    expect(options.normalizedDatabaseSchema, 'auth');
    final authDatabase = options.toDartEdgeAuthConfig().database;
    expect(authDatabase, isA<SharedDartEdgeAuthDatabase>());
    expect((authDatabase as SharedDartEdgeAuthDatabase).schema, 'auth');

    expect(
      () => HippoAuthBackendOptions(
        database: database,
        secret: 'test-secret-key-that-is-at-least-32-characters-long',
        baseUrl: 'http://localhost:3000',
        databaseSchema: 'auth;drop',
      ).normalizedDatabaseSchema,
      throwsArgumentError,
    );
  });

  test('mounts hippo auth, view, and optional better-auth routes', () {
    final database = SqliteDatabase.inMemory();
    final backend = _backend(database);
    addTearDown(() async {
      backend.dispose();
      await database.close();
    });

    final app = DartEdge<void>(services: () {});
    backend.mount(app);

    final document = app.buildOpenApiDocumentJson();
    final paths = document['paths']! as Map<String, Object?>;

    expect(paths.keys, contains('/v1/user/info'));
    expect(paths.keys, contains('/v1/user/sign-up-email'));
    expect(paths.keys, contains('/v1/admin/list-users'));
    expect(paths.keys, contains('/views/reset-password'));
    expect(paths.keys, contains('/better-auth/sign-up/email'));

    final components = document['components']! as Map<String, Object?>;
    final schemas = components['schemas']! as Map<String, Object?>;
    expect(schemas.keys, containsAll(['DartEdgeAuthUser', 'HippoAuthSessionPayload']));

    final signUp = _operation(paths, '/v1/user/sign-up-email', 'post');
    expect(signUp['operationId'], 'postV1UserSignUpEmail');
    final signUpBody = _jsonRequestBodySchema(signUp);
    expect(signUpBody['type'], 'object');
    expect(signUpBody.keys, isNot(contains('\$id')));
    final signUpResponse = _jsonResponseSchema(signUp, 200)!;
    expect(signUpResponse['type'], 'object');
    expect(signUpResponse.keys, isNot(contains('\$ref')));
    _expectSessionResponseSchema(signUpResponse);
    expect(_jsonResponseSchema(signUp, 403), isNull);

    final signIn = _operation(paths, '/v1/user/sign-in-email', 'post');
    expect(signIn['operationId'], 'postV1UserSignInEmail');
    final signInResponse = _jsonResponseSchema(signIn, 200)!;
    expect(signInResponse['type'], 'object');
    expect(signInResponse.keys, isNot(contains('\$ref')));
    _expectSessionResponseSchema(signInResponse);

    final listUsers = _operation(paths, '/v1/admin/list-users', 'get');
    expect(listUsers['operationId'], 'getV1AdminListUsers');
    final listUsersResponse = _jsonResponseSchema(listUsers, 200)!;
    expect(listUsersResponse['type'], 'object');
    final listUsersProperties = listUsersResponse['properties']! as Map<String, Object?>;
    final users = listUsersProperties['users']! as Map<String, Object?>;
    expect(users['type'], 'array');
    final userItems = users['items']! as Map<String, Object?>;
    expect(userItems['type'], 'object');
    expect(userItems.keys, isNot(contains('\$ref')));
  });

  test('mounts the full backend under a subpath', () {
    final database = SqliteDatabase.inMemory();
    final backend = _backend(database);
    addTearDown(() async {
      backend.dispose();
      await database.close();
    });

    final app = DartEdge<void>(services: () {});
    backend.mount(app, basePath: '/auth');

    final document = app.buildOpenApiDocumentJson();
    final paths = document['paths']! as Map<String, Object?>;

    expect(paths.keys, contains('/auth/v1/user/info'));
    expect(paths.keys, contains('/auth/v1/user/sign-up-email'));
    expect(paths.keys, contains('/auth/views/reset-password'));
    expect(paths.keys, contains('/auth/better-auth/sign-up/email'));
  });

  test('signs up, signs in, and resolves a session through the ported routes', () async {
    final database = SqliteDatabase.inMemory();
    final backend = _backend(database);
    final app = DartEdge<void>(services: () {});
    backend.mount(app);

    final server = await app.listen(port: 0, workers: 1);
    final client = HttpClient();
    addTearDown(() async {
      client.close(force: true);
      await server.close();
      backend.dispose();
      await database.close();
    });

    final baseUri = Uri.http('127.0.0.1:${server.port}');
    final signup = await _postJson(client, baseUri.resolve('/v1/user/sign-up-email'), {
      'name': 'Ada Lovelace',
      'email': 'ada@example.com',
      'password': 'password123',
    });

    expect(signup.statusCode, HttpStatus.ok);
    final signupJson = await _readJson(signup);
    expect(signupJson['session_id'], isA<String>());
    expect(signupJson['token'], isA<String>());
    final signupUser = signupJson['user']! as Map<String, Object?>;
    expect(signupUser['email'], 'ada@example.com');

    final sessions = SessionGateway(database);
    final session = await sessions.findByToken(signupJson['token']! as String);
    expect(session?.id, signupJson['session_id']);

    final signin = await _postJson(client, baseUri.resolve('/v1/user/sign-in-email'), {
      'email': 'ada@example.com',
      'password': 'password123',
    });

    expect(signin.statusCode, HttpStatus.ok);
    final signinJson = await _readJson(signin);
    expect(signinJson['session_id'], isA<String>());
    expect(signinJson['token'], isA<String>());
    final signinUser = signinJson['user']! as Map<String, Object?>;
    expect(signinUser['email'], 'ada@example.com');

    final invalidSignin = await _postJson(client, baseUri.resolve('/v1/user/sign-in-email'), {
      'email': 'ada@example.com',
      'password': 'wrong-password',
    });

    expect(invalidSignin.statusCode, HttpStatus.unauthorized);
    final invalidSigninJson = await _readJson(invalidSignin);
    expect(invalidSigninJson['error'], {
      'code': 'SignInEmailFailed',
      'message': 'Invalid credentials',
    });

    final updatedExpiresAt = session!.expiresAt.toUtc().add(const Duration(days: 1));
    await sessions.updateExpiresAt(sessionId: session.id, expiresAt: updatedExpiresAt);
    final updatedSession = await sessions.findByToken(session.token);
    expect(updatedSession?.expiresAt, updatedExpiresAt);

    final request = await client.getUrl(baseUri.resolve('/v1/user/get_user'));
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer ${signupJson['token']}');
    final response = await request.close();

    expect(response.statusCode, HttpStatus.ok);
    final body = await _readJson(response);
    final user = body['user']! as Map<String, Object?>;
    expect(user['email'], 'ada@example.com');
  });

  test('signs up through subpath-mounted routes', () async {
    final database = SqliteDatabase.inMemory();
    final backend = _backend(database);
    final app = DartEdge<void>(services: () {});
    backend.mount(app, basePath: '/auth');

    final server = await app.listen(port: 0, workers: 1);
    final client = HttpClient();
    addTearDown(() async {
      client.close(force: true);
      await server.close();
      backend.dispose();
      await database.close();
    });

    final baseUri = Uri.http('127.0.0.1:${server.port}');
    final signup = await _postJson(client, baseUri.resolve('/auth/v1/user/sign-up-email'), {
      'name': 'Grace Hopper',
      'email': 'grace@example.com',
      'password': 'password123',
    });

    expect(signup.statusCode, HttpStatus.ok);
    final signupJson = await _readJson(signup);
    expect(signupJson['token'], isA<String>());
    final signupUser = signupJson['user']! as Map<String, Object?>;
    expect(signupUser['email'], 'grace@example.com');
  });

  test('signs in through compatibility route after direct Better Auth signup on PGlite', () async {
    final database = PgliteDatabase.temporary().asPostgresPool();
    final backend = _backend(database, databaseSchema: 'auth');
    final app = DartEdge<void>(services: () {});
    backend.mount(app, basePath: '/auth');

    final server = await app.listen(port: 0, workers: 1);
    final client = HttpClient();
    addTearDown(() async {
      client.close(force: true);
      await server.close();
      backend.dispose();
      await database.close();
    });

    final baseUri = Uri.http('127.0.0.1:${server.port}');
    final signup = await _postJson(client, baseUri.resolve('/auth/better-auth/sign-up/email'), {
      'name': 'Katherine Johnson',
      'email': 'katherine@example.com',
      'password': 'password123',
    });
    final signupBody = await _readBody(signup);

    expect(signup.statusCode, HttpStatus.ok, reason: signupBody);

    final signin = await _postJson(client, baseUri.resolve('/auth/v1/user/sign-in-email'), {
      'email': 'katherine@example.com',
      'password': 'password123',
    });
    final signinBody = await _readBody(signin);

    expect(signin.statusCode, HttpStatus.ok, reason: signinBody);
    final signinJson = jsonDecode(signinBody) as Map<String, Object?>;
    expect(signinJson['session_id'], isA<String>());
    expect(signinJson['token'], isA<String>());
    final signinUser = signinJson['user']! as Map<String, Object?>;
    expect(signinUser['email'], 'katherine@example.com');
  });
}

HippoAuthBackend _backend(SqlPool database, {String? databaseSchema}) {
  return HippoAuthBackend(
    HippoAuthBackendOptions(
      database: database,
      secret: 'test-secret-key-that-is-at-least-32-characters-long',
      baseUrl: 'http://localhost:3000',
      databaseSchema: databaseSchema,
      exposeBetterAuthApi: true,
      enableRateLimit: false,
      manageMigrations: true,
    ),
  );
}

Future<HttpClientResponse> _postJson(HttpClient client, Uri uri, Map<String, Object?> body) async {
  final request = await client.postUrl(uri);
  request.headers.contentType = ContentType.json;
  request.write(jsonEncode(body));
  return request.close();
}

Future<Map<String, Object?>> _readJson(HttpClientResponse response) async {
  return jsonDecode(await _readBody(response)) as Map<String, Object?>;
}

Future<String> _readBody(HttpClientResponse response) async {
  return utf8.decoder.bind(response).join();
}

Map<String, Object?> _operation(Map<String, Object?> paths, String path, String method) {
  final pathItem = paths[path]! as Map<String, Object?>;
  return pathItem[method]! as Map<String, Object?>;
}

Map<String, Object?> _jsonRequestBodySchema(Map<String, Object?> operation) {
  final body = operation['requestBody']! as Map<String, Object?>;
  final content = body['content']! as Map<String, Object?>;
  final json = content['application/json']! as Map<String, Object?>;
  return json['schema']! as Map<String, Object?>;
}

Map<String, Object?>? _jsonResponseSchema(Map<String, Object?> operation, int status) {
  final responses = operation['responses']! as Map<String, Object?>;
  final response = responses['$status']! as Map<String, Object?>;
  final content = response['content'] as Map<String, Object?>?;
  final json = content?['application/json'] as Map<String, Object?>?;
  return json?['schema'] as Map<String, Object?>?;
}

void _expectSessionResponseSchema(Map<String, Object?> schema) {
  final properties = schema['properties']! as Map<String, Object?>;
  expect(properties.keys, containsAll(['session_id', 'token', 'expires_at', 'user']));
  final user = properties['user']! as Map<String, Object?>;
  expect(
    user['type'] == 'object' || user['\$ref'] == '#/components/schemas/DartEdgeAuthUser',
    isTrue,
  );
}
