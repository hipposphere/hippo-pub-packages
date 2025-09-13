import Cocoa
import FlutterMacOS

public class HotkeyApiPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  static let methodChannelName = "hotkey_api/methods"
  static let eventChannelName  = "hotkey_api/events"

  var eventSink: FlutterEventSink?
  var localEventMonitor: Any?
  var globalEventMonitor: Any?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let methodChannel = FlutterMethodChannel(name: methodChannelName, binaryMessenger: registrar.messenger)
    let eventChannel = FlutterEventChannel(name: eventChannelName, binaryMessenger: registrar.messenger)
    let instance = HotkeyApiPlugin()
    registrar.addMethodCallDelegate(instance, channel: methodChannel)
    eventChannel.setStreamHandler(instance)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    self.eventSink = events
    
    let mask: NSEvent.EventTypeMask = [
        .keyDown,
        .keyUp,
        .flagsChanged,
    ]
    // events when the app is in focus
    self.localEventMonitor = NSEvent.addLocalMonitorForEvents(matching: mask) { (event) in
        self.handle(event: event)
        return event  // Return the event to pass it through to the system
    }
    // events when the app is out of focus
    self.globalEventMonitor = NSEvent.addGlobalMonitorForEvents(matching: mask) { (event) in
        self.handle(event: event)
        // Global monitor doesn't return anything
    }
    
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    if let monitor = self.localEventMonitor {
        NSEvent.removeMonitor(monitor)
    }
    if let monitor = self.globalEventMonitor {
        NSEvent.removeMonitor(monitor)
    }
    self.localEventMonitor = nil
    self.globalEventMonitor = nil
    self.eventSink = nil
    return nil
  }

  private func handle(event: NSEvent) {
    if let sink = self.eventSink {
        let eventType: String
        var keyCode: Int
        
        switch event.type {
        case .keyDown:
            eventType = "down"
            keyCode = Int(event.keyCode)
        case .keyUp:
            eventType = "up"
            keyCode = Int(event.keyCode)
        case .flagsChanged:
            // Handle modifier key changes
            let modifierFlags = event.modifierFlags
            
            // Predefined modifier mappings
            let modifierMappings: [(NSEvent.ModifierFlags, Int)] = [
                (.command, 55),   // Command key
                (.shift, 56),     // Shift key
                (.capsLock, 57),  // Caps Lock key
                (.option, 58),    // Option key
                (.control, 59),   // Control key
            ]
            
            // Find which modifier key changed
            var foundModifier = false
            for (flag, code) in modifierMappings {
                if modifierFlags.contains(flag) {
                    eventType = "down"
                    keyCode = code
                    foundModifier = true
                    break
                }
            }
            
            if !foundModifier {
                // No modifier flags set, so this is a release event
                eventType = "up"
                keyCode = Int(event.keyCode)
            }
        default:
            return // Skip other event types
        }

        sink([
            "key": keyCode,
            "type": eventType,
        ])
    }
  }
}
