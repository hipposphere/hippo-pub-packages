import 'package:flutter/material.dart';
import 'package:desktop_permissions/desktop_permissions.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _desktopPermissions = DesktopPermissions();

  bool? _accessibilityGranted;
  bool? _inputMonitoringGranted;
  PermissionStatus? _accessibilityStatus;
  PermissionStatus? _inputMonitoringStatus;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    try {
      final accessibilityGranted = await _desktopPermissions
          .isAccessibilityGranted();
      final inputMonitoringGranted = await _desktopPermissions
          .isInputMonitoringGranted();
      final accessibilityStatus = await _desktopPermissions
          .getAccessibilityStatus();
      final inputMonitoringStatus = await _desktopPermissions
          .getInputMonitoringStatus();

      setState(() {
        _accessibilityGranted = accessibilityGranted;
        _inputMonitoringGranted = inputMonitoringGranted;
        _accessibilityStatus = accessibilityStatus;
        _inputMonitoringStatus = inputMonitoringStatus;
      });
    } catch (e) {
      debugPrint('Error checking permissions: $e');
    }
  }

  Future<void> _requestAccessibility({bool openPreferences = true}) async {
    final granted = await _desktopPermissions.requestAccessibility(
      openSystemPreferences: openPreferences,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            granted
                ? 'Accessibility permission granted!'
                : 'Please grant Accessibility permission in System Settings',
          ),
          duration: const Duration(seconds: 3),
        ),
      );

      // Recheck after a delay to allow user to grant permission
      if (!granted && openPreferences) {
        await Future.delayed(const Duration(seconds: 2));
        _checkPermissions();
      }
    }
  }

  Future<void> _requestInputMonitoring({bool openPreferences = true}) async {
    final granted = await _desktopPermissions.requestInputMonitoring(
      openSystemPreferences: openPreferences,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            granted
                ? 'Input Monitoring permission granted!'
                : 'Please grant Input Monitoring permission in System Settings',
          ),
          duration: const Duration(seconds: 3),
        ),
      );

      if (!granted && openPreferences) {
        await Future.delayed(const Duration(seconds: 2));
        _checkPermissions();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Desktop Permissions Example'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildPermissionCard(
                  title: 'Accessibility Permission',
                  description:
                      'Required for global keyboard monitoring and simulating input',
                  isGranted: _accessibilityGranted,
                  status: _accessibilityStatus,
                  onRequestWithPrompt: () =>
                      _requestAccessibility(openPreferences: false),
                  onRequestWithSettings: () =>
                      _requestAccessibility(openPreferences: true),
                ),
                const SizedBox(height: 24),
                _buildPermissionCard(
                  title: 'Input Monitoring Permission',
                  description:
                      'Required for monitoring keyboard/mouse when app is not focused',
                  isGranted: _inputMonitoringGranted,
                  status: _inputMonitoringStatus,
                  onRequestWithPrompt: () =>
                      _requestInputMonitoring(openPreferences: false),
                  onRequestWithSettings: () =>
                      _requestInputMonitoring(openPreferences: true),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _checkPermissions,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh Permission Status'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionCard({
    required String title,
    required String description,
    required bool? isGranted,
    required PermissionStatus? status,
    required VoidCallback onRequestWithPrompt,
    required VoidCallback onRequestWithSettings,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isGranted == true ? Icons.check_circle : Icons.error_outline,
                  color: isGranted == true ? Colors.green : Colors.orange,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            _buildStatusRow('Granted:', isGranted),
            const SizedBox(height: 8),
            _buildStatusRow('Status:', status),
            const SizedBox(height: 16),
            if (isGranted != true) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onRequestWithPrompt,
                      child: const Text('Request (Prompt)'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onRequestWithSettings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Open Settings'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, dynamic value) {
    String displayValue;
    if (value == null) {
      displayValue = 'Checking...';
    } else if (value is bool) {
      displayValue = value ? 'Yes ✓' : 'No ✗';
    } else if (value is PermissionStatus) {
      displayValue = value.name;
    } else {
      displayValue = value.toString();
    }

    return Row(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(width: 8),
        Text(displayValue, style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }
}
