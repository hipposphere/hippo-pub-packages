import Cocoa
import FlutterMacOS
import IOKit.hid

// USB interface number key for proper USB device interface detection
private let kUSBInterfaceNumber = "bInterfaceNumber" as CFString

public class HidApiPlugin: NSObject, FlutterPlugin {
    var manager: IOHIDManager?
    private var openDevices: [String: IOHIDDevice] = [:]
    private var eventHandlers: [String: ReportStreamHandler] = [:]
    private var disconnectionHandlers: [String: DisconnectionStreamHandler] = [:]
    private var deviceUpdateHandler: DeviceUpdateStreamHandler?
    private static var messenger: FlutterBinaryMessenger?
    
    /// Set to true to enable verbose HID logging. Change this to false to disable logging.
    /// You can toggle this at runtime for debugging.
    static var verboseLogging = true

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "hid_api", binaryMessenger: registrar.messenger)
        let instance = HidApiPlugin()
        self.messenger = registrar.messenger
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
        case "sendReport":
            handleSendReport(call: call, result: result)
        case "setBlocking":
            result(nil)
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
        
        if let messenger = HidApiPlugin.messenger {
            let channel = FlutterEventChannel(name: "hid_api/device_updates", binaryMessenger: messenger)
            deviceUpdateHandler = DeviceUpdateStreamHandler(plugin: self)
            channel.setStreamHandler(deviceUpdateHandler)
        }
        
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
        
        // Note: Do NOT call IOHIDManagerSetDeviceMatching here - it would trigger
        // the device matching callback. Filter manually via VID/PID below.

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
            
            if let v = vendorId, vid != v { continue }
            if let p = productId, pid != p { continue }
            
            let release = IOHIDDeviceGetProperty(device, kIOHIDVersionNumberKey as CFString) as? Int ?? 0
            let usagePage = IOHIDDeviceGetProperty(device, kIOHIDPrimaryUsagePageKey as CFString) as? Int ?? 0
            let usage = IOHIDDeviceGetProperty(device, kIOHIDPrimaryUsageKey as CFString) as? Int ?? 0
            let manufacturer = IOHIDDeviceGetProperty(device, kIOHIDManufacturerKey as CFString) as? String
            let product = IOHIDDeviceGetProperty(device, kIOHIDProductKey as CFString) as? String
            let serial = IOHIDDeviceGetProperty(device, kIOHIDSerialNumberKey as CFString) as? String
            let interfaceNumber = getInterfaceNumber(device)

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
        
        // Note: Do NOT call IOHIDManagerSetDeviceMatching here - it triggers callbacks
        let deviceSet = IOHIDManagerCopyDevices(manager!)
        guard let devices = deviceSet as? Set<IOHIDDevice> else {
            result(FlutterError(code: "DEVICE_NOT_FOUND", message: "Device not found", details: nil))
            return
        }
        
        if let device = devices.first(where: { getDevicePath($0) == path }) {
            let ret = IOHIDDeviceOpen(device, IOOptionBits(kIOHIDOptionsTypeNone))
            if ret == kIOReturnSuccess {
                // Schedule the device on the run loop so callbacks can fire
                IOHIDDeviceScheduleWithRunLoop(device, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)
                openDevices[path] = device
                
                // Get device properties once
                let vid = IOHIDDeviceGetProperty(device, kIOHIDVendorIDKey as CFString) as? Int ?? 0
                let pid = IOHIDDeviceGetProperty(device, kIOHIDProductIDKey as CFString) as? Int ?? 0
                let release = IOHIDDeviceGetProperty(device, kIOHIDVersionNumberKey as CFString) as? Int ?? 0
                let usagePage = IOHIDDeviceGetProperty(device, kIOHIDPrimaryUsagePageKey as CFString) as? Int ?? 0
                let usage = IOHIDDeviceGetProperty(device, kIOHIDPrimaryUsageKey as CFString) as? Int ?? 0
                let manufacturer = IOHIDDeviceGetProperty(device, kIOHIDManufacturerKey as CFString) as? String
                let product = IOHIDDeviceGetProperty(device, kIOHIDProductKey as CFString) as? String
                let serial = IOHIDDeviceGetProperty(device, kIOHIDSerialNumberKey as CFString) as? String
                let interfaceNumber = getInterfaceNumber(device)
                
                NSLog("[HID] ✅ Opened device %04X:%04X - Interface: %d, UsagePage: %d, Usage: %d", 
                      vid, pid, interfaceNumber, usagePage, usage)
                
                // Set up event channel
                if let messenger = HidApiPlugin.messenger {
                    let eventChannel = FlutterEventChannel(name: "hid_api/reports/\(path)", binaryMessenger: messenger)
                    let handler = ReportStreamHandler(device: device)
                    eventChannel.setStreamHandler(handler)
                    eventHandlers[path] = handler

                    let discChannel = FlutterEventChannel(name: "hid_api/disconnection/\(path)", binaryMessenger: messenger)
                    let discHandler = DisconnectionStreamHandler(device: device)
                    discChannel.setStreamHandler(discHandler)
                    disconnectionHandlers[path] = discHandler
                }
                
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
                    "interfaceNumber": interfaceNumber
                ])
            } else {
                var message = "Failed to open device (Error: \(ret))"
                var errorCode = "OPEN_FAILED"
                
                if ret == -536870174 { // kIOReturnNotPrivileged
                    errorCode = "PERMISSION_DENIED"
                    message = "Access denied (kIOReturnNotPrivileged). macOS prevents opening system devices like keyboards or mice for security."
                } else if ret == -536870203 { // kIOReturnExclusiveAccess
                    errorCode = "EXCLUSIVE_ACCESS"
                    message = "Exclusive access (kIOReturnExclusiveAccess). The device is already open by another process with exclusive access."
                }
                
                result(FlutterError(code: errorCode, message: message, details: "IOReturn: \(ret)"))
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
        
        // Unschedule from run loop before closing
        IOHIDDeviceUnscheduleFromRunLoop(device, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)
        IOHIDDeviceClose(device, IOOptionBits(kIOHIDOptionsTypeNone))
        openDevices.removeValue(forKey: path)
        eventHandlers.removeValue(forKey: path)
        disconnectionHandlers.removeValue(forKey: path)
        result(nil)
    }

    private func read(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let path = args["path"] as? String,
              let device = openDevices[path] else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid arguments", details: nil))
            return
        }

        let timeout = (args["timeout"] as? Int) ?? 1000
        var buffer = [UInt8](repeating: 0, count: 64) // Default size
        var length = CFIndex(64)
        
        // This is a synchronous read for the 'read' method call
        let ret = IOHIDDeviceGetReport(device, kIOHIDReportTypeInput, 0, &buffer, &length)
        if ret == kIOReturnSuccess {
            result([
                "reportId": buffer[0],
                "data": FlutterStandardTypedData(bytes: Data(buffer.prefix(length)))
            ])
        } else {
            result(FlutterError(code: "READ_FAILED", message: "Read failed: \(ret)", details: nil))
        }
    }


    // Unified method to send HID reports (Output or Feature)
    private func sendReport(
        call: FlutterMethodCall,
        result: @escaping FlutterResult,
        reportType: IOHIDReportType,
        reportTypeName: String
    ) {
        guard let args = call.arguments as? [String: Any],
              let path = args["path"] as? String,
              let data = args["data"] as? FlutterStandardTypedData,
              let device = openDevices[path] else {
            if HidApiPlugin.verboseLogging {
                NSLog("[HID] Send \(reportTypeName) FAILED: Invalid arguments")
            }
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid arguments", details: nil))
            return
        }
        
        let reportId = (args["reportId"] as? Int) ?? 0
        var bytes = [UInt8](data.data)
        
        // Log which device interface is receiving this
        let vid = IOHIDDeviceGetProperty(device, kIOHIDVendorIDKey as CFString) as? Int ?? 0
        let pid = IOHIDDeviceGetProperty(device, kIOHIDProductIDKey as CFString) as? Int ?? 0
        let usagePage = IOHIDDeviceGetProperty(device, kIOHIDPrimaryUsagePageKey as CFString) as? Int ?? 0
        let usage = IOHIDDeviceGetProperty(device, kIOHIDPrimaryUsageKey as CFString) as? Int ?? 0
        let interfaceNumber = getInterfaceNumber(device)
        
        if HidApiPlugin.verboseLogging {
            NSLog("[HID] Send \(reportTypeName) called - Report ID: %d, Original data length: %d", reportId, bytes.count)
            NSLog("[HID] Target device: %04X:%04X, Interface: %d, UsagePage: %d, Usage: %d",
                  vid, pid, interfaceNumber, usagePage, usage)
            NSLog("[HID] Original data from Dart: %@", bytes.map { String(format: "%02X", $0) }.joined(separator: " "))
        } else {
            NSLog("[HID] \(reportTypeName) to %04X:%04X Interface %d (UsagePage:%d, Usage:%d)",
                  vid, pid, interfaceNumber, usagePage, usage)
        }
        
        // On macOS, devices expect the Report ID as the first byte of the data buffer.
        // Automatically prepend it so users don't have to include it manually.
        var dataWithReportId = [UInt8]()
        if reportId != 0 {
            dataWithReportId.append(UInt8(reportId))
        }
        dataWithReportId.append(contentsOf: bytes)
        
        // Construct the complete buffer that the device will receive
        let completeBuffer = dataWithReportId
        
        if HidApiPlugin.verboseLogging {
            NSLog("[HID] ═══════════════════════════════════════════════════════")
            NSLog("[HID] Calling IOHIDDeviceSetReport with:")
            NSLog("[HID]   - Type: \(reportTypeName)")
            NSLog("[HID]   - Report ID (parameter): %d (0x%02X)", reportId, reportId)
            NSLog("[HID]   - Data buffer length: %d", dataWithReportId.count)
            NSLog("[HID]   - Data buffer: %@", dataWithReportId.map { String(format: "%02X", $0) }.joined(separator: " "))
            NSLog("[HID] ")
            NSLog("[HID] COMPLETE BUFFER SENT TO DEVICE:")
            NSLog("[HID]   Length: %d bytes", completeBuffer.count)
            NSLog("[HID]   Data: %@", completeBuffer.map { String(format: "%02X", $0) }.joined(separator: " "))
            NSLog("[HID] ═══════════════════════════════════════════════════════")
        } else {
            // Minimal logging when verbose is off
            NSLog("[HID] Sending \(reportTypeName) ID 0x%02X (%d bytes): %@",
                  reportId, completeBuffer.count,
                  completeBuffer.map { String(format: "%02X", $0) }.joined(separator: " "))
        }
        
        let ret = IOHIDDeviceSetReport(
            device,
            reportType,
            CFIndex(reportId),
            dataWithReportId,
            CFIndex(dataWithReportId.count)
        )
        
        if ret == kIOReturnSuccess {
            if HidApiPlugin.verboseLogging {
                let ioReturnString = getIOReturnString(ret)
                NSLog("[HID] IOHIDDeviceSetReport returned: %@ (0x%X)", ioReturnString, ret)
                NSLog("[HID] Send \(reportTypeName) SUCCESS - Device received %d bytes total", completeBuffer.count)
            }
            result(bytes.count)
        } else {
            let errorMessage = "Send \(reportTypeName) failed: \(getIOReturnString(ret)) (0x\(String(format: "%X", ret)))"
            NSLog("[HID] Send \(reportTypeName) FAILED: %@", errorMessage)
            result(FlutterError(code: "WRITE_FAILED", message: errorMessage, details: "IOReturn: \(ret)"))
        }
    }

    private func handleSendReport(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let typeStr = args["type"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing type argument", details: nil))
            return
        }
        
        let reportType: IOHIDReportType
        let reportTypeName: String
        
        if typeStr == "output" {
            reportType = kIOHIDReportTypeOutput
            reportTypeName = "Output Report"
        } else if typeStr == "feature" {
            reportType = kIOHIDReportTypeFeature
            reportTypeName = "Feature Report"
        } else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid report type: \(typeStr)", details: nil))
            return
        }
        
        sendReport(call: call, result: result, reportType: reportType, reportTypeName: reportTypeName)
    }
    
    private func getIOReturnString(_ ret: IOReturn) -> String {
        switch ret {
        case kIOReturnSuccess:
            return "kIOReturnSuccess"
        case kIOReturnError:
            return "kIOReturnError (general error)"
        case kIOReturnNoMemory:
            return "kIOReturnNoMemory"
        case kIOReturnNoResources:
            return "kIOReturnNoResources"
        case kIOReturnIPCError:
            return "kIOReturnIPCError"
        case kIOReturnNoDevice:
            return "kIOReturnNoDevice"
        case kIOReturnNotPrivileged:
            return "kIOReturnNotPrivileged"
        case kIOReturnBadArgument:
            return "kIOReturnBadArgument"
        case kIOReturnLockedRead:
            return "kIOReturnLockedRead"
        case kIOReturnLockedWrite:
            return "kIOReturnLockedWrite"
        case kIOReturnExclusiveAccess:
            return "kIOReturnExclusiveAccess"
        case kIOReturnBadMessageID:
            return "kIOReturnBadMessageID"
        case kIOReturnUnsupported:
            return "kIOReturnUnsupported (device doesn't support this operation)"
        case kIOReturnVMError:
            return "kIOReturnVMError"
        case kIOReturnInternalError:
            return "kIOReturnInternalError"
        case kIOReturnIOError:
            return "kIOReturnIOError"
        case kIOReturnCannotLock:
            return "kIOReturnCannotLock"
        case kIOReturnNotOpen:
            return "kIOReturnNotOpen"
        case kIOReturnNotReadable:
            return "kIOReturnNotReadable"
        case kIOReturnNotWritable:
            return "kIOReturnNotWritable"
        case kIOReturnNotAligned:
            return "kIOReturnNotAligned"
        case kIOReturnBadMedia:
            return "kIOReturnBadMedia"
        case kIOReturnStillOpen:
            return "kIOReturnStillOpen"
        case kIOReturnRLDError:
            return "kIOReturnRLDError"
        case kIOReturnDMAError:
            return "kIOReturnDMAError"
        case kIOReturnBusy:
            return "kIOReturnBusy"
        case kIOReturnTimeout:
            return "kIOReturnTimeout"
        case kIOReturnOffline:
            return "kIOReturnOffline"
        case kIOReturnNotReady:
            return "kIOReturnNotReady"
        case kIOReturnNotAttached:
            return "kIOReturnNotAttached"
        case kIOReturnNoChannels:
            return "kIOReturnNoChannels"
        case kIOReturnNoSpace:
            return "kIOReturnNoSpace"
        case kIOReturnPortExists:
            return "kIOReturnPortExists"
        case kIOReturnCannotWire:
            return "kIOReturnCannotWire"
        case kIOReturnNoInterrupt:
            return "kIOReturnNoInterrupt"
        case kIOReturnNoFrames:
            return "kIOReturnNoFrames"
        case kIOReturnMessageTooLarge:
            return "kIOReturnMessageTooLarge"
        case kIOReturnNotPermitted:
            return "kIOReturnNotPermitted"
        case kIOReturnNoPower:
            return "kIOReturnNoPower"
        case kIOReturnNoMedia:
            return "kIOReturnNoMedia"
        case kIOReturnUnformattedMedia:
            return "kIOReturnUnformattedMedia"
        case kIOReturnUnsupportedMode:
            return "kIOReturnUnsupportedMode"
        case kIOReturnUnderrun:
            return "kIOReturnUnderrun"
        case kIOReturnOverrun:
            return "kIOReturnOverrun"
        case kIOReturnDeviceError:
            return "kIOReturnDeviceError"
        case kIOReturnNoCompletion:
            return "kIOReturnNoCompletion"
        case kIOReturnAborted:
            return "kIOReturnAborted"
        case kIOReturnNoBandwidth:
            return "kIOReturnNoBandwidth"
        case kIOReturnNotResponding:
            return "kIOReturnNotResponding"
        case kIOReturnIsoTooOld:
            return "kIOReturnIsoTooOld"
        case kIOReturnIsoTooNew:
            return "kIOReturnIsoTooNew"
        case kIOReturnInvalid:
            return "kIOReturnInvalid"
        default:
            return "Unknown IOReturn"
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
            var resultData = Data(buffer.prefix(Int(reportLength)))
            
            // Ensure consistency: if the Report ID is not already at index 0, prepend it.
            // This matches the behavior of Input Reports on both macOS and Windows.
            if reportId != 0 && (resultData.isEmpty || resultData[0] != UInt8(reportId)) {
                resultData.insert(UInt8(reportId), at: 0)
            }
            
            result([
                "data": FlutterStandardTypedData(bytes: resultData)
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
    
    private func getInterfaceNumber(_ device: IOHIDDevice) -> Int {
        // Try to retrieve the USB interface number using the proper key
        if let ref = IOHIDDeviceGetProperty(device, kUSBInterfaceNumber) {
            if CFGetTypeID(ref) == CFNumberGetTypeID() {
                var interfaceNumber: Int = 0
                if CFNumberGetValue(ref as! CFNumber, .intType, &interfaceNumber) {
                    return interfaceNumber
                }
            }
        }
        // Fallback: device might not be a USB device or doesn't have interface number
        return 0
    }
    
    internal func getDeviceInfoList() -> [[String: Any]] {
        guard let manager = manager else { return [] }
        // Note: Do NOT call IOHIDManagerSetDeviceMatching here - it would trigger
        // the device matching callback and cause an infinite loop
        let deviceSet = IOHIDManagerCopyDevices(manager)
        guard let devices = deviceSet as? Set<IOHIDDevice> else {
            return []
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
                "interfaceNumber": getInterfaceNumber(device)
            ])
        }
        return deviceList
    }
}

class ReportStreamHandler: NSObject, FlutterStreamHandler {
    private let device: IOHIDDevice
    private var eventSink: FlutterEventSink?
    private let bufferSize = 256
    private var bufferPtr: UnsafeMutablePointer<UInt8>?

    init(device: IOHIDDevice) {
        self.device = device
        super.init()
    }
    
    deinit {
        bufferPtr?.deallocate()
    }

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        
        // Allocate a stable buffer for the callback
        bufferPtr = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        bufferPtr?.initialize(repeating: 0, count: bufferSize)
        
        let context = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        IOHIDDeviceRegisterInputReportCallback(device, bufferPtr!, bufferSize, { (context, result, sender, type, reportId, report, reportLength) in
            let handler = Unmanaged<ReportStreamHandler>.fromOpaque(context!).takeUnretainedValue()
            
            // Copy the data immediately since the buffer may be reused
            let data = Data(bytes: report, count: reportLength)
            let reportIdInt = Int(reportId)
            
            DispatchQueue.main.async {
                guard let eventSink = handler.eventSink else { return }
                eventSink([
                    "reportId": reportIdInt,
                    "data": FlutterStandardTypedData(bytes: data)
                ])
            }
        }, context)
        
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        if let ptr = bufferPtr {
            IOHIDDeviceRegisterInputReportCallback(device, ptr, bufferSize, nil, nil)
            ptr.deallocate()
            bufferPtr = nil
        }
        self.eventSink = nil
        return nil
    }
}

class DisconnectionStreamHandler: NSObject, FlutterStreamHandler {
    private let device: IOHIDDevice
    private var eventSink: FlutterEventSink?

    init(device: IOHIDDevice) {
        self.device = device
        super.init()
    }

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        
        let context = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        IOHIDDeviceRegisterRemovalCallback(device, { (context, result, sender) in
            let handler = Unmanaged<DisconnectionStreamHandler>.fromOpaque(context!).takeUnretainedValue()
            DispatchQueue.main.async {
                handler.eventSink?(nil) // Signal disconnection
            }
        }, context)
        
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        IOHIDDeviceRegisterRemovalCallback(device, nil, nil)
        self.eventSink = nil
        return nil
    }
}

class DeviceUpdateStreamHandler: NSObject, FlutterStreamHandler {
    private weak var plugin: HidApiPlugin?
    private var eventSink: FlutterEventSink?

    init(plugin: HidApiPlugin) {
        self.plugin = plugin
        super.init()
    }

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        
        guard let manager = plugin?.manager else { return nil }
        
        let context = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        
        IOHIDManagerRegisterDeviceMatchingCallback(manager, { (context, result, sender, device) in
            let handler = Unmanaged<DeviceUpdateStreamHandler>.fromOpaque(context!).takeUnretainedValue()
            handler.notify()
        }, context)
        
        IOHIDManagerRegisterDeviceRemovalCallback(manager, { (context, result, sender, device) in
            let handler = Unmanaged<DeviceUpdateStreamHandler>.fromOpaque(context!).takeUnretainedValue()
            handler.notify()
        }, context)
        
        // Send initial list
        notify()
        
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        guard let manager = plugin?.manager else { return nil }
        IOHIDManagerRegisterDeviceMatchingCallback(manager, nil, nil)
        IOHIDManagerRegisterDeviceRemovalCallback(manager, nil, nil)
        self.eventSink = nil
        return nil
    }
    
    private func notify() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let plugin = self.plugin else { return }
            self.eventSink?(plugin.getDeviceInfoList())
        }
    }
}
