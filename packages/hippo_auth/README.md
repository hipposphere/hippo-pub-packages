# hippo_auth

Authentication state, session management, API access, and login controllers for
Hipposphere Flutter applications.

This package provides the authentication SDK without depending on
`hippo_components` or `hippo_utils`. Applications supply their own login UI.

```dart
import 'package:hippo_auth/hippo_auth.dart';

final authBloc = HippoAuthBloc.create(
  baseUrl: Uri.parse('https://example.com/auth'),
  sessionStore: sessionStore,
);
```
