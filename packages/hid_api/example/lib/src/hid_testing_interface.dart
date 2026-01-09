import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hid_api/hid_api.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:hippo_utils/hippo_utils.dart';

Future<void> openHidTestingInterface(BuildContext context) async {
  await Routing.openPage(
    context,
    BlocProvider<HidTestingInterfaceBloc>(
      bloc: HidTestingInterfaceBloc(),
      child: const HidTestingInterfacePage(),
    ),
  );
}

class HidTestingInterfaceBloc extends BlocBase {
  HidTestingInterfaceBloc() {
    _initBloc();
    vendorIdController.addListener(reloadHidDevices);
    productIdController.addListener(reloadHidDevices);
  }

  final vendorIdController = TextEditingController();
  final productIdController = TextEditingController();

  final hidDeviceInfosSubject = DataSubject<List<HidDeviceInfo>?>.seeded(null);
  final selectedDeviceInfoSubject = DataSubject<HidDeviceInfo?>.seeded(null);
  final connectedDeviceSubject = DataSubject<HidDevice?>.seeded(null);
  final hidEventsSubject = DataSubject<List<String>>.seeded([]);

  Future<void> _initBloc() async {
    await HidApi.initialize();
    await reloadHidDevices();
  }

  Future<void> reloadHidDevices() async {
    int? parseHexOrInt(String text) {
      if (text.isEmpty) return null;
      if (text.startsWith('0x')) {
        return int.tryParse(text.substring(2), radix: 16);
      }
      return int.tryParse(text);
    }

    final vendorId = parseHexOrInt(vendorIdController.text);
    final productId = parseHexOrInt(productIdController.text);

    final devices = await HidApi.enumerate(
      vendorId: vendorId,
      productId: productId,
    );
    hidDeviceInfosSubject.add(devices);
  }

  void selectDevice(HidDeviceInfo info) {
    selectedDeviceInfoSubject.add(info);
    if (connectedDeviceSubject.value != null) {
      disconnect();
    }
  }

  Future<void> connect() async {
    final info = selectedDeviceInfoSubject.value;
    if (info == null) return;

    try {
      final device = await HidApi.open(info.path);
      connectedDeviceSubject.add(device);
      _log('Connected to ${info.product ?? 'Unknown'} (${info.path})');
      _startReading(device);
    } catch (e) {
      _log('Error connecting: $e');
    }
  }

  Future<void> disconnect() async {
    final device = connectedDeviceSubject.value;
    if (device != null) {
      await device.close();
      connectedDeviceSubject.add(null);
      _log('Disconnected');
    }
  }

  void _startReading(HidDevice device) async {
    while (device.isOpen) {
      try {
        final report = await device.read(timeout: const Duration(seconds: 1));
        _log(
          'Received report: ${report.reportId}, data: ${report.data.map((e) => e.toRadixString(16).padLeft(2, '0')).join(' ')}',
        );
      } catch (e) {
        if (e is! HidTimeoutException) {
          if (device.isOpen) {
            _log('Read error: $e');
          }
          break;
        }
      }
    }
  }

  Future<void> sendReport(int reportId, List<int> data) async {
    final device = connectedDeviceSubject.value;
    if (device == null) return;

    try {
      await device.write(HidOutputReport(reportId, Uint8List.fromList(data)));
      _log(
        'Sent report: $reportId, data: ${data.map((e) => e.toRadixString(16).padLeft(2, '0')).join(' ')}',
      );
    } catch (e) {
      _log('Write error: $e');
    }
  }

  void _log(String message) {
    final current = hidEventsSubject.value;
    hidEventsSubject.add([
      '[${DateTime.now().toIso8601String().split('T').last.split('.').first}] $message',
      ...current.take(99),
    ]);
  }

  @override
  void dispose() {
    disconnect();
    vendorIdController.dispose();
    productIdController.dispose();
  }

  static HidTestingInterfaceBloc of(BuildContext context) {
    return BlocProvider.of<HidTestingInterfaceBloc>(context);
  }
}

class HidTestingInterfacePage extends StatelessWidget {
  const HidTestingInterfacePage({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = HidTestingInterfaceBloc.of(context);

    return PageContainer(
      title: 'HID-Testing-Interface',
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sidebar: Device List and Filters
          Container(
            width: 350,
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Column(
              children: [
                _buildFilters(bloc, context),
                const Divider(),
                Expanded(child: _buildDeviceList(bloc)),
              ],
            ),
          ),
          // Main content: Device details and Monitor
          Expanded(
            child: Column(
              children: [
                Expanded(child: _buildControlPanel(bloc, context)),
                const Divider(),
                Expanded(child: _buildEventLog(bloc, context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(HidTestingInterfaceBloc bloc, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filters', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: StyledTextfield(
                  controller: bloc.vendorIdController,
                  label: const Text('Vendor ID'),
                  hint: 'e.g. 0x05f3',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StyledTextfield(
                  controller: bloc.productIdController,
                  label: const Text('Product ID'),
                  hint: 'e.g. 0x0001',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Button(
            onTap: bloc.reloadHidDevices,
            label: 'Refresh Devices',
            prefix: const Icon(Icons.refresh),
            type: ButtonType.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceList(HidTestingInterfaceBloc bloc) {
    return DataSubjectBuilder<List<HidDeviceInfo>?>(
      subject: bloc.hidDeviceInfosSubject,
      builder: (context, devices) {
        if (devices == null) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }
        if (devices.isEmpty) {
          return const Center(child: Text('No devices found'));
        }

        return ListView.builder(
          itemCount: devices.length,
          itemBuilder: (context, index) {
            final device = devices[index];
            return DataSubjectBuilder<HidDeviceInfo?>(
              subject: bloc.selectedDeviceInfoSubject,
              builder: (context, selected) {
                final isSelected = selected?.path == device.path;
                return ListTile(
                  selected: isSelected,
                  title: Text(
                    device.product?.isEmpty ?? true
                        ? 'Unknown Product'
                        : device.product!,
                  ),
                  subtitle: Text(
                    'VID: 0x${device.vendorId.toRadixString(16).padLeft(4, '0')} '
                    'PID: 0x${device.productId.toRadixString(16).padLeft(4, '0')}',
                  ),
                  onTap: () => bloc.selectDevice(device),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildControlPanel(
    HidTestingInterfaceBloc bloc,
    BuildContext context,
  ) {
    return DataSubjectBuilder<HidDeviceInfo?>(
      subject: bloc.selectedDeviceInfoSubject,
      builder: (context, info) {
        if (info == null) {
          return const Center(child: Text('Select a device to see details'));
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Device Details',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Path', info.path),
              _buildDetailRow('Manufacturer', info.manufacturer ?? 'Unknown'),
              _buildDetailRow('Product', info.product ?? 'Unknown'),
              _buildDetailRow('Serial Number', info.serialNumber ?? 'None'),
              _buildDetailRow(
                'Release',
                '0x${info.releaseNumber.toRadixString(16).padLeft(4, '0')}',
              ),
              _buildDetailRow(
                'Usage Page',
                '0x${info.usagePage.toRadixString(16).padLeft(4, '0')}',
              ),
              _buildDetailRow(
                'Usage',
                '0x${info.usage.toRadixString(16).padLeft(4, '0')}',
              ),
              _buildDetailRow('Interface', info.interfaceNumber.toString()),
              const SizedBox(height: 24),
              DataSubjectBuilder<HidDevice?>(
                subject: bloc.connectedDeviceSubject,
                builder: (context, connected) {
                  final isConnected = connected != null;
                  return Row(
                    children: [
                      Button(
                        onTap: isConnected ? bloc.disconnect : bloc.connect,
                        label: isConnected ? 'Disconnect' : 'Connect',
                        prefix: Icon(isConnected ? Icons.link_off : Icons.link),
                        type: isConnected
                            ? ButtonType.destructive
                            : ButtonType.primary,
                      ),
                      if (isConnected) ...[
                        const SizedBox(width: 16),
                        Expanded(child: _buildSendReportAction(bloc)),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildSendReportAction(HidTestingInterfaceBloc bloc) {
    final reportIdController = TextEditingController(text: '0');
    final dataController = TextEditingController();

    return Row(
      children: [
        SizedBox(
          width: 80,
          child: StyledTextfield(
            controller: reportIdController,
            label: const Text('ID'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: StyledTextfield(
            controller: dataController,
            label: const Text('Data (hex)'),
            hint: 'e.g. 01 02 FF',
          ),
        ),
        const SizedBox(width: 8),
        Button(
          onTap: () {
            final id = int.tryParse(reportIdController.text) ?? 1;
            final data = dataController.text
                .split(' ')
                .where((s) => s.isNotEmpty)
                .map((s) => int.tryParse(s, radix: 16))
                .whereType<int>()
                .toList();
            bloc.sendReport(id, data);
          },
          label: 'Send',
        ),
      ],
    );
  }

  Widget _buildEventLog(HidTestingInterfaceBloc bloc, BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.05),
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Event Log',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Button(
                onTap: () => bloc.hidEventsSubject.add([]),
                label: 'Clear',
                type: ButtonType.secondary,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: DataSubjectBuilder<List<String>>(
              subject: bloc.hidEventsSubject,
              builder: (context, logs) {
                return ListView.builder(
                  controller: ScrollController(), // To stay at top normally
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    return Text(
                      logs[index],
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
