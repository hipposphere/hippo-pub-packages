# analytics_posthog

PostHog analytics provider package for the `AnalyticsProvider` abstraction from
`hippo_utils`.

## Usage

```dart
import 'package:analytics_posthog/analytics_posthog.dart';
import 'package:hippo_utils/hippo_utils.dart';

void setupAnalytics() {
  Analytics.initialize(PosthogAnalyticsProvider());
}
```
