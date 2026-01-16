# app_permissions

A Flutter plugin for checking and requesting desktop permissions, with a focus on **Accessibility** and **Input Monitoring** permissions required by desktop applications.

## Features

- ✅ Check if Accessibility permission is granted (Desktop)
- ✅ Request Accessibility permission (opens System Settings on macOS)
- ✅ Check if Input Monitoring permission is granted (Desktop)
- ✅ Request Input Monitoring permission (opens System Settings on macOS)
- ✅ Check if Microphone permission is granted (All platforms)
- ✅ Request Microphone permission (All platforms)
- ✅ Get detailed permission status (granted, denied, notDetermined, notRequired)
- ✅ Cross-platform support (macOS, Windows, iOS, Android)
- ✅ Simple, consistent API across platforms

## Platform Support

| Platform | Accessibility | Input Monitoring | Microphone |
|----------|---------------|------------------|------------|
| **macOS** | ✅ Required | ✅ Required | ✅ Required |
| **Windows**| ⚪ Not Required | ⚪ Not Required | ⚪ Not Required |
| **iOS** | ⚪ Not Required | ⚪ Not Required | ✅ Required |
| **Android**| ⚪ Not Required | ⚪ Not Required | ✅ Required |

### macOS Permissions

On macOS, these permissions are required for:

**Accessibility Permission:**
- Simulating keyboard and mouse input (`CGEvent` API)
- Monitoring keyboard/mouse events globally
- UI element inspection and automation

**Input Monitoring Permission:**
- Capturing keyboard/mouse input when your app is not focused
- Global hotkey detection
- Similar to Accessibility for most use cases

### Windows

Windows applications can use keyboard hooks (`SetWindowsHookEx`) and input simulation (`SendInput`) without requiring special permissions, so all permission checks return `true`/`notRequired`.

## Usage

### Basic Permission Check

```dart
import 'package:app_permissions/app_permissions.dart';

final permissions = AppPermissions();

// Check if Accessibility permission is granted
final isGranted = await permissions.isAccessibilityGranted();

if (!isGranted) {
  print('Accessibility permission is not granted');
}
```

### Request Permission

```dart
// Option 1: Show system prompt (only works first time)
final granted = await permissions.requestAccessibility(
  openSystemPreferences: false,
);

// Option 2: Open System Settings (recommended)
final granted = await permissions.requestAccessibility(
  openSystemPreferences: true,
);

if (granted) {
  print('Permission granted!');
} else {
  print('Please grant permission in System Settings');
}
```

### Get Detailed Status

```dart
final status = await permissions.getAccessibilityStatus();

switch (status) {
  case PermissionStatus.granted:
    print('Permission is granted');
    break;
  case PermissionStatus.denied:
    print('Permission was denied');
    break;
  case PermissionStatus.notDetermined:
    print('Permission not yet requested');
    break;
  case PermissionStatus.notRequired:
    print('Platform does not require this permission');
    break;
}
```

### Input Monitoring Permission

```dart
// Similar API for Input Monitoring
final isGranted = await permissions.isInputMonitoringGranted();
final status = await permissions.getInputMonitoringStatus();

await permissions.requestInputMonitoring(
  openSystemPreferences: true,
);
```

### Microphone Permission

Microphone permission is supported on all platforms. On macOS, iOS, and Android, it will trigger the system permission dialog.

```dart
// Check if Microphone permission is granted
final isGranted = await permissions.isMicrophoneGranted();

// Request Microphone permission
final granted = await permissions.requestMicrophone();

if (granted) {
  print('Microphone access granted!');
}
```

#### Android Setup

Add the following to your `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
```

#### iOS & macOS Setup

Add the following to your `Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs access to the microphone for audio recording.</string>
```

### Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:app_permissions/app_permissions.dart';

class PermissionChecker extends StatefulWidget {
  @override
  _PermissionCheckerState createState() => _PermissionCheckerState();
}

class _PermissionCheckerState extends State<PermissionChecker> {
  final _permissions = AppPermissions();
  bool _isGranted = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final granted = await _permissions.isAccessibilityGranted();
    setState(() => _isGranted = granted);
  }

  Future<void> _requestPermission() async {
    await _permissions.requestAccessibility(openSystemPreferences: true);
    
    // Give user time to grant permission, then recheck
    await Future.delayed(Duration(seconds: 2));
    _checkPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Accessibility: ${_isGranted ? "Granted ✓" : "Not Granted ✗"}'),
        if (!_isGranted)
          ElevatedButton(
            onPressed: _requestPermission,
            child: Text('Grant Permission'),
          ),
      ],
    );
  }
}
```

## When to Use This Package

This package is essential if your Flutter desktop app needs to:

1. **Monitor global keyboard/mouse input** (like `hotkey_api` package)
   - Capturing hotkeys when app is not focused
   - System-wide keyboard shortcuts

2. **Simulate keyboard/mouse input** (like `desktop_autopaste` package)
   - Auto-typing or auto-pasting text
   - Automating UI interactions

3. **Inspect UI elements** of other applications
   - Accessibility features
   - Screen readers

## macOS App Sandbox

If you're building a sandboxed macOS app, you don't need special entitlements in your `.entitlements` file for these permissions. The standard sandbox entitlements are sufficient:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.app-sandbox</key>
    <true/>
    <key>com.apple.security.cs.allow-jit</key>
    <true/>
    <key>com.apple.security.network.server</key>
    <true/>
</dict>
</plist>
```

The permission request will trigger the system dialog automatically.

## Best Practices

### 1. Check Before Use

Always check if permission is granted before attempting operations that require it:

```dart
final granted = await permissions.isAccessibilityGranted();
if (!granted) {
  // Show UI to request permission
  await permissions.requestAccessibility(openSystemPreferences: true);
  return;
}

// Proceed with operation
```

### 2. Explain Why You Need Permission

Show a dialog explaining why your app needs the permission before requesting it:

```dart
await showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('Permission Required'),
    content: Text(
      'This app needs Accessibility permission to monitor global hotkeys. '
      'This allows you to trigger commands even when the app is in the background.',
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text('Cancel'),
      ),
      ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
          permissions.requestAccessibility(openSystemPreferences: true);
        },
        child: Text('Grant Permission'),
      ),
    ],
  ),
);
```

### 3. Handle Permission Denial Gracefully

If the user denies permission, provide a way to request it again:

```dart
if (!isGranted) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 64, color: Colors.orange),
        SizedBox(height: 16),
        Text('Accessibility Permission Required'),
        SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => permissions.requestAccessibility(
            openSystemPreferences: true,
          ),
          child: Text('Open System Settings'),
        ),
      ],
    ),
  );
}
```

### 4. Poll After Opening System Settings

Since macOS doesn't notify your app when permission is granted, poll the status after opening System Settings:

```dart
await permissions.requestAccessibility(openSystemPreferences: true);

// Poll every 2 seconds for up to 30 seconds
for (int i = 0; i < 15; i++) {
  await Future.delayed(Duration(seconds: 2));
  final granted = await permissions.isAccessibilityGranted();
  if (granted) {
    // Permission was granted!
    setState(() => _isGranted = true);
    break;
  }
}
```

## API Reference

### `AppPermissions`

Main class for permission management.

#### Methods

##### `isAccessibilityGranted()`
```dart
Future<bool> isAccessibilityGranted()
```
Returns `true` if Accessibility permission is granted.

##### `requestAccessibility({bool openSystemPreferences})`
```dart
Future<bool> requestAccessibility({bool openSystemPreferences = true})
```
Requests Accessibility permission. If `openSystemPreferences` is `true`, opens System Settings. Returns `true` if already granted.

##### `getAccessibilityStatus()`
```dart
Future<PermissionStatus> getAccessibilityStatus()
```
Returns detailed status: `granted`, `denied`, `notDetermined`, or `notRequired`.

##### `isInputMonitoringGranted()`
```dart
Future<bool> isInputMonitoringGranted()
```
Returns `true` if Input Monitoring permission is granted.

##### `requestInputMonitoring({bool openSystemPreferences})`
```dart
Future<bool> requestInputMonitoring({bool openSystemPreferences = true})
```
Requests Input Monitoring permission.

##### `getInputMonitoringStatus()`
```dart
Future<PermissionStatus> getInputMonitoringStatus()
```
Returns detailed Input Monitoring permission status.

### `PermissionStatus` enum

- `granted` - Permission has been granted
- `denied` - Permission has been explicitly denied
- `notDetermined` - Permission hasn't been requested yet
- `notRequired` - Platform doesn't require this permission

## Related Packages

This package works great with:

- [`hotkey_api`](../hotkey_api) - Global hotkey monitoring (requires Accessibility/Input Monitoring permission)
- [`desktop_autopaste`](../desktop_autopaste) - Auto-paste functionality (requires Accessibility permission)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
