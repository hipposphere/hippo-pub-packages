import Cocoa
import FlutterMacOS

public class HotkeyApiPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  // MARK: - Channels
  static let methodChannelName = "hotkey_api/methods"
  static let eventChannelName  = "hotkey_api/events"

  // MARK: - Streams / Monitors
  private var eventSink: FlutterEventSink?
  private var localEventMonitor: Any?
  private var globalEventMonitor: Any?

  // MARK: - Modifier state (side-aware)
  /// Tracks which modifier *key codes* are currently pressed (so we can disambiguate sides).
  private var pressedModifierKeyCodes = Set<UInt16>()

  /// Map of hardware keyCode -> (flag, code to report).
  /// The `reportCode` preserves side-specific key codes so consumers see left vs right distinctly.
  private let modifierKeyMap: [UInt16: (flag: NSEvent.ModifierFlags, reportCode: Int)] = [
    55: (.command, 55), // left ⌘
    54: (.command, 54), // right ⌘
    56: (.shift,   56), // left ⇧
    60: (.shift,   60), // right ⇧
    57: (.capsLock,57), // caps lock (toggle)
    58: (.option,  58), // left ⌥
    61: (.option,  61), // right ⌥
    59: (.control, 59), // left ⌃
    62: (.control, 62), // right ⌃
    63: (.function,63), // fn
  ]

  // MARK: - Registration
  public static func register(with registrar: FlutterPluginRegistrar) {
    let methodChannel = FlutterMethodChannel(
      name: methodChannelName,
      binaryMessenger: registrar.messenger
    )
    let eventChannel = FlutterEventChannel(
      name: eventChannelName,
      binaryMessenger: registrar.messenger
    )

    let instance = HotkeyApiPlugin()
    registrar.addMethodCallDelegate(instance, channel: methodChannel)
    eventChannel.setStreamHandler(instance)
  }

  deinit {
    // Best-effort cleanup if Flutter stream cancellation didn't fire.
    if let monitor = self.localEventMonitor { NSEvent.removeMonitor(monitor) }
    if let monitor = self.globalEventMonitor { NSEvent.removeMonitor(monitor) }
  }

  // MARK: - Methods
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // MARK: - Stream handler
  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    self.eventSink = events

    let mask: NSEvent.EventTypeMask = [.keyDown, .keyUp, .flagsChanged]

    // Local: when app is focused (can return/modify events)
    self.localEventMonitor = NSEvent.addLocalMonitorForEvents(matching: mask) { [weak self] event in
      self?.handle(event: event)
      return event // pass through
    }

    // Global: when app is not focused (receive-only)
    self.globalEventMonitor = NSEvent.addGlobalMonitorForEvents(matching: mask) { [weak self] event in
      self?.handle(event: event)
    }

    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    if let monitor = self.localEventMonitor { NSEvent.removeMonitor(monitor) }
    if let monitor = self.globalEventMonitor { NSEvent.removeMonitor(monitor) }
    self.localEventMonitor = nil
    self.globalEventMonitor = nil
    self.eventSink = nil
    self.pressedModifierKeyCodes.removeAll()
    return nil
  }

  // MARK: - Unified emit helper
  /// Emits a Flutter event if a sink is available.
  /// Keeps payload construction in one place.
  @inline(__always)
  private func emit(type: String, key: Int) {
    guard let sink = self.eventSink else { return }
    sink(["key": key, "type": type])
  }

  // MARK: - Event handling
  private func handle(event: NSEvent) {
    switch event.type {
    case .keyDown:
      emit(type: event.isARepeat ? "repeat" : "down", key: Int(event.keyCode))

    case .keyUp:
      emit(type: "up", key: Int(event.keyCode))

    case .flagsChanged:
      handleFlagsChanged(event)

    default:
      break
    }
  }

  /// Handle side-aware modifier changes using the actual hardware keyCode.
  private func handleFlagsChanged(_ event: NSEvent) {
    let code = event.keyCode
    guard let entry = modifierKeyMap[code] else { return }

    if entry.flag == .capsLock {
      // Caps Lock is a toggle: use current flags to decide on/off.
      let isOn = event.modifierFlags.contains(.capsLock)
      emit(type: isOn ? "down" : "up", key: entry.reportCode)
      return
    }

    // For side-specific modifiers (⌘ ⌥ ⇧ ⌃, and fn), toggle based on keyCode membership.
    if pressedModifierKeyCodes.contains(code) {
      // Transitioning UP for this specific side.
      pressedModifierKeyCodes.remove(code)
      emit(type: "up", key: entry.reportCode)
    } else {
      // Transitioning DOWN for this specific side.
      pressedModifierKeyCodes.insert(code)
      emit(type: "down", key: entry.reportCode)
    }
  }
}
