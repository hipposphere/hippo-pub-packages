import 'package:dart_axum/dart_axum.dart';
import 'package:test/test.dart';

void main() {
  test('builds openapi document from route definitions and reusable components', () {
    final app = AxumApp(
      openApi: const AxumOpenApi(
        info: AxumOpenApiInfo(title: 'Example API', version: '1.2.3'),
      ),
    );
    final usersRouter = AxumRouter();

    final createUserComponent = AxumSchemaComponent.object(
      name: 'CreateUserRequest',
      properties: <String, AxumSchema>{'name': AxumSchema.string()},
      required: const <String>{'name'},
    );
    final userComponent = AxumSchemaComponent.object(
      name: 'UserRecord',
      properties: <String, AxumSchema>{'id': AxumSchema.string(), 'name': AxumSchema.string()},
      required: const <String>{'id', 'name'},
    );
    final errorComponent = AxumSchemaComponent.object(
      name: 'ApiError',
      properties: <String, AxumSchema>{'error': AxumSchema.string()},
      required: const <String>{'error'},
    );

    final createUserType = AxumJsonType<_CreateUser>.component(
      decodeJson: _CreateUser.fromJsonObject,
      encodeJson: (value) => value.toJson(),
      component: createUserComponent,
    );
    final userType = AxumJsonType<_UserRecord>.component(
      decodeJson: _UserRecord.fromJsonObject,
      encodeJson: (value) => value.toJson(),
      component: userComponent,
    );

    usersRouter.register<_CreateUser, _UserRecord>(
      AxumTypedRouteDefinition<_CreateUser, _UserRecord>(
        method: AxumMethod.post,
        path: '/:userId',
        request: createUserType,
        response: userType,
        docs: AxumRouteDocs(
          summary: 'Create or replace a user',
          tags: const <String>['users', 'contracts'],
          responses: <int, AxumResponseDocs>{
            201: AxumResponseDocs(
              description: 'Created',
              schema: userComponent.reference,
              components: <AxumSchemaComponent>[userComponent],
            ),
            400: AxumResponseDocs(
              description: 'Invalid input',
              schema: errorComponent.reference,
              components: <AxumSchemaComponent>[errorComponent],
            ),
          },
        ),
      ),
      handler: (context) => _UserRecord(id: context.params['userId']!, name: context.body.name),
    );
    app.mount('/users', usersRouter);

    final document = app.openApiDocument();
    final paths = document['paths']! as Map<String, Object?>;
    final components =
        (document['components']! as Map<String, Object?>)['schemas']! as Map<String, Object?>;
    final pathItem = paths['/users/{userId}']! as Map<String, Object?>;
    final operation = pathItem['post']! as Map<String, Object?>;

    expect(document['openapi'], '3.1.0');
    expect((document['info']! as Map<String, Object?>)['title'], 'Example API');
    expect(operation['summary'], 'Create or replace a user');
    expect(operation['tags'], <String>['users', 'contracts']);

    final parameters = operation['parameters']! as List<Object?>;
    expect(parameters, contains(containsPair('in', 'path')));

    final requestBody = operation['requestBody']! as Map<String, Object?>;
    final content = requestBody['content']! as Map<String, Object?>;
    final jsonContent = content['application/json; charset=utf-8']! as Map<String, Object?>;
    expect(jsonContent['schema'], createUserComponent.reference.toJson());

    final responses = operation['responses']! as Map<String, Object?>;
    final created = responses['201']! as Map<String, Object?>;
    expect(created['description'], 'Created');
    expect(
      ((created['content']! as Map<String, Object?>)['application/json']!
          as Map<String, Object?>)['schema'],
      userComponent.reference.toJson(),
    );
    expect(components['CreateUserRequest'], createUserComponent.toJson());
    expect(components['UserRecord'], userComponent.toJson());
    expect(components['ApiError'], errorComponent.toJson());
  });

  test('includes raw-route request bodies such as multipart uploads', () {
    final app = AxumApp(
      openApi: const AxumOpenApi(
        info: AxumOpenApiInfo(title: 'Upload API', version: '1.0.0'),
      ),
    );

    app.post(
      '/uploads',
      handler: (_) => AxumResponse.json(<String, Object?>{'ok': true}),
      docs: const AxumRouteDocs(
        summary: 'Upload a file',
        requestBody: AxumRequestBodyDocs(
          contentType: 'multipart/form-data',
          schema: AxumSchema.object(
            properties: <String, AxumSchema>{
              'owner': AxumSchema.string(),
              'file': AxumSchema.string(format: 'binary'),
            },
            required: <String>{'owner', 'file'},
          ),
        ),
      ),
    );

    final document = app.openApiDocument();
    final paths = document['paths']! as Map<String, Object?>;
    final operation = (paths['/uploads']! as Map<String, Object?>)['post']! as Map<String, Object?>;
    final requestBody = operation['requestBody']! as Map<String, Object?>;
    final content = requestBody['content']! as Map<String, Object?>;

    expect(content.containsKey('multipart/form-data'), isTrue);
    expect(content['multipart/form-data'], <String, Object?>{
      'schema': <String, Object?>{
        'type': 'object',
        'properties': <String, Object?>{
          'owner': const AxumSchema.string().toJson(),
          'file': const AxumSchema.string(format: 'binary').toJson(),
        },
        'required': <String>['file', 'owner'],
        'additionalProperties': false,
      },
    });
  });
}

final class _CreateUser {
  _CreateUser({required this.name});

  final String name;

  static _CreateUser fromJsonObject(Object? value) {
    final json = value as Map<String, Object?>;
    return _CreateUser(name: json['name']! as String);
  }

  Map<String, Object?> toJson() => <String, Object?>{'name': name};
}

final class _UserRecord {
  _UserRecord({required this.id, required this.name});

  final String id;
  final String name;

  static _UserRecord fromJsonObject(Object? value) {
    final json = value as Map<String, Object?>;
    return _UserRecord(id: json['id']! as String, name: json['name']! as String);
  }

  Map<String, Object?> toJson() => <String, Object?>{'id': id, 'name': name};
}
