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

        return LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DataSubjectBuilder<HidDevice?>(
                      subject: bloc.connectedDeviceSubject,
                      builder: (context, connected) {
                        final isConnected = connected != null;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Device Connection',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineSmall,
                                ),
                                Button(
                                  onTap: isConnected
                                      ? bloc.disconnect
                                      : bloc.connect,
                                  label: isConnected ? 'Disconnect' : 'Connect',
                                  prefix: Icon(
                                    isConnected ? Icons.link_off : Icons.link,
                                  ),
                                  type: isConnected
                                      ? ButtonType.destructive
                                      : ButtonType.primary,
                                ),
                              ],
                            ),
                            if (isConnected) ...[
                              const SizedBox(height: 16),
                              _buildSendReportAction(
                                bloc,
                                constraints.maxWidth,
                              ),
                            ],
                            const Divider(height: 32),
                          ],
                        );
                      },
                    ),
                    Text(
                      'Device Information',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow('Path', info.path),
                    _buildDetailRow(
                      'Manufacturer',
                      info.manufacturer ?? 'Unknown',
                    ),
                    _buildDetailRow('Product', info.product ?? 'Unknown'),
                    _buildDetailRow(
                      'Serial Number',
                      info.serialNumber ?? 'None',
                    ),
                    _buildDetailRow('Release', formatValue(info.releaseNumber)),
                    _buildDetailRow('Usage Page', formatValue(info.usagePage)),
                    _buildDetailRow('Usage', formatValue(info.usage)),
                    _buildDetailRow(
                      'Interface',
                      info.interfaceNumber.toString(),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String formatValue(int value) {
    final hex = '0x${value.toRadixString(16).toUpperCase().padLeft(4, '0')}';
    return '$hex ($value)';
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSendReportAction(HidTestingInterfaceBloc bloc, double maxWidth) {
    final reportIdController = TextEditingController(text: '0');
    final dataController = TextEditingController();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: [
        SizedBox(
          width: 140,
          child: DataSubjectBuilder<HidReportType>(
            subject: bloc.reportTypeSubject,
            builder: (context, currentType) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Report Type',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  DropdownButton<HidReportType>(
                    value: currentType,
                    isDense: true,
                    isExpanded: true,
                    items: HidReportType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(
                          type.label,
                          style: const TextStyle(fontSize: 13),
                        ),
                      );
                    }).toList(),
                    onChanged: (type) {
                      if (type != null) bloc.setReportType(type);
                    },
                  ),
                ],
              );
            },
          ),
        ),
        SizedBox(
          width: 120,
          child: DataSubjectBuilder<String?>(
            subject: bloc.reportIdErrorSubject,
            builder: (context, error) {
              final isValid =
                  error == null && reportIdController.text.isNotEmpty;
              return StyledTextfield(
                controller: reportIdController,
                label: const Text('ID'),
                error: error != null ? Text(error) : null,
                onChange: (val) => bloc.validateReportId(val),
                suffix: isValid
                    ? const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 16,
                      )
                    : null,
              );
            },
          ),
        ),
        SizedBox(
          width: maxWidth > 500 ? 250 : maxWidth - 32,
          child: DataSubjectBuilder<String?>(
            subject: bloc.dataErrorSubject,
            builder: (context, error) {
              final isValid = error == null && dataController.text.isNotEmpty;
              return StyledTextfield(
                controller: dataController,
                label: const Text('Data (hex)'),
                hint: 'e.g. 01 02 FF',
                error: error != null ? Text(error) : null,
                onChange: (val) => bloc.validateData(val),
                suffix: isValid
                    ? const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 16,
                      )
                    : null,
              );
            },
          ),
        ),
        CombinedDataSubjectBuilder<String?, String?>(
          subject1: bloc.reportIdErrorSubject,
          subject2: bloc.dataErrorSubject,
          builder: (context, idError, dataError) {
            final isEnabled =
                idError == null &&
                dataError == null &&
                reportIdController.text.isNotEmpty;
            return Button(
              enabled: isEnabled,
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
              prefix: const Icon(Icons.send, size: 16),
            );
          },
        ),
      ],
    );
  }
}
