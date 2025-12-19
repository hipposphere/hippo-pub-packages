import Cocoa
import FlutterMacOS
import IOKit.hid

public class HidApiPlugin: NSObject, FlutterPlugin {
    private var manager: IOHIDManager?
    private var openDevices: [String: IOHIDDevice] = [:]
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "hid_api", binaryMessenger: registrar.messenger)
        let instance = HidApiPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize":
            initialize(result: result)
        case "shutdown":
            shutdown(result: result)
        case "enumerate":
            enumerate(call: call, result: result)
        case "open":
            open(call: call, result: result)
        case "close":
            close(call: call, result: result)
        case "read":
            read(call: call, result: result)
        case "write":
            write(call: call, result: result)
        case "setBlocking":
            result(nil)
        case "sendFeatureReport":
            sendFeatureReport(call: call, result: result)
        case "getFeatureReport":
            getFeatureReport(call: call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func initialize(result: @escaping FlutterResult) {
        manager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
        IOHIDManagerSetDeviceMatching(manager!, nil) // Match all
        IOHIDManagerScheduleWithRunLoop(manager!, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)
        IOHIDManagerOpen(manager!, IOOptionBits(kIOHIDOptionsTypeNone))
        result(nil)
    }

    private func shutdown(result: @escaping FlutterResult) {
        if let manager = manager {
            IOHIDManagerClose(manager, IOOptionBits(kIOHIDOptionsTypeNone))
            IOHIDManagerUnscheduleFromRunLoop(manager, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)
            self.manager = nil
        }
        openDevices.removeAll()
        result(nil)
    }

    private func enumerate(call: FlutterMethodCall, result: @escaping FlutterResult) {
        if manager == nil {
             self.manager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
             IOHIDManagerSetDeviceMatching(self.manager!, nil)
             IOHIDManagerOpen(self.manager!, IOOptionBits(kIOHIDOptionsTypeNone))
        }
        
        let args = call.arguments as? [String: Any]
        let vendorId = args?["vendorId"] as? Int
        let productId = args?["productId"] as? Int
        
        if vendorId != nil || productId != nil {
            var match = [String: Any]()
            if let v = vendorId { match[kIOHIDVendorIDKey] = v }
            if let p = productId { match[kIOHIDProductIDKey] = p }
            IOHIDManagerSetDeviceMatching(manager!, match as CFDictionary)
        } else {
            IOHIDManagerSetDeviceMatching(manager!, nil)
        }

        let deviceSet = IOHIDManagerCopyDevices(manager!)
        guard let devices = deviceSet as? Set<IOHIDDevice> else {
            result([])
            return
        }

        var deviceList = [[String: Any]]()
        
        for device in devices {
            let path = getDevicePath(device)
            let vid = IOHIDDeviceGetProperty(device, kIOHIDVendorIDKey as CFString) as? Int ?? 0
            let pid = IOHIDDeviceGetProperty(device, kIOHIDProductIDKey as CFString) as? Int ?? 0
            let release = IOHIDDeviceGetProperty(device, kIOHIDVersionNumberKey as CFString) as? Int ?? 0
            let usagePage = IOHIDDeviceGetProperty(device, kIOHIDPrimaryUsagePageKey as CFString) as? Int ?? 0
            let usage = IOHIDDeviceGetProperty(device, kIOHIDPrimaryUsageKey as CFString) as? Int ?? 0
            let manufacturer = IOHIDDeviceGetProperty(device, kIOHIDManufacturerKey as CFString) as? String
            let product = IOHIDDeviceGetProperty(device, kIOHIDProductKey as CFString) as? String
            let serial = IOHIDDeviceGetProperty(device, kIOHIDSerialNumberKey as CFString) as? String
            let interfaceNumber = 0 

            deviceList.append([
                "path": path,
                "vendorId": vid,
                "productId": pid,
                "releaseNumber": release,
                "usagePage": usagePage,
                "usage": usage,
                "manufacturer": manufacturer ?? "",
                "product": product ?? "",
                "serialNumber": serial ?? "",
                "interfaceNumber": interfaceNumber
            ])
        }
        
        result(deviceList)
    }

    private func open(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let path = args["path"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Path required", details: nil))
            return
        }
        
        if manager == nil {
             self.manager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
             IOHIDManagerSetDeviceMatching(self.manager!, nil)
             IOHIDManagerOpen(self.manager!, IOOptionBits(kIOHIDOptionsTypeNone))
        }
        
        IOHIDManagerSetDeviceMatching(manager!, nil)
        let deviceSet = IOHIDManagerCopyDevices(manager!)
        guard let devices = deviceSet as? Set<IOHIDDevice> else {
            result(FlutterError(code: "DEVICE_NOT_FOUND", message: "Device not found", details: nil))
            return
        }
        
        if let device = devices.first(where: { getDevicePath($0) == path }) {
            let ret = IOHIDDeviceOpen(device, IOOptionBits(kIOHIDOptionsTypeNone))
            if ret == kIOReturnSuccess {
                openDevices[path] = device
                
                let vid = IOHIDDeviceGetProperty(device, kIOHIDVendorIDKey as CFString) as? Int ?? 0
                let pid = IOHIDDeviceGetProperty(device, kIOHIDProductIDKey as CFString) as? Int ?? 0
                let release = IOHIDDeviceGetProperty(device, kIOHIDVersionNumberKey as CFString) as? Int ?? 0
                let usagePage = IOHIDDeviceGetProperty(device, kIOHIDPrimaryUsagePageKey as CFString) as? Int ?? 0
                let usage = IOHIDDeviceGetProperty(device, kIOHIDPrimaryUsageKey as CFString) as? Int ?? 0
                let manufacturer = IOHIDDeviceGetProperty(device, kIOHIDManufacturerKey as CFString) as? String
                let product = IOHIDDeviceGetProperty(device, kIOHIDProductKey as CFString) as? String
                let serial = IOHIDDeviceGetProperty(device, kIOHIDSerialNumberKey as CFString) as? String
                
                result([
                    "path": path,
                    "vendorId": vid,
                    "productId": pid,
                    "releaseNumber": release,
                    "usagePage": usagePage,
                    "usage": usage,
                    "manufacturer": manufacturer ?? "",
                    "product": product ?? "",
                    "serialNumber": serial ?? "",
                    "interfaceNumber": 0
                ])
            } else {
                result(FlutterError(code: "OPEN_FAILED", message: "Failed to open device: \(ret)", details: nil))
            }
        } else {
            result(FlutterError(code: "DEVICE_NOT_FOUND", message: "Device not found", details: nil))
        }
    }

    private func close(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let path = args["path"] as? String,
              let device = openDevices[path] else {
            result(nil)
            return
        }
        
        IOHIDDeviceClose(device, IOOptionBits(kIOHIDOptionsTypeNone))
        openDevices.removeValue(forKey: path)
        result(nil)
    }

    private func read(call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Not implemented in this basic version
        result(FlutterError(code: "UNIMPLEMENTED", message: "Async read not implemented", details: nil))
    }

    private func write(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let path = args["path"] as? String,
              let data = args["data"] as? FlutterStandardTypedData,
              let device = openDevices[path] else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid arguments", details: nil))
            return
        }
        
        let reportId = (args["reportId"] as? Int) ?? 0
        let bytes = [UInt8](data.data)
        
        let ret = IOHIDDeviceSetReport(
            device,
            kIOHIDReportTypeOutput,
            CFIndex(reportId),
            bytes,
            CFIndex(bytes.count)
        )
        
        if ret == kIOReturnSuccess {
            result(bytes.count)
        } else {
            result(FlutterError(code: "WRITE_FAILED", message: "Write failed: \(ret)", details: nil))
        }
    }
    
    private func sendFeatureReport(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let path = args["path"] as? String,
              let data = args["data"] as? FlutterStandardTypedData,
              let device = openDevices[path] else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid arguments", details: nil))
            return
        }
        
        let reportId = (args["reportId"] as? Int) ?? 0
        let bytes = [UInt8](data.data)
        
        let ret = IOHIDDeviceSetReport(
            device,
            kIOHIDReportTypeFeature,
            CFIndex(reportId),
            bytes,
            CFIndex(bytes.count)
        )
        
        if ret == kIOReturnSuccess {
            result(bytes.count)
        } else {
            result(FlutterError(code: "WRITE_FAILED", message: "Send Feature Report failed: \(ret)", details: nil))
        }
    }
    
    private func getFeatureReport(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let path = args["path"] as? String,
              let length = args["length"] as? Int,
              let device = openDevices[path] else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid arguments", details: nil))
            return
        }
        
        let reportId = (args["reportId"] as? Int) ?? 0
        var reportLength = CFIndex(length)
        var buffer = [UInt8](repeating: 0, count: length)
        
        let ret = IOHIDDeviceGetReport(
            device,
            kIOHIDReportTypeFeature,
            CFIndex(reportId),
            &buffer,
            &reportLength
        )
        
        if ret == kIOReturnSuccess {
            result([
                "data": FlutterStandardTypedData(bytes: Data(buffer.prefix(Int(reportLength))))
            ])
        } else {
            result(FlutterError(code: "READ_FAILED", message: "Get Feature Report failed: \(ret)", details: nil))
        }
    }

    private func getDevicePath(_ device: IOHIDDevice) -> String {
        let service = IOHIDDeviceGetService(device)
        var entryID: UInt64 = 0
        IORegistryEntryGetRegistryEntryID(service, &entryID)
        return "\(entryID)"
    }
}
