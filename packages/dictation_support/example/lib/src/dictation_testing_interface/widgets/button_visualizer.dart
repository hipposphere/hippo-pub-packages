part of '../page.dart';

class ButtonVisualizer extends StatelessWidget {
  const ButtonVisualizer({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = DictationTestingBloc.of(context);

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Button States',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: DataSubjectBuilder<DictationDevice?>(
              subject: bloc.selectedDeviceSubject,
              builder: (context, device) {
                if (device == null) {
                  return const Center(
                    child: Text('Select a device to see button states'),
                  );
                }

                return DataSubjectBuilder<int>(
                  subject: bloc.currentButtonStateSubject,
                  builder: (context, bitmask) {
                    return SingleChildScrollView(
                      child: _buildButtonGrid(bitmask, device),
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

  Widget _buildButtonGrid(int bitmask, DictationDevice device) {
    final buttons = _getButtonsForDevice(device);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: buttons.map((button) {
        final isPressed = (bitmask & button.flag) != 0;
        return _ButtonIndicator(label: button.label, isPressed: isPressed);
      }).toList(),
    );
  }

  List<_ButtonInfo> _getButtonsForDevice(DictationDevice device) {
    // Common buttons for most devices
    final List<_ButtonInfo> buttons = [
      _ButtonInfo('Record', ButtonEvent.record),
      _ButtonInfo('Play', ButtonEvent.play),
      _ButtonInfo('Stop', ButtonEvent.stop),
      _ButtonInfo('Rewind', ButtonEvent.rewind),
      _ButtonInfo('Forward', ButtonEvent.forward),
    ];

    // Device-specific buttons
    if (device is SpeechMikeHidDevice) {
      buttons.addAll([
        _ButtonInfo('Ins/Ovr', ButtonEvent.insOvr),
        _ButtonInfo('Command', ButtonEvent.command),
        _ButtonInfo('Instr', ButtonEvent.instr),
        _ButtonInfo('F1/A', ButtonEvent.f1A),
        _ButtonInfo('F2/B', ButtonEvent.f2B),
        _ButtonInfo('F3/C', ButtonEvent.f3C),
        _ButtonInfo('F4/D', ButtonEvent.f4D),
        _ButtonInfo('EOL/Prio', ButtonEvent.eolPrio),
        _ButtonInfo('Scan End', ButtonEvent.scanEnd),
        _ButtonInfo('Scan Success', ButtonEvent.scanSuccess),
      ]);
    } else if (device is PowerMic3Device) {
      buttons.addAll([
        _ButtonInfo('Transcribe', ButtonEvent.transcribe),
        _ButtonInfo('Tab Back', ButtonEvent.tabBackward),
        _ButtonInfo('Tab Forward', ButtonEvent.tabForward),
        _ButtonInfo('Custom Left', ButtonEvent.customLeft),
        _ButtonInfo('Custom Right', ButtonEvent.customRight),
        _ButtonInfo('Enter/Select', ButtonEvent.enterSelect),
      ]);
    } else if (device is FootControlDevice) {
      // FootControl has simpler button set
      buttons.add(_ButtonInfo('EOL/Prio', ButtonEvent.eolPrio));
    }

    return buttons;
  }
}

class _ButtonInfo {
  final String label;
  final int flag;

  const _ButtonInfo(this.label, this.flag);
}

class _ButtonIndicator extends StatelessWidget {
  final String label;
  final bool isPressed;

  const _ButtonIndicator({required this.label, required this.isPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 60,
      decoration: BoxDecoration(
        color: isPressed
            ? Theme.of(context).colorScheme.primary
            : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isPressed
              ? Theme.of(context).colorScheme.primary
              : Colors.grey.shade400,
          width: 2,
        ),
        boxShadow: isPressed
            ? [
                BoxShadow(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.4),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isPressed ? Colors.white : Colors.black87,
            fontWeight: isPressed ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
