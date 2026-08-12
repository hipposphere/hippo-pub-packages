# hippo_auth_ui

Ready-made Flutter authentication widgets and email/SSO login flows built on
[`hippo_auth`](../hippo_auth/README.md).

`hippo_auth_ui` owns the presentation dependencies on `hippo_components` and
`hippo_utils`, keeping the core authentication package independent of them.

```dart
import 'package:hippo_auth/hippo_auth.dart';
import 'package:hippo_auth_ui/hippo_auth_ui.dart';

HippoAuthWrapper(
  loadingBuilder: (_) => const CircularProgressIndicator.adaptive(),
  loginBuilder: (_) => const HippoAuthLoginFlow(),
  childBuilder: (_, session) => Text('Session: ${session.id}'),
);
```
