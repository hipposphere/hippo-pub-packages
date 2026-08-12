# hippo_auth

Authentication state, session management, API access, and login controllers for
Hipposphere Flutter applications.

This package intentionally does not depend on `hippo_components` or
`hippo_utils`. For the ready-made login flow and authentication widgets, use
[`hippo_auth_ui`](../hippo_auth_ui/README.md).

```dart
import 'package:hippo_auth/hippo_auth.dart';

final authBloc = HippoAuthBloc.create(
  baseUrl: Uri.parse('https://example.com/auth'),
  sessionStore: sessionStore,
);
```
