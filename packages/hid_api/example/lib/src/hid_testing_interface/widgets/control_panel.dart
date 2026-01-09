part of '../page.dart';

class ControlPanel extends StatelessWidget {
  const ControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = HidTestingInterfaceBloc.of(context);

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
}
