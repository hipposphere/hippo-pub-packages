import Cocoa
import FlutterMacOS
import ApplicationServices
import IOKit.hid
import AVFoundation

public class AppPermissionsPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "app_permissions",
      binaryMessenger: registrar.messenger
    )
    let instance = AppPermissionsPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "isAccessibilityGranted":
      result(isAccessibilityGranted())
      
    case "requestAccessibility":
      let args = call.arguments as? [String: Any]
      let openPrefs = args?["openSystemPreferences"] as? Bool ?? true
      requestAccessibility(openSystemPreferences: openPrefs, result: result)
      
    case "getAccessibilityStatus":
      result(getAccessibilityStatus())
      
    case "isInputMonitoringGranted":
      result(isInputMonitoringGranted())
      
    case "requestInputMonitoring":
      let args = call.arguments as? [String: Any]
      let openPrefs = args?["openSystemPreferences"] as? Bool ?? true
      requestInputMonitoring(openSystemPreferences: openPrefs, result: result)
      
    case "getInputMonitoringStatus":
      result(getInputMonitoringStatus())
      
    case "isMicrophoneGranted":
      result(isMicrophoneGranted())
      
    case "requestMicrophone":
      requestMicrophone(result: result)
      
    case "getMicrophoneStatus":
      result(getMicrophoneStatus())
      
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  // MARK: - Accessibility Permission Methods
  
  /// Checks if the app has Accessibility permission
  private func isAccessibilityGranted() -> Bool {
    return AXIsProcessTrusted()
  }
  
  /// Gets the detailed status of Accessibility permission
  private func getAccessibilityStatus() -> String {
    if AXIsProcessTrusted() {
      return "granted"
    }
    
    // Check if we've prompted before by seeing if we're in the list
    // If the user denied, the app would be in System Settings but unchecked
    // Unfortunately there's no direct API to distinguish between "not determined"
    // and "denied", so we return "notDetermined" if not trusted
    return "notDetermined"
  }
  
  /// Requests Accessibility permission
  private func requestAccessibility(
    openSystemPreferences: Bool,
    result: @escaping FlutterResult
  ) {
    // Check if already granted
    if AXIsProcessTrusted() {
      result(true)
      return
    }
    
    if openSystemPreferences {
      // Open System Settings to the Accessibility pane
      openAccessibilityPreferences()
      result(false) // Return false as permission is not yet granted
    } else {
      // Show the system prompt (only works if not previously prompted)
      let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
      let trusted = AXIsProcessTrustedWithOptions(options as CFDictionary)
      result(trusted)
    }
  }
  
  /// Opens System Settings to the Privacy & Security > Accessibility pane
  private func openAccessibilityPreferences() {
    // Modern macOS (10.15+) - Open to Privacy & Security > Accessibility
    if #available(macOS 13.0, *) {
      // macOS 13+ (Ventura and later) - use new URL scheme
      if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
        NSWorkspace.shared.open(url)
      }
    } else if #available(macOS 10.15, *) {
      // macOS 10.15 - 12.x (Catalina through Monterey)
      if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
        NSWorkspace.shared.open(url)
      }
    } else {
      // Fallback for older macOS versions
      let prefpaneUrl = "/System/Library/PreferencePanes/Security.prefPane"
      NSWorkspace.shared.open(URL(fileURLWithPath: prefpaneUrl))
    }
  }
  
  // MARK: - Input Monitoring Permission Methods
  
  /// Checks if the app has Input Monitoring permission
  @available(macOS 10.15, *)
  private func isInputMonitoringGranted() -> Bool {
    // IOHIDRequestAccess returns true if access is granted
    // kIOHIDRequestTypeListenEvent is for monitoring keyboard/mouse events
    return IOHIDCheckAccess(kIOHIDRequestTypeListenEvent) == kIOHIDAccessTypeGranted
  }
  
  /// Gets the detailed status of Input Monitoring permission
  @available(macOS 10.15, *)
  private func getInputMonitoringStatus() -> String {
    let status = IOHIDCheckAccess(kIOHIDRequestTypeListenEvent)
    
    if status == kIOHIDAccessTypeGranted {
      return "granted"
    } else {
      // IOHIDCheckAccess doesn't distinguish between denied and not determined
      // so we return "notDetermined" if not granted
      return "notDetermined"
    }
  }
  
  /// Requests Input Monitoring permission
  @available(macOS 10.15, *)
  private func requestInputMonitoring(
    openSystemPreferences: Bool,
    result: @escaping FlutterResult
  ) {
    // Check if already granted
    if IOHIDCheckAccess(kIOHIDRequestTypeListenEvent) == kIOHIDAccessTypeGranted {
      result(true)
      return
    }
    
    if openSystemPreferences {
      // Open System Settings to the Input Monitoring pane
      openInputMonitoringPreferences()
      result(false) // Return false as permission is not yet granted
    } else {
      // Request access - this will show a system prompt if not previously prompted
      let granted = IOHIDRequestAccess(kIOHIDRequestTypeListenEvent)
      result(granted)
    }
  }
  
  /// Opens System Settings to the Privacy & Security > Input Monitoring pane
  @available(macOS 10.15, *)
  private func openInputMonitoringPreferences() {
    if #available(macOS 13.0, *) {
      // macOS 13+ (Ventura and later) - use new URL scheme
      if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent") {
        NSWorkspace.shared.open(url)
      }
    } else if #available(macOS 10.15, *) {
      // macOS 10.15 - 12.x (Catalina through Monterey)
      if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent") {
        NSWorkspace.shared.open(url)
      }
    }
  }
  
  // MARK: - Microphone Permission Methods
  
  /// Checks if the app has Microphone permission
  private func isMicrophoneGranted() -> Bool {
    if #available(macOS 10.14, *) {
      let status = AVCaptureDevice.authorizationStatus(for: .audio)
      return status == .authorized
    }
    return true // Older versions don't have this permission system
  }
  
  /// Gets the detailed status of Microphone permission
  private func getMicrophoneStatus() -> String {
    if #available(macOS 10.14, *) {
      let status = AVCaptureDevice.authorizationStatus(for: .audio)
      
      switch status {
      case .authorized:
        return "granted"
      case .denied:
        return "denied"
      case .notDetermined:
        return "notDetermined"
      case .restricted:
        return "denied" // Treat restricted as denied
      @unknown default:
        return "notDetermined"
      }
    }
    return "notRequired"
  }
  
  /// Requests Microphone permission
  private func requestMicrophone(result: @escaping FlutterResult) {
    if #available(macOS 10.14, *) {
      // Check current status first
      let currentStatus = AVCaptureDevice.authorizationStatus(for: .audio)
      
      if currentStatus == .authorized {
        result(true)
        return
      }
      
      // Request permission - this will show the system dialog
      AVCaptureDevice.requestAccess(for: .audio) { granted in
        // Ensure we're on the main thread when calling the Flutter result
        DispatchQueue.main.async {
          result(granted)
        }
      }
    } else {
      // Older macOS versions don't require microphone permission
      result(true)
    }
  }
}
