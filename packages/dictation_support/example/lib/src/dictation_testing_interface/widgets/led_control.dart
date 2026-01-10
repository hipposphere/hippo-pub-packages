part of '../page.dart';

class LedControlPanel extends StatelessWidget {
  const LedControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = DictationTestingBloc.of(context);

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('LED Control', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Expanded(
            child: DataSubjectBuilder<DictationDevice?>(
              subject: bloc.selectedDeviceSubject,
              builder: (context, device) {
                if (device == null) {
                  return const Center(
                    child: Text('Select a device to control LEDs'),
                  );
                }

                if (device is! SpeechMikeHidDevice) {
                  return Center(
                    child: Text(
                      'LED control is only available for SpeechMike devices.\n\n'
                      'Selected: ${device.getDeviceType().name}',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _SimpleLedStateControl(bloc: bloc),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),
                      Text(
                        'Individual LED Control',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      _IndividualLedControls(bloc: bloc),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SimpleLedStateControl extends StatefulWidget {
  final DictationTestingBloc bloc;

  const _SimpleLedStateControl({required this.bloc});

  @override
  State<_SimpleLedStateControl> createState() => _SimpleLedStateControlState();
}

class _SimpleLedStateControlState extends State<_SimpleLedStateControl> {
  SimpleLedState _currentState = SimpleLedState.off;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick LED States',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: SimpleLedState.values.map((state) {
            final isSelected = _currentState == state;
            return Button(
              onTap: () {
                setState(() => _currentState = state);
                widget.bloc.setSimpleLedState(state);
              },
              label: _getStateName(state),
              type: isSelected ? ButtonType.primary : ButtonType.outline,
            );
          }).toList(),
        ),
      ],
    );
  }

  String _getStateName(SimpleLedState state) {
    switch (state) {
      case SimpleLedState.off:
        return 'Off';
      case SimpleLedState.recordInsert:
        return 'Record Insert';
      case SimpleLedState.recordOverwrite:
        return 'Record Overwrite';
      case SimpleLedState.recordStandbyInsert:
        return 'Standby Insert';
      case SimpleLedState.recordStandbyOverwrite:
        return 'Standby Overwrite';
    }
  }
}

class _IndividualLedControls extends StatelessWidget {
  final DictationTestingBloc bloc;

  const _IndividualLedControls({required this.bloc});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: LedIndex.values.map((ledIndex) {
        return _LedRow(ledIndex: ledIndex, bloc: bloc);
      }).toList(),
    );
  }
}

class _LedRow extends StatefulWidget {
  final LedIndex ledIndex;
  final DictationTestingBloc bloc;

  const _LedRow({required this.ledIndex, required this.bloc});

  @override
  State<_LedRow> createState() => _LedRowState();
}

class _LedRowState extends State<_LedRow> {
  LedMode _currentMode = LedMode.off;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 160,
            child: Text(
              _getLedName(widget.ledIndex),
              style: const TextStyle(fontSize: 13),
            ),
          ),
          Expanded(
            child: DropdownButton<LedMode>(
              value: _currentMode,
              isDense: true,
              isExpanded: true,
              items: LedMode.values.map((mode) {
                return DropdownMenuItem(
                  value: mode,
                  child: Text(_getModeName(mode)),
                );
              }).toList(),
              onChanged: (mode) {
                if (mode != null) {
                  setState(() => _currentMode = mode);
                  widget.bloc.setLed(widget.ledIndex, mode);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getLedName(LedIndex index) {
    switch (index) {
      case LedIndex.recordLedGreen:
        return 'Record LED (Green)';
      case LedIndex.recordLedRed:
        return 'Record LED (Red)';
      case LedIndex.instructionLedGreen:
        return 'Instruction LED (Green)';
      case LedIndex.instructionLedRed:
        return 'Instruction LED (Red)';
      case LedIndex.insOwrButtonLedGreen:
        return 'Ins/Owr Button (Green)';
      case LedIndex.insOwrButtonLedRed:
        return 'Ins/Owr Button (Red)';
      case LedIndex.f1ButtonLed:
        return 'F1 Button LED';
      case LedIndex.f2ButtonLed:
        return 'F2 Button LED';
      case LedIndex.f3ButtonLed:
        return 'F3 Button LED';
      case LedIndex.f4ButtonLed:
        return 'F4 Button LED';
    }
  }

  String _getModeName(LedMode mode) {
    switch (mode) {
      case LedMode.off:
        return 'Off';
      case LedMode.blinkSlow:
        return 'Blink Slow';
      case LedMode.blinkFast:
        return 'Blink Fast';
      case LedMode.on:
        return 'On';
    }
  }
}
