import 'package:dart_axum/dart_axum.dart';
import 'package:test/test.dart';

void main() {
  test('builds openapi document from typed routes', () {
    final app = AxumApp(
      openApi: const AxumOpenApi(
        info: AxumOpenApiInfo(title: 'Example API', version: '1.2.3'),
      ),
    );

    const createUserSchema = AxumSchema.object(
      properties: <String, AxumSchema>{'name': AxumSchema.string()},
      required: <String>{'name'},
    );
    const userSchema = AxumSchema.object(
      properties: <String, AxumSchema>{'id': AxumSchema.string(), 'name': AxumSchema.string()},
      required: <String>{'id', 'name'},
    );

    final createUserCodec = AxumJsonCodec<_CreateUser>(
      decodeJson: _CreateUser.fromJsonObject,
      encodeJson: (value) => value.toJson(),
      schema: createUserSchema,
    );
    final userCodec = AxumJsonCodec<_UserRecord>(
      decodeJson: _UserRecord.fromJsonObject,
      encodeJson: (value) => value.toJson(),
      schema: userSchema,
    );

    app.postTyped<_CreateUser, _UserRecord>(
      '/users/:userId',
      request: createUserCodec,
      response: userCodec,
      docs: const AxumRouteDocs(
        summary: 'Create or replace a user',
        tags: <String>['users'],
        responses: <int, AxumResponseDocs>{
          201: AxumResponseDocs(description: 'Created', schema: userSchema),
        },
      ),
      handler: (context) => _UserRecord(id: context.params['userId']!, name: context.body.name),
    );

    final document = app.openApiDocument();
    final paths = document['paths']! as Map<String, Object?>;
    final pathItem = paths['/users/{userId}']! as Map<String, Object?>;
    final operation = pathItem['post']! as Map<String, Object?>;

    expect(document['openapi'], '3.1.0');
    expect((document['info']! as Map<String, Object?>)['title'], 'Example API');
    expect(operation['summary'], 'Create or replace a user');
    expect(operation['tags'], <String>['users']);

    final parameters = operation['parameters']! as List<Object?>;
    expect(parameters, contains(containsPair('in', 'path')));

    final requestBody = operation['requestBody']! as Map<String, Object?>;
    final content = requestBody['content']! as Map<String, Object?>;
    final jsonContent = content['application/json; charset=utf-8']! as Map<String, Object?>;
    expect(jsonContent['schema'], createUserSchema.toJson());

    final responses = operation['responses']! as Map<String, Object?>;
    final created = responses['201']! as Map<String, Object?>;
    expect(created['description'], 'Created');
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
