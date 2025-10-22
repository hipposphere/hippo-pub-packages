// macos/Classes/AutoPasteTextService.swift

import Cocoa
import ApplicationServices

/// A service that types your text via CGEvents—no clipboard involved.
public class PasteIntoCursor {
    // Maximum number of UTF-16 code units per Unicode event
    private static let maxUnicodeStringLength = 20
    // Small pacing delay to help browser editors (in microseconds)
    private static let smallDelayMicros: useconds_t = 5000 // 5 ms
    private static let baseDelayMicros: useconds_t = 15_000 // 15 ms
    private static let jitterMicros: useconds_t    = 8_000 // ±8 ms

    /// Synthesizes key events to type the given text.
    /// For short, control-free text we use the Unicode string path.
    /// Otherwise we stream printable runs and emit control keys (like Shift+Return, Tab) as real key events.
    @discardableResult
    public static func paste(_ text: String) -> Bool {
        guard !text.isEmpty else { return true }
        guard let source = CGEventSource(stateID: .hidSystemState) else {
            NSLog("AutoPasteTextService: failed to create CGEventSource")
            return false
        }
    if(cursorIsInSafari()){
        return pastePerGrapheme(text, source: source)
    }else{
        if text.count <= maxUnicodeStringLength && !containsControlChars(text) {
            return pasteUsingUnicodeString(text, source: source)
        } else {
            return pasteSmart(text, source: source)
        }
    }
        
    }



    // MARK: - Per-grapheme streaming (no batching)

    /// Emits exactly one Unicode keyDown+keyUp per extended grapheme cluster.
    /// Newlines use Shift+Return (soft break); Tab uses real Tab.
    private static func pastePerGrapheme(_ text: String, source: CGEventSource) -> Bool {
        for ch in text {
            switch ch {
            case "\n", "\r":
                if !tapShiftReturn(source: source) {
                    NSLog("AutoPasteTextService: failed to emit Shift+Return")
                    return false
                }
                sleepWithJitter()

            case "\t":
                if !tapVirtualKey(virtualKey: 0x30, flags: [], source: source) { // kVK_Tab
                    NSLog("AutoPasteTextService: failed to emit Tab")
                    return false
                }
                sleepWithJitter()

            default:
                // Emit this grapheme atomically via Unicode string.
                let units = Array(String(ch).utf16)
                guard emitUnicodeBuffer(units, source: source) else { return false }
                sleepWithJitter()
            }
        }
        return true
    }

    // MARK: - Smart streaming with explicit control keys

    /// Streams text in runs of printable characters, emitting control keys as real events.
    /// Newlines (\n, \r) are typed as **Shift+Return** (soft line break).
    private static func pasteSmart(_ text: String, source: CGEventSource) -> Bool {
        var buffer: [UInt16] = []
        buffer.reserveCapacity(maxUnicodeStringLength)

        func flushBuffer() -> Bool {
            guard !buffer.isEmpty else { return true }
            guard emitUnicodeBuffer(buffer, source: source) else { return false }
            buffer.removeAll(keepingCapacity: true)
            usleep(smallDelayMicros)
            return true
        }

        for scalar in text.unicodeScalars {
            switch scalar {
            case "\n", "\r":
                // Soft break via Shift+Return
                if !flushBuffer() { return false }
                if !tapShiftReturn(source: source) {
                    NSLog("AutoPasteTextService: failed to emit Shift+Return")
                    return false
                }
                usleep(smallDelayMicros)

            case "\t":
                if !flushBuffer() { return false }
                if !tapVirtualKey(virtualKey: 0x30, flags: [], source: source) { // kVK_Tab
                    NSLog("AutoPasteTextService: failed to emit Tab")
                    return false
                }
                usleep(smallDelayMicros)

            default:
                // Accumulate printable chars; split into UTF-16 units
                for unit in String(scalar).utf16 {
                    buffer.append(unit)
                    if buffer.count >= maxUnicodeStringLength {
                        if !flushBuffer() { return false }
                    }
                }
            }
        }

        return flushBuffer()
    }

    // MARK: - Unicode-string path

    /// Pastes text using the Unicode string method for short control-free runs.
    private static func pasteUsingUnicodeString(_ text: String, source: CGEventSource) -> Bool {
        let utf16units = Array(text.utf16)
        return emitUnicodeBuffer(utf16units, source: source)
    }

    /// Emits a pair of Unicode-string key events using a prepared UTF-16 buffer.
    private static func emitUnicodeBuffer(_ utf16: [UInt16], source: CGEventSource) -> Bool {
        guard let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: true),
              let keyUp   = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: false) else {
            NSLog("AutoPasteTextService: failed to create key events")
            return false
        }

        utf16.withUnsafeBufferPointer { buf in
            keyDown.keyboardSetUnicodeString(stringLength: buf.count, unicodeString: buf.baseAddress)
            keyUp.keyboardSetUnicodeString(stringLength: buf.count, unicodeString: buf.baseAddress)
        }

        keyDown.post(tap: .cghidEventTap)
        keyUp.post(tap: .cghidEventTap)
        return true
    }

    // MARK: - Key emitters

    /// Emits a single keyDown+keyUp for the given virtual key with optional modifier flags.
    private static func tapVirtualKey(virtualKey: CGKeyCode, flags: CGEventFlags, source: CGEventSource) -> Bool {
        guard let down = CGEvent(keyboardEventSource: source, virtualKey: virtualKey, keyDown: true),
              let up   = CGEvent(keyboardEventSource: source, virtualKey: virtualKey, keyDown: false) else {
            return false
        }
        if !flags.isEmpty {
            down.flags = flags
            up.flags = flags
        }
        down.post(tap: .cghidEventTap)
        up.post(tap: .cghidEventTap)
        return true
    }

    /// Emits **Shift+Return** (soft line break).
    private static func tapShiftReturn(source: CGEventSource) -> Bool {
        return tapVirtualKey(virtualKey: 0x24, flags: .maskShift, source: source) // 0x24 = kVK_Return
    }

    // MARK: - Utilities

    private static func containsControlChars(_ s: String) -> Bool {
        for u in s.unicodeScalars {
            if u == "\n" || u == "\r" || u == "\t" { return true }
        }
        return false
    }

    // MARK: - Utils

    /// Sleep ~baseDelay ± jitter, safely (no negative cast).
    private static func sleepWithJitter() {
        let base = Int(baseDelayMicros)
        let jit  = Int(jitterMicros)
        let delta = Int.random(in: -jit...jit)
        let total = max(0, base + delta)
        usleep(useconds_t(total))
    }

        /// Returns true if the current mouse point falls on any Safari UI element/window.
   private static func cursorIsInSafari() -> Bool {
        // Ensure we're trusted for AX (you can also call AXIsProcessTrustedWithOptions to prompt).
        guard AXIsProcessTrusted() else { return false }

        // Get mouse location in global display coords (Quartz coordinates).
        let mouse = CGEvent(source: nil)?.location ?? .zero

        // Hit-test the UI element under the cursor.
        let system = AXUIElementCreateSystemWide()
        var hitElement: AXUIElement?
        let err = AXUIElementCopyElementAtPosition(system, Float(mouse.x), Float(mouse.y), &hitElement)
        guard err == .success, let element = hitElement else { return false }

        // Resolve owning process.
        var pid: pid_t = 0
        AXUIElementGetPid(element, &pid)

        // Map PID -> running app -> bundle id.
        if let app = NSRunningApplication(processIdentifier: pid) {
            return app.bundleIdentifier == "com.apple.Safari"
        } else {
            // Fallback: some elements may be transient; try walking to the application element.
            return false
        }
    }

    


}