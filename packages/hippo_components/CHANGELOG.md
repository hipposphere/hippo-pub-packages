## Unreleased

## 0.1.62

- Remove the unused native context menu API and its `nativeapi` dependency.

## 0.1.61

- Allow `PageHeader` callers to set the navigation bar brightness so transparent
  headers can select the correct system status bar appearance.
- Expose `CupertinoApp.builder` through `App.builder` for app-wide layers that
  must remain above the navigator.
- Migrate the JSON Schema editor and visualization to `json_schema` 0.1.4 from
  `https://pub.hippolabs.org`.

## 0.1.54

- Add a details toggle to JSON schema visualization and hide metadata chips by default.
- Show JSON Pointer strings in schema path UI and allow copying them from the visualization chip.
- Update `forui`, `lottie`, `nativeapi`, and `webview_flutter`
  dependency constraints.
- Raise the minimum `hippo_utils` dependency to `^0.3.3`.

## 0.1.0:
- First release
