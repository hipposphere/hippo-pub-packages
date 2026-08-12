## 0.2.0

* Breaking: Move Flutter authentication widgets and the login flow to `hippo_auth_ui`.
* Remove the `hippo_components` and `hippo_utils` dependencies.
* Export `HippoAuthLoginController` for UI integrations.

## 0.1.19

* Centralize proactive, single-flight session renewal in the auth controller.
* Report why a stored session ended and clear expired or invalid credentials.
* Revoke the backend session during sign-out before clearing local credentials.
* Redact bearer tokens from session diagnostics.

## 0.1.15

* Use the configured SSO callback URL scheme when starting OAuth web auth.

## 0.0.1

* TODO: Describe initial release.
