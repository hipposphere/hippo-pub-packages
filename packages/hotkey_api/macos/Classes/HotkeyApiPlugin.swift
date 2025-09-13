import Cocoa
import FlutterMacOS

public class HotkeyApiPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  static let methodChannelName = "hotkey_api/methods"
  static let eventChannelName  = "hotkey_api/events"

  var eventSink: FlutterEventSink?
  var eventMonitor: Any?

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
    self.eventMonitor = NSEvent.addLocalMonitorForEvents(matching: mask) { (event) in
        self.handle(event: event)
    }
    // events when the app is out of focus
    self.eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: mask) { (event) in
        self.handle(event: event)
    }
    
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    if let monitor = self.eventMonitor {
        NSEvent.removeMonitor(monitor)
    }
    self.eventMonitor = nil
    self.eventSink = nil
    return nil
  }

  private func handle(event: NSEvent) {
    if let sink = self.eventSink {
        let eventType: String
        switch event.type {
        case .keyDown:
            eventType = "down"
        case .keyUp:
            eventType = "up"
        default:
            // For flagsChanged events, we can treat them as key down events
            // for the purpose of simplicity. The specific modifier key can
            // be extracted from the event if needed.
            eventType = "down"
        }

        sink([
            "key": Int(event.keyCode),
            "type": eventType,
        ])
    }
  }
}
