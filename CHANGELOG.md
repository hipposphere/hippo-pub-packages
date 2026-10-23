# Workspace changelog

## Unreleased

- Retire `hippo_native_deps` and its vendored RapidJSON and WIL headers after
  `desktop_autopaste_windows` 0.3.11 switched to typed FFI and standard C++
  handle ownership. No remaining package in this workspace depends on it.
- Keep previously published `hippo_native_deps` versions available for legacy
  consumers, including older `speech_utils` releases.
- Retire `analytics_posthog`, `app_release_client`, `hippo_auth_ui`, and
  `live_audio` from this source workspace, including their examples and tests.
- Remove the `hippo_auth` UI example because it depends on the retired
  `hippo_auth_ui` package.
- Previously published package versions remain available in their registries.
  Remaining packages keep their current APIs and versions.
