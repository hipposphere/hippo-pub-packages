import Cocoa
import FlutterMacOS
import ApplicationServices

public class DesktopPermissionsPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "desktop_permissions",
      binaryMessenger: registrar.messenger
    )
    let instance = DesktopPermissionsPlugin()
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
      // On macOS, Input Monitoring is essentially the same as Accessibility
      // for keyboard monitoring purposes
      result(isAccessibilityGranted())
      
    case "requestInputMonitoring":
      let args = call.arguments as? [String: Any]
      let openPrefs = args?["openSystemPreferences"] as? Bool ?? true
      requestAccessibility(openSystemPreferences: openPrefs, result: result)
      
    case "getInputMonitoringStatus":
      result(getAccessibilityStatus())
      
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
}
