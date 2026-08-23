# hippo_auth_backend

Backend routes for Hippo Auth on Dart Edge.

The package mounts the Hippo Auth HTTP surface from the NPM package on top of
`dart_http_core`, uses `dart_better_auth` for Better Auth, stores auth data in a
shared `dart_sql` pool, and renders reset-password / confirm-mail pages
with `dart_edge_jaspr`.

```dart
final database = SqliteDatabase.inMemory();
final backend = HippoAuthBackend(
  HippoAuthBackendOptions(
    workerPoolSize: 4,
    database: database,
    secret: 'replace-with-a-strong-secret-at-least-32-chars',
    baseUrl: 'http://localhost:3000',
    trustedOrigins: const ['https://app.example.com'],
    exposeBetterAuthApi: true,
    manageMigrations: true, // Use application migrations in production.
  ),
);

final app = DartHttp<void>(services: () {});
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

OAuth2 and SSO routes are backed by `dart_better_auth` OAuth providers. OAuth
client admin routes are still registered for client compatibility, but return
`501` until `dart_better_auth` exposes the matching Better Auth OAuth provider
management plugin.

`callbackURL` on `/v1/oauth2/sign-in/<provider>` is the final application return
URL. `hippo_auth_backend` starts the provider OAuth flow with the backend
callback URL instead, stores the app callback by OAuth state, and redirects to
the app callback after the backend callback creates a session. The provider
redirect URL defaults to `<baseUrl>/v1/oauth2/callback/<provider>` and can be
overridden per provider with `HippoAuthSsoProvider.redirectUrl` for proxied or
subpath deployments.

The final app `callbackURL` must be an absolute HTTP(S) URL on the auth origin,
an absolute URL on a configured `trustedOrigins` origin, or an HTTP(S) URL on a
loopback host when `allowLoopbackOAuthCallbackUrls` is enabled. Explicitly
configured custom-scheme origins such as `com.example.app://auth` are supported
for native app callbacks. Loopback ports such as
`http://127.0.0.1:55357/callback` do not need to be added to Better Auth trusted
origins. Configure the OAuth provider, such as Azure Entra ID, with the backend
callback URL, not the final native or loopback app callback URL.

Generated OpenAPI docs include stable operation IDs, request body presence,
response content types, and error status metadata. Hippo route payloads are
documented as untyped JSON so the backend does not install route-level component
schemas automatically.

## SQL Models

Better Auth user row models and table descriptors come from
`hippobase_auth_models`, so shared user contracts do not depend on the auth
server implementation. `hippo_auth_backend` re-exports `AuthUserId`,
`AuthUserRow`, `AuthUserInsert`, `AuthUserUpdate`, and `AuthUsersTable`.
Session persistence and the Better Auth runtime remain provided by
`dart_better_auth`.

Auth-managed migrations are disabled by default. Production applications should
create and evolve the Better Auth tables through their normal migration system.
Set `manageMigrations: true` only for throwaway/demo databases.

For PostgreSQL deployments that isolate auth tables in a separate schema, pass
`databaseSchema: 'auth'` and create that schema and its tables yourself.
`hippo_auth_backend` forwards the schema to `dart_better_auth`, and backend
session lookups use the schema-aware SQL table descriptors.
