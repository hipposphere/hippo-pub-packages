part of '../page.dart';

class DictationDeviceList extends StatelessWidget {
  const DictationDeviceList({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = DictationTestingBloc.of(context);

    return Container(
      width: 280,
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Dictation Devices',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: DataSubjectBuilder<List<DictationDevice>>(
              subject: bloc.devicesSubject,
              builder: (context, devices) {
                if (devices.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'No dictation devices found.\n\nConnect a SpeechMike, FootControl, or PowerMic device.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return DataSubjectBuilder<DictationDevice?>(
                  subject: bloc.selectedDeviceSubject,
                  builder: (context, selected) {
                    return ListView.builder(
                      itemCount: devices.length,
                      itemBuilder: (context, index) {
                        final device = devices[index];
                        final isSelected = selected?.id == device.id;
                        return _DeviceListTile(
                          device: device,
                          isSelected: isSelected,
                          onTap: () => bloc.selectDevice(device),
                        );
                      },
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

class _DeviceListTile extends StatelessWidget {
  final DictationDevice device;
  final bool isSelected;
  final VoidCallback onTap;

  const _DeviceListTile({
    required this.device,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = device.getDeviceType();
    final implType = device.implType;

    return ListTile(
      selected: isSelected,
      leading: Icon(_getDeviceIcon(implType)),
      title: Text(deviceType.name),
      subtitle: Text(_getImplTypeLabel(implType)),
      onTap: onTap,
    );
  }

  IconData _getDeviceIcon(ImplementationType type) {
    switch (type) {
      case ImplementationType.speechMikeHid:
      case ImplementationType.speechMikeGamepad:
        return Icons.mic;
      case ImplementationType.footControl:
        return Icons.gamepad;
      case ImplementationType.powerMic3:
        return Icons.settings_voice;
    }
  }

  String _getImplTypeLabel(ImplementationType type) {
    switch (type) {
      case ImplementationType.speechMikeHid:
        return 'SpeechMike HID';
      case ImplementationType.speechMikeGamepad:
        return 'SpeechMike Gamepad';
      case ImplementationType.footControl:
        return 'Foot Control';
      case ImplementationType.powerMic3:
        return 'PowerMic III';
    }
  }
}
