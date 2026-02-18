import Cocoa
import FlutterMacOS

public class DesktopAutopastePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "desktop_autopaste", binaryMessenger: registrar.messenger)
    let instance = DesktopAutopastePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "pasteIntoCursorViaClipboard":
        guard let args = call.arguments as? [String: Any],
            let text = args["text"] as? String
      else {
        result(FlutterError(
          code: "BAD_ARGS",
          message: "Missing 'text'",
          details: nil
        ))
        return
      }
      
      let ok: Bool = PasteIntoCursorViaClipboard.paste(text)

      result(ok)
    case "getFocusedTextFieldContext":
      result([
        "available": false,
        "reason": "unsupportedOnMacOS",
      ])
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
