import 'package:dart_axum/dart_axum.dart';

import '../models/user_models.dart';

AxumRouter buildUsersRouter() {
  final users = <String, UserRecord>{
    'ada': UserRecord(id: 'ada', name: 'Ada Lovelace'),
    'grace': UserRecord(id: 'grace', name: 'Grace Hopper'),
  };

  return AxumRouter(
    build: (router) {
      router.get(
        '/',
        handler: (_) =>
            AxumResponse.json(<Object?>[for (final user in users.values) user.toJson()]),
        docs: AxumRouteDocs(
          summary: 'List users',
          description: 'Returns a small in-memory user list from the mounted users router.',
          tags: const <String>['users'],
          responses: <int, AxumResponseDocs>{
            200: AxumResponseDocs(
              description: 'List of users.',
              schema: AxumSchema.array(userRecordComponent.reference),
              components: <AxumSchemaComponent>[userRecordComponent],
            ),
          },
        ),
      );

      router.get(
        '/:userId',
        handler: (context) {
          final userId = context.params['userId']!;
          final user = users[userId];
          if (user == null) {
            throw AxumHttpException(404, message: 'User $userId was not found');
          }
          return AxumResponse.json(user.toJson());
        },
        docs: AxumRouteDocs(
          summary: 'Fetch a user',
          description: 'Returns one user from the mounted users router.',
          tags: const <String>['users'],
          responses: <int, AxumResponseDocs>{
            200: AxumResponseDocs(
              description: 'User record.',
              schema: userRecordComponent.reference,
              components: <AxumSchemaComponent>[userRecordComponent],
            ),
            404: AxumResponseDocs(
              description: 'User not found.',
              schema: apiErrorComponent.reference,
              components: <AxumSchemaComponent>[apiErrorComponent],
            ),
          },
        ),
      );

      router.register<CreateUserRequest, UserRecord>(
        CreateUserRoute(),
        handler: (context) {
          final name = context.body.name.trim();
          if (name.isEmpty) {
            throw AxumHttpException(400, message: 'name must not be empty');
          }

          final id = _slugify(name);
          final user = UserRecord(id: id, name: name);
          users[id] = user;
          return user;
        },
      );
    },
  );
}

String _slugify(String value) {
  final lower = value.toLowerCase();
  final normalized = lower.replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-|-$'), '');
  return normalized.isEmpty ? 'user' : normalized;
}
