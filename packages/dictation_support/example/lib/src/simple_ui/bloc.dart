part of 'page.dart';

class SimpleDictationBloc extends BlocBase {
  SimpleDictationBloc() {
    _initBloc();
  }

  final DictationDeviceManager _manager = DictationDeviceManager();

  DataSubject<List<DictationDevice>> get devicesSubject =>
      _manager.connectedDevicesSubject;
  final eventsSubject = DataSubject<List<String>>.seeded([]);

  StreamSubscription<(DictationDevice, ButtonChange)>?
  _globalButtonSubscription;
  bool _ledsOn = false;

  Future<void> _initBloc() async {
    await _manager.init();

    _globalButtonSubscription = _manager.onButtonChange.listen((event) {
      final device = event.$1;
      final change = event.$2;
      final action = change.isPressed ? 'pressed' : 'released';

      _log('[${device.getDeviceType().name}] ${change.buttonName} $action');
    });
  }

  void toggleAllLeds() async {
    _ledsOn = !_ledsOn;
    final devices = _manager.getDevices();

    for (final device in devices) {
      if (device is SpeechMikeHidDevice) {
        await device.setSimpleLedState(
          _ledsOn ? SimpleLedState.recordInsert : SimpleLedState.off,
        );
      }
    }
    _log(
      'Toggled LEDs on all SpeechMike devices to: ${_ledsOn ? 'ON' : 'OFF'}',
    );
  }

  void _log(String message) {
    final now = DateTime.now();
    final timestamp =
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}.'
        '${now.millisecond.toString().padLeft(3, '0')}';
    final current = eventsSubject.value;
    eventsSubject.add(['[$timestamp] $message', ...current.take(499)]);
  }

  void clearLog() {
    eventsSubject.add([]);
  }

  @override
  void dispose() {
    _globalButtonSubscription?.cancel();
    _manager.shutdown();
  }

  static SimpleDictationBloc of(BuildContext context) {
    return BlocProvider.of<SimpleDictationBloc>(context);
  }
}
