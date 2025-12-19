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
