import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hippo_bluetooth_client/hippo_bluetooth_client.dart';

void main() {
  runApp(const _ExampleApp());
}

class _ExampleApp extends StatelessWidget {
  const _ExampleApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hippo BLE Client Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const _HomePage(),
    );
  }
}

class _HomePage extends StatefulWidget {
  const _HomePage();

  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  static const _serviceUuid = '12345678-1234-5678-1234-56789abc0000';
  static const _statusUuid = '12345678-1234-5678-1234-56789abc0001';
  static const _commandUuid = '12345678-1234-5678-1234-56789abc0002';
  static const _chunkUuid = '12345678-1234-5678-1234-56789abc0003';
  static const _challengeUuid = '12345678-1234-5678-1234-56789abc0004';
  static const _responseUuid = '12345678-1234-5678-1234-56789abc0005';
  static const _resultUuid = '12345678-1234-5678-1234-56789abc0006';

  final _gatt = FlutterBluePlusGattClient();
  final _commandController = TextEditingController(text: 'ping');

  StreamSubscription<BleScanResult>? _scanSubscription;
  StreamSubscription<String>? _statusSubscription;
  StreamSubscription<String>? _chunkSubscription;

  final List<BleScanResult> _scanResults = <BleScanResult>[];
  final List<String> _logs = <String>[];

  String? _remoteId;
  BleProtocolClient? _protocolClient;
  BluetoothLeAuthManager? _authManager;

  bool _isScanning = false;
  bool _isConnecting = false;

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _statusSubscription?.cancel();
    _chunkSubscription?.cancel();
    _authManager?.dispose();
    _protocolClient?.dispose();
    _gatt.dispose();
    _commandController.dispose();
    super.dispose();
  }

  Future<void> _startScan() async {
    await _scanSubscription?.cancel();
    _scanResults.clear();
    setState(() {
      _isScanning = true;
    });

    _scanSubscription = _gatt
        .scan(
          withServiceUuids: const <String>[_serviceUuid],
          timeout: const Duration(seconds: 8),
        )
        .listen(
          (result) {
            if (!_scanResults.any(
              (entry) => entry.remoteId == result.remoteId,
            )) {
              setState(() {
                _scanResults.add(result);
              });
            }
          },
          onError: (Object error) {
            _log('scan error: $error');
          },
          onDone: () {
            if (mounted) {
              setState(() {
                _isScanning = false;
              });
            }
          },
        );
  }

  Future<void> _stopScan() async {
    await _gatt.stopScan();
    await _scanSubscription?.cancel();
    if (mounted) {
      setState(() {
        _isScanning = false;
      });
    }
  }

  Future<void> _connect(String remoteId) async {
    setState(() {
      _isConnecting = true;
    });

    try {
      await _gatt.connect(remoteId, timeout: const Duration(seconds: 12));

      final protocol = BleProtocolDefinition(
        protocolId: 'demo',
        serviceUuid: _serviceUuid,
        channels: <BleChannelDefinition<dynamic>>[
          const BleChannelDefinition<String>(
            channelId: 'status',
            channelUuid: _statusUuid,
            properties: BleChannelProperties(read: true, notify: true),
            codec: Utf8ChannelCodec(),
          ),
          const BleChannelDefinition<String>(
            channelId: 'command',
            channelUuid: _commandUuid,
            properties: BleChannelProperties(write: true),
            codec: Utf8ChannelCodec(),
          ),
          const BleChannelDefinition<String>(
            channelId: 'chunkedData',
            channelUuid: _chunkUuid,
            properties: BleChannelProperties(write: true, notify: true),
            codec: Utf8ChannelCodec(),
          ),
          const BleChannelDefinition<Map<String, dynamic>>(
            channelId: 'authChallenge',
            channelUuid: _challengeUuid,
            properties: BleChannelProperties(read: true),
            codec: JsonMapChannelCodec(),
          ),
          const BleChannelDefinition<Map<String, dynamic>>(
            channelId: 'authResponse',
            channelUuid: _responseUuid,
            properties: BleChannelProperties(write: true),
            codec: JsonMapChannelCodec(),
          ),
          const BleChannelDefinition<Map<String, dynamic>>(
            channelId: 'authResult',
            channelUuid: _resultUuid,
            properties: BleChannelProperties(read: true),
            codec: JsonMapChannelCodec(),
          ),
        ],
      );

      final protocolClient = BleProtocolClient(
        gattClient: _gatt,
        remoteId: remoteId,
        protocols: <BleProtocolDefinition>[protocol],
      );

      final authManager = BluetoothLeAuthManager(
        protocolClient: protocolClient,
        channels: const BluetoothLeAuthChannels(
          protocolId: 'demo',
          challengeChannelId: 'authChallenge',
          responseChannelId: 'authResponse',
          resultChannelId: 'authResult',
        ),
        // Demo secret only. Replace with secure secret management.
        secret: Uint8List.fromList(utf8.encode('replace-me-in-production')),
      );

      if (mounted) {
        setState(() {
          _remoteId = remoteId;
          _protocolClient = protocolClient;
          _authManager = authManager;
        });
      }

      _log('connected: $remoteId');
    } on Object catch (error) {
      _log('connect error: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
      }
    }
  }

  Future<void> _disconnect() async {
    final id = _remoteId;
    if (id == null) {
      return;
    }

    await _statusSubscription?.cancel();
    await _chunkSubscription?.cancel();
    _statusSubscription = null;
    _chunkSubscription = null;

    await _authManager?.dispose();
    await _protocolClient?.dispose();

    _authManager = null;
    _protocolClient = null;

    try {
      await _gatt.disconnect(id);
      _log('disconnected: $id');
    } on Object catch (error) {
      _log('disconnect error: $error');
    }

    if (mounted) {
      setState(() {
        _remoteId = null;
      });
    }
  }

  Future<void> _authorize() async {
    final manager = _authManager;
    if (manager == null) {
      return;
    }

    try {
      final result = await manager.authorize();
      _log('authorized: ${result.sessionId}');
    } on Object catch (error) {
      _log('auth error: $error');
    }
  }

  Future<void> _readStatus() async {
    final client = _protocolClient;
    if (client == null) {
      return;
    }

    try {
      final status = await client.readChannel<String>('demo', 'status');
      _log('status read: $status');
    } on Object catch (error) {
      _log('read error: $error');
    }
  }

  Future<void> _writeCommand() async {
    final client = _protocolClient;
    if (client == null) {
      return;
    }

    try {
      await client.writeChannel<String>(
        'demo',
        'command',
        _commandController.text,
      );
      _log('command written: ${_commandController.text}');
    } on Object catch (error) {
      _log('write error: $error');
    }
  }

  Future<void> _subscribeStatus() async {
    final client = _protocolClient;
    if (client == null) {
      return;
    }

    await _statusSubscription?.cancel();
    _statusSubscription = client
        .subscribeChannel<String>('demo', 'status')
        .listen((value) => _log('status notify: $value'));

    _log('subscribed to status');
  }

  Future<void> _sendChunked() async {
    final client = _protocolClient;
    if (client == null) {
      return;
    }

    const text = 'This is a larger payload sent as chunked frames over BLE.';
    try {
      await client.sendChunked<String>(
        'demo',
        'chunkedData',
        text,
        options: const ChunkSendOptions(withoutResponse: true),
      );
      _log('chunked payload sent (${text.length} chars)');
    } on Object catch (error) {
      _log('chunked send error: $error');
    }
  }

  Future<void> _subscribeChunked() async {
    final client = _protocolClient;
    if (client == null) {
      return;
    }

    await _chunkSubscription?.cancel();
    _chunkSubscription = client
        .subscribeChunkedChannel<String>('demo', 'chunkedData')
        .listen((value) => _log('chunked payload: $value'));

    _log('subscribed to chunked channel');
  }

  void _log(String message) {
    setState(() {
      _logs.insert(0, '${DateTime.now().toIso8601String()}  $message');
      if (_logs.length > 100) {
        _logs.removeRange(100, _logs.length);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final connected = _remoteId != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Hippo BLE Client Example')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                FilledButton(
                  onPressed: _isScanning ? null : _startScan,
                  child: const Text('Scan'),
                ),
                OutlinedButton(
                  onPressed: _isScanning ? _stopScan : null,
                  child: const Text('Stop Scan'),
                ),
                OutlinedButton(
                  onPressed: connected && !_isConnecting ? _disconnect : null,
                  child: const Text('Disconnect'),
                ),
                Text(
                  connected
                      ? 'Connected: $_remoteId'
                      : (_isConnecting ? 'Connecting...' : 'Not connected'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Row(
                children: <Widget>[
                  Expanded(flex: 2, child: _buildDeviceList()),
                  const SizedBox(width: 12),
                  Expanded(flex: 3, child: _buildActionPanel(connected)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceList() {
    if (_scanResults.isEmpty) {
      return const Card(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Text('No scan results yet.'),
          ),
        ),
      );
    }

    return Card(
      child: ListView.builder(
        itemCount: _scanResults.length,
        itemBuilder: (context, index) {
          final item = _scanResults[index];
          return ListTile(
            title: Text(item.name.isEmpty ? '(unnamed)' : item.name),
            subtitle: Text('${item.remoteId}  RSSI=${item.rssi}'),
            trailing: FilledButton.tonal(
              onPressed: _isConnecting ? null : () => _connect(item.remoteId),
              child: const Text('Connect'),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionPanel(bool connected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                FilledButton.tonal(
                  onPressed: connected ? _authorize : null,
                  child: const Text('Authorize'),
                ),
                FilledButton.tonal(
                  onPressed: connected ? _readStatus : null,
                  child: const Text('Read Status'),
                ),
                FilledButton.tonal(
                  onPressed: connected ? _subscribeStatus : null,
                  child: const Text('Subscribe Status'),
                ),
                FilledButton.tonal(
                  onPressed: connected ? _sendChunked : null,
                  child: const Text('Send Chunked'),
                ),
                FilledButton.tonal(
                  onPressed: connected ? _subscribeChunked : null,
                  child: const Text('Subscribe Chunked'),
                ),
                SizedBox(
                  width: 240,
                  child: TextField(
                    controller: _commandController,
                    decoration: const InputDecoration(
                      labelText: 'Command',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                FilledButton(
                  onPressed: connected ? _writeCommand : null,
                  child: const Text('Write Command'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Card(
            child: ListView.builder(
              itemCount: _logs.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Text(_logs[index]),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
