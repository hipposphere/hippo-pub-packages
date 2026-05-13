`app_release_client` provides a release-channel aware appcast client for Flutter apps.

## Features

- `AppReleaseClientBloc` with `appCastUrlSubject` (resolved appcast URL)
- Channel loading via public channels APIs (`/api/public/v1/channels`)
- Persisted selected channel using `hippo_core` `KeyValueStore`
- Persisted known hidden-channel slugs for repeated hidden lookups
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
  // optional interceptors, e.g. custom headers for your release API host
  interceptors: const [],
  // optional optimization; if omitted, appSlug is used for public channel lookups
  appId: null,
  // optional: defaults to true; set false to include persisted hidden channel slugs
  publicChannelsOnly: true,
  // optional custom store key for known hidden slugs
  knownHiddenChannelSlugsStoreKey: 'app_release_client.known_hidden_channel_slugs',
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
