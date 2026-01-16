import Flutter
import UIKit
import AVFoundation

public class AppPermissionsPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "app_permissions", binaryMessenger: registrar.messenger())
    let instance = AppPermissionsPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "isAccessibilityGranted":
      // iOS doesn't have accessibility permission like macOS
      result(true)
      
    case "requestAccessibility":
      // iOS doesn't have accessibility permission like macOS
      result(true)
      
    case "getAccessibilityStatus":
      result("notRequired")
      
    case "isInputMonitoringGranted":
      // iOS doesn't have input monitoring permission like macOS
      result(true)
      
    case "requestInputMonitoring":
      // iOS doesn't have input monitoring permission like macOS
      result(true)
      
    case "getInputMonitoringStatus":
      result("notRequired")
      
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
  
  // MARK: - Microphone Permission Methods
  
  /// Checks if the app has Microphone permission
  private func isMicrophoneGranted() -> Bool {
    let status = AVCaptureDevice.authorizationStatus(for: .audio)
    return status == .authorized
  }
  
  /// Gets the detailed status of Microphone permission
  private func getMicrophoneStatus() -> String {
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
  
  /// Requests Microphone permission
  private func requestMicrophone(result: @escaping FlutterResult) {
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
  }
}
