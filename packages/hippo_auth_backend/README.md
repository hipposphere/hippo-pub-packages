# hippo_auth_backend

Backend routes for Hippo Auth on Dart Edge.

The package mounts the Hippo Auth HTTP surface from the NPM package on top of
`dart_edge_core`, uses `dart_edge_auth` for Better Auth, stores auth data in a
shared `dart_edge_sql` pool, and renders reset-password / confirm-mail pages
with `dart_edge_jaspr`.

```dart
final database = SqliteDatabase.inMemory();
final backend = HippoAuthBackend(
  HippoAuthBackendOptions(
      workerPoolSize: 4,
    database: database,
    secret: 'replace-with-a-strong-secret-at-least-32-chars',
    baseUrl: 'http://localhost:3000',
    exposeBetterAuthApi: true,
    manageMigrations: true, // Use application migrations in production.
  ),
);

final app = DartEdge<void>(services: () {});
backend.mount(app);
await app.listen(port: 3000);
```

To mount everything under a subpath, pass `basePath`:

```dart
backend.mount(app, basePath: '/auth');
```

This exposes the Hippo routes as `/auth/v1/...`, hosted views as
`/auth/views/...`, and optional Better Auth routes as `/auth/better-auth/...`.

Mounted routes include:

- `/v1/user/info`
- `/v1/user/sign-in-email`
- `/v1/user/sign-up-email`
- `/v1/user/request-password-reset`
- `/v1/user/reset-password`
- `/v1/user/confirm-mail`
- `/v1/user/get_user`
- `/v1/user/logout`
- `/v1/user/refresh-session`
- `/v1/admin/create-user`
- `/v1/admin/list-users`
- `/v1/admin/update-user`
- `/v1/admin/delete-user`
- `/views/reset-password`
- `/views/confirm-mail`

OAuth2 and SSO routes are backed by `dart_edge_auth` OAuth providers. OAuth
client admin routes are still registered for client compatibility, but return
`501` until `dart_edge_auth` exposes the matching Better Auth OAuth provider
management plugin.

Generated OpenAPI docs include stable operation IDs, request body presence,
response content types, and error status metadata. Hippo route payloads are
documented as untyped JSON so the backend does not install route-level component
schemas automatically.

## SQL Models

Better Auth SQL row models and table descriptors come from `dart_edge_auth`.
`hippo_auth_backend` re-exports the canonical `DartEdgeAuthSchema`,
`DartEdgeAuthUser`, `DartEdgeAuthSession`, `DartEdgeAuthUsersTable`, and
`DartEdgeAuthSessionsTable` types for callers that need direct SQL access.

Auth-managed migrations are disabled by default. Production applications should
create and evolve the Better Auth tables through their normal migration system.
Set `manageMigrations: true` only for throwaway/demo databases.

For PostgreSQL deployments that isolate auth tables in a separate schema, pass
`databaseSchema: 'auth'` and create that schema and its tables yourself.
`hippo_auth_backend` forwards the schema to `dart_edge_auth`, and backend
session lookups use the schema-aware SQL table descriptors.
