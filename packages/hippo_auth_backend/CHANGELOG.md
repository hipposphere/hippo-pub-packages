## 0.2.0

* Replace `dart_edge_auth` with the standalone `dart_better_auth` package.

## 0.1.26

* Allow explicitly trusted custom-scheme origins as final OAuth application
  callbacks for native clients.

## 0.1.25

* Make session refresh idempotent while a session is still healthy.
* Revoke the server-side session during logout.
* Mark invalid bearer sessions with a `WWW-Authenticate` challenge.

## 0.1.21

* Update Dart Edge auth, SQL, and HTTP server runtime package constraints.

## 0.1.17

* Relay OAuth SSO callbacks through the backend callback route so native
  loopback app callbacks are not sent to the OAuth provider as `redirect_uri`.
* Add provider-level OAuth `redirectUrl` configuration and loopback callback
  validation for desktop/native SSO clients.
* Read OAuth callback session tokens from Better Auth session cookies.
* Allow generic OAuth SSO providers to omit `clientSecret` for public-client
  PKCE flows supported by `dart_edge_auth`.
* Allow generic OIDC SSO providers to omit `userInfoUrl` and rely on
  `id_token` claims when supported by `dart_edge_auth`.

## 0.1.16

* Expose `trustedOrigins` in `HippoAuthBackendOptions` and forward it to
  `dart_edge_auth`.

## 0.1.0

* TODO: Describe initial release.
