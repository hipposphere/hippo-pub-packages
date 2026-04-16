import 'package:dart_axum/dart_axum.dart';

final AxumSchemaComponent createUserRequestComponent = AxumSchemaComponent.object(
  name: 'CreateUserRequest',
  description: 'JSON request body used when creating a user.',
  properties: <String, AxumSchema>{
    'name': AxumSchema.string(description: 'Display name for the new user.'),
  },
  required: const <String>{'name'},
);

final AxumSchemaComponent userRecordComponent = AxumSchemaComponent.object(
  name: 'UserRecord',
  description: 'Stored user record returned by the API.',
  properties: <String, AxumSchema>{
    'id': AxumSchema.string(description: 'Stable user identifier.'),
    'name': AxumSchema.string(description: 'Display name.'),
  },
  required: const <String>{'id', 'name'},
);

final AxumSchemaComponent apiErrorComponent = AxumSchemaComponent.object(
  name: 'ApiError',
  description: 'Basic JSON error payload.',
  properties: <String, AxumSchema>{
    'error': AxumSchema.string(description: 'Human-readable error message.'),
  },
  required: const <String>{'error'},
);

final AxumJsonType<CreateUserRequest> createUserRequestType =
    AxumJsonType<CreateUserRequest>.component(
      decodeJson: CreateUserRequest.fromJsonObject,
      encodeJson: (value) => value.toJson(),
      component: createUserRequestComponent,
    );

final AxumJsonType<UserRecord> userRecordType = AxumJsonType<UserRecord>.component(
  decodeJson: UserRecord.fromJsonObject,
  encodeJson: (value) => value.toJson(),
  component: userRecordComponent,
);

final class CreateUserRoute extends AxumTypedRouteDefinition<CreateUserRequest, UserRecord> {
  CreateUserRoute()
    : super(
        method: AxumMethod.post,
        path: '/',
        request: createUserRequestType,
        response: userRecordType,
        docs: AxumRouteDocs(
          summary: 'Create a user',
          description: 'Accepts JSON input and returns the created user record.',
          tags: const <String>['users'],
          responses: <int, AxumResponseDocs>{
            200: AxumResponseDocs(
              description: 'Created user record.',
              schema: userRecordComponent.reference,
              components: <AxumSchemaComponent>[userRecordComponent],
              contentType: 'application/json; charset=utf-8',
            ),
            400: AxumResponseDocs(
              description: 'Validation failure when the name is empty.',
              schema: apiErrorComponent.reference,
              components: <AxumSchemaComponent>[apiErrorComponent],
              contentType: 'application/json; charset=utf-8',
            ),
          },
        ),
      );
}

final class CreateUserRequest {
  CreateUserRequest({required this.name});

  final String name;

  static CreateUserRequest fromJsonObject(Object? value) {
    final json = value as Map<String, Object?>;
    return CreateUserRequest(name: json['name']! as String);
  }

  Map<String, Object?> toJson() => <String, Object?>{'name': name};
}

final class UserRecord {
  UserRecord({required this.id, required this.name});

  final String id;
  final String name;

  static UserRecord fromJsonObject(Object? value) {
    final json = value as Map<String, Object?>;
    return UserRecord(id: json['id']! as String, name: json['name']! as String);
  }

  Map<String, Object?> toJson() => <String, Object?>{'id': id, 'name': name};
}
