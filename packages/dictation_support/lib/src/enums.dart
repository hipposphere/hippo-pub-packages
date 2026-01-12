/// Implementation types for dictation devices.
enum ImplementationType {
  speechMikeHid(0),
  speechMikeGamepad(1),
  footControl(2),
  powerMic3(3);

  final int value;
  const ImplementationType(this.value);
}

/// Supported device types.
enum DeviceType {
  unknown(0),
  footControlAcc2310_2320(6212),
  footControlAcc2330(2330),
  speechMikeLfh3200(3200),
  speechMikeLfh3210(3210),
  speechMikeLfh3220(3220),
  speechMikeLfh3300(3300),
  speechMikeLfh3310(3310),
  speechMikeLfh3500(3500),
  speechMikeLfh3510(3510),
  speechMikeLfh3520(3520),
  speechMikeLfh3600(3600),
  speechMikeLfh3610(3610),
  speechMikeSmp3700(3700),
  speechMikeSmp3710(3710),
  speechMikeSmp3720(3720),
  speechMikeSmp3800(3800),
  speechMikeSmp3810(3810),
  speechMikeSmp4000(4000),
  speechMikeSmp4010(4010),
  speechOnePsm6000(6001),
  powerMic3(4097),
  powerMic4(100),
  speechMikeAmbientPsm5000(5000);

  final int value;
  const DeviceType(this.value);

  static DeviceType fromValue(int value) {
    return DeviceType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => DeviceType.unknown,
    );
  }
}

/// Button event bitmask flags.
class ButtonEvent {
  static const int none = 0;
  static const int rewind = 1 << 0;
  static const int play = 1 << 1;
  static const int forward = 1 << 2;
  static const int insOvr = 1 << 4;
  static const int record = 1 << 5;
  static const int command = 1 << 6;
  static const int stop = 1 << 8;
  static const int instr = 1 << 9;
  static const int f1A = 1 << 10;
  static const int f2B = 1 << 11;
  static const int f3C = 1 << 12;
  static const int f4D = 1 << 13;
  static const int eolPrio = 1 << 14;
  static const int transcribe = 1 << 15;
  static const int tabBackward = 1 << 16;
  static const int tabForward = 1 << 17;
  static const int customLeft = 1 << 18;
  static const int customRight = 1 << 19;
  static const int enterSelect = 1 << 20;
  static const int scanEnd = 1 << 21;
  static const int scanSuccess = 1 << 22;
}

/// Event modes for SpeechMike devices.
enum EventMode {
  hid(0),
  keyboard(1),
  browser(2),
  windowsSr(3),
  dragonForMac(4),
  dragonForWindows(5);

  final int value;
  const EventMode(this.value);

  static EventMode fromValue(int value) {
    return EventMode.values.firstWhere(
      (e) => e.value == value,
      orElse: () => EventMode.hid,
    );
  }
}

/// Simple LED states for SpeechMike devices.
enum SimpleLedState {
  off(0),
  recordInsert(1),
  recordOverwrite(2),
  recordStandbyInsert(3),
  recordStandbyOverwrite(4);

  final int value;
  const SimpleLedState(this.value);
}

/// LED indices for SpeechMike devices.
enum LedIndex {
  recordLedGreen(0),
  recordLedRed(1),
  instructionLedGreen(2),
  instructionLedRed(3),
  insOwrButtonLedGreen(4),
  insOwrButtonLedRed(5),
  f1ButtonLed(6),
  f2ButtonLed(7),
  f3ButtonLed(8),
  f4ButtonLed(9);

  final int value;
  const LedIndex(this.value);
}

/// LED modes (behavior).
enum LedMode {
  off(0),
  blinkSlow(1),
  blinkFast(2),
  on(3);

  final int value;
  const LedMode(this.value);
}

/// Motion events for SpeechMike devices.
enum MotionEvent {
  pickedUp(0),
  layedDown(1);

  final int value;
  const MotionEvent(this.value);
}

/// Represents the current state of all buttons on a dictation device.
///
/// Wraps a bitmask and provides convenient getters for checking
/// individual button states.
class ButtonStates {
  final int bitmask;

  const ButtonStates(this.bitmask);

  bool get isRewindPressed => (bitmask & ButtonEvent.rewind) != 0;
  bool get isPlayPressed => (bitmask & ButtonEvent.play) != 0;
  bool get isForwardPressed => (bitmask & ButtonEvent.forward) != 0;
  bool get isInsOvrPressed => (bitmask & ButtonEvent.insOvr) != 0;
  bool get isRecordPressed => (bitmask & ButtonEvent.record) != 0;
  bool get isCommandPressed => (bitmask & ButtonEvent.command) != 0;
  bool get isStopPressed => (bitmask & ButtonEvent.stop) != 0;
  bool get isInstrPressed => (bitmask & ButtonEvent.instr) != 0;
  bool get isF1APressed => (bitmask & ButtonEvent.f1A) != 0;
  bool get isF2BPressed => (bitmask & ButtonEvent.f2B) != 0;
  bool get isF3CPressed => (bitmask & ButtonEvent.f3C) != 0;
  bool get isF4DPressed => (bitmask & ButtonEvent.f4D) != 0;
  bool get isEolPrioPressed => (bitmask & ButtonEvent.eolPrio) != 0;
  bool get isTranscribePressed => (bitmask & ButtonEvent.transcribe) != 0;
  bool get isTabBackwardPressed => (bitmask & ButtonEvent.tabBackward) != 0;
  bool get isTabForwardPressed => (bitmask & ButtonEvent.tabForward) != 0;
  bool get isCustomLeftPressed => (bitmask & ButtonEvent.customLeft) != 0;
  bool get isCustomRightPressed => (bitmask & ButtonEvent.customRight) != 0;
  bool get isEnterSelectPressed => (bitmask & ButtonEvent.enterSelect) != 0;
  bool get isScanEndPressed => (bitmask & ButtonEvent.scanEnd) != 0;
  bool get isScanSuccessPressed => (bitmask & ButtonEvent.scanSuccess) != 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ButtonStates &&
          runtimeType == other.runtimeType &&
          bitmask == other.bitmask;

  @override
  int get hashCode => bitmask.hashCode;

  @override
  String toString() => 'ButtonStates(bitmask: 0x${bitmask.toRadixString(16)})';
}

/// Represents a single button state change (pressed or released).
class ButtonChange {
  /// The specific button that changed (e.g., ButtonEvent.record)
  final int buttonMask;

  /// True if the button was pressed, false if released
  final bool isPressed;

  /// The overall button state after this change
  final ButtonStates currentState;

  const ButtonChange({
    required this.buttonMask,
    required this.isPressed,
    required this.currentState,
  });

  /// Returns a human-readable name for the button that changed
  String get buttonName {
    switch (buttonMask) {
      case ButtonEvent.rewind:
        return 'rewind';
      case ButtonEvent.play:
        return 'play';
      case ButtonEvent.forward:
        return 'forward';
      case ButtonEvent.insOvr:
        return 'insOvr';
      case ButtonEvent.record:
        return 'record';
      case ButtonEvent.command:
        return 'command';
      case ButtonEvent.stop:
        return 'stop';
      case ButtonEvent.instr:
        return 'instr';
      case ButtonEvent.f1A:
        return 'f1A';
      case ButtonEvent.f2B:
        return 'f2B';
      case ButtonEvent.f3C:
        return 'f3C';
      case ButtonEvent.f4D:
        return 'f4D';
      case ButtonEvent.eolPrio:
        return 'eolPrio';
      case ButtonEvent.transcribe:
        return 'transcribe';
      case ButtonEvent.tabBackward:
        return 'tabBackward';
      case ButtonEvent.tabForward:
        return 'tabForward';
      case ButtonEvent.customLeft:
        return 'customLeft';
      case ButtonEvent.customRight:
        return 'customRight';
      case ButtonEvent.enterSelect:
        return 'enterSelect';
      case ButtonEvent.scanEnd:
        return 'scanEnd';
      case ButtonEvent.scanSuccess:
        return 'scanSuccess';
      default:
        return 'unknown';
    }
  }

  @override
  String toString() =>
      'ButtonChange($buttonName ${isPressed ? 'pressed' : 'released'})';
}
