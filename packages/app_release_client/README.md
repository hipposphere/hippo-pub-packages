`app_release_client` provides a release-channel aware appcast client for Flutter apps.

## Features

- `AppReleaseClientBloc` with `appCastUrlSubject` (resolved appcast URL)
- Channel list loading from app-release-manager OpenAPI client
- Persisted selected channel using `hippo_utils` `KeyValueStore`
- Default `AppReleaseChannelSelector` widget for channel selection UI

## Basic usage

```dart
final bloc = AppReleaseClientBloc.create(
  baseUrl: Uri.parse('https://release-manager.example.com'),
  keyValueStore: SharedPreferencesKeyValueStore(),
  appSlug: 'hippo-desktop',
  platform: AppReleasePlatform.macos,
  // optional
  arch: AppReleaseArch.arm64,
  // optional: appcast query packageType=dmg&packageType=zip
  packageTypes: const ['dmg', 'zip'],
  // optional interceptors, e.g. auth headers for /api/v1/apps + /api/v1/channels
  interceptors: const [],
  // optional if you already know it; otherwise resolved via list apps
  appId: null,
  // optional: defaults to 'stable'
  defaultChannelSlug: 'stable',
);
```

Use with `BlocProvider` and UI:

```dart
BlocProvider<AppReleaseClientBloc>(
  bloc: bloc,
  child: Column(
    children: [
      const AppReleaseChannelSelector(),
      AppReleaseClientBuilder(
        builder: (context, value) {
          final appcastUrl = value?.value;
          return Text(appcastUrl?.toString() ?? 'No appcast URL');
        },
      ),
    ],
  ),
)
```

## OpenAPI regeneration

1. Replace `specs/openapi.json` with the latest spec.
2. Run:

```bash
make build
```

The build step normalizes `anyOf([enum, null])` schemas before running `swagger_dart_code_generator` to keep generation stable.

## Small example

A minimal Flutter example is available at:

- `packages/app_release_client/example/lib/main.dart`

Run it from the repository root:

```bash
dart pub get
cd packages/app_release_client/example
flutter run
```
