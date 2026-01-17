part of 'page.dart';

class DictationTestingBloc extends BlocBase {
  DictationTestingBloc() {
    _initBloc();
  }

  final DictationDeviceManager _manager = DictationDeviceManager();

  DataSubject<List<DictationDevice>> get devicesSubject =>
      _manager.connectedDevicesSubject;
  final selectedDeviceSubject = DataSubject<DictationDevice?>.seeded(null);
  final currentButtonStateSubject = DataSubject<int>.seeded(0);
  final eventsSubject = DataSubject<List<String>>.seeded([]);

  StreamSubscription<int>? _buttonSubscription;
  StreamSubscription<DictationDevice>? _connectSubscription;
  StreamSubscription<DictationDevice>? _disconnectSubscription;

  Future<void> _initBloc() async {
    await _manager.init();

    _connectSubscription = _manager.deviceConnectedStream.listen((device) {
      _log('Device connected: ${device.getDeviceType().name}');
    });

    _disconnectSubscription = _manager.deviceDisconnectedStream.listen((
      device,
    ) {
      _log('Device disconnected: ${device.getDeviceType().name}');
      if (selectedDeviceSubject.value?.id == device.id) {
        selectedDeviceSubject.add(null);
        currentButtonStateSubject.add(0);
        _buttonSubscription?.cancel();
        _buttonSubscription = null;
      }
    });
  }

  void selectDevice(DictationDevice device) {
    _buttonSubscription?.cancel();
    selectedDeviceSubject.add(device);
    currentButtonStateSubject.add(device.currentButtonState);
    _log('Selected device: ${device.getDeviceType().name}');

    _buttonSubscription = device.buttonEventsSubject.listen((bitmask) {
      currentButtonStateSubject.add(bitmask);
      _logButtonEvent(bitmask);
    });
  }

  void _logButtonEvent(int bitmask) {
    final buttons = _parseButtons(bitmask);
    if (buttons.isEmpty) {
      _log('Button released (all buttons up)');
    } else {
      _log('Button pressed: ${buttons.join(', ')}');
    }
  }

  List<String> _parseButtons(int bitmask) {
    final List<String> buttons = [];
    if ((bitmask & ButtonEvent.rewind) != 0) buttons.add('Rewind');
    if ((bitmask & ButtonEvent.play) != 0) buttons.add('Play');
    if ((bitmask & ButtonEvent.forward) != 0) buttons.add('Forward');
    if ((bitmask & ButtonEvent.insOvr) != 0) buttons.add('Ins/Ovr');
    if ((bitmask & ButtonEvent.record) != 0) buttons.add('Record');
    if ((bitmask & ButtonEvent.command) != 0) buttons.add('Command');
    if ((bitmask & ButtonEvent.stop) != 0) buttons.add('Stop');
    if ((bitmask & ButtonEvent.instr) != 0) buttons.add('Instr');
    if ((bitmask & ButtonEvent.f1A) != 0) buttons.add('F1/A');
    if ((bitmask & ButtonEvent.f2B) != 0) buttons.add('F2/B');
    if ((bitmask & ButtonEvent.f3C) != 0) buttons.add('F3/C');
    if ((bitmask & ButtonEvent.f4D) != 0) buttons.add('F4/D');
    if ((bitmask & ButtonEvent.eolPrio) != 0) buttons.add('EOL/Prio');
    if ((bitmask & ButtonEvent.transcribe) != 0) buttons.add('Transcribe');
    if ((bitmask & ButtonEvent.tabBackward) != 0) buttons.add('Tab Back');
    if ((bitmask & ButtonEvent.tabForward) != 0) buttons.add('Tab Forward');
    if ((bitmask & ButtonEvent.customLeft) != 0) buttons.add('Custom Left');
    if ((bitmask & ButtonEvent.customRight) != 0) buttons.add('Custom Right');
    if ((bitmask & ButtonEvent.enterSelect) != 0) buttons.add('Enter/Select');
    if ((bitmask & ButtonEvent.scanEnd) != 0) buttons.add('Scan End');
    if ((bitmask & ButtonEvent.scanSuccess) != 0) buttons.add('Scan Success');
    return buttons;
  }

  Future<void> setSimpleLedState(SimpleLedState state) async {
    final device = selectedDeviceSubject.value;
    if (device is SpeechMikeHidDevice) {
      await device.setSimpleLedState(state);
      _log('LED state set to: ${state.name}');
    }
  }

  Future<void> setLed(LedIndex index, LedMode mode) async {
    final device = selectedDeviceSubject.value;
    if (device is SpeechMikeHidDevice) {
      await device.setLed(index, mode);
      _log('LED ${index.name} set to ${mode.name}');
    }
  }

  void _log(String message) {
    final now = DateTime.now();
    final timestamp =
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}.'
        '${now.millisecond.toString().padLeft(3, '0')}';
    final current = eventsSubject.value;
    eventsSubject.add(['[$timestamp] $message', ...current.take(199)]);
  }

  void clearLog() {
    eventsSubject.add([]);
  }

  @override
  void dispose() {
    _buttonSubscription?.cancel();
    _connectSubscription?.cancel();
    _disconnectSubscription?.cancel();
    _manager.shutdown();
  }

  static DictationTestingBloc of(BuildContext context) {
    return BlocProvider.of<DictationTestingBloc>(context);
  }
}
