part of '../page.dart';

class DeviceListSidebar extends StatelessWidget {
  const DeviceListSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = HidTestingInterfaceBloc.of(context);

    return Container(
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
    );
  }

  Widget _buildFilters(HidTestingInterfaceBloc bloc, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filters', style: Theme.of(context).textTheme.headlineSmall),
              DataSubjectBuilder<List<HidDeviceInfo>?>(
                subject: bloc.hidDeviceInfosSubject,
                builder: (context, devices) => Text(
                  '${devices?.length ?? 0} found',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
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
          Row(
            children: [
              Expanded(
                child: Button(
                  onTap: bloc.reloadHidDevices,
                  label: 'Refresh',
                  prefix: const Icon(Icons.refresh),
                  type: ButtonType.secondary,
                ),
              ),
              const SizedBox(width: 8),
              DataSubjectBuilder<bool>(
                subject: bloc.autoRefreshEnabledSubject,
                builder: (context, enabled) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Auto',
                        style: TextStyle(
                          fontSize: 12,
                          color: enabled ? Colors.green : Colors.grey,
                        ),
                      ),
                      Switch.adaptive(
                        value: enabled,
                        onChanged: (_) => bloc.toggleAutoRefresh(),
                      ),
                    ],
                  );
                },
              ),
            ],
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
}
