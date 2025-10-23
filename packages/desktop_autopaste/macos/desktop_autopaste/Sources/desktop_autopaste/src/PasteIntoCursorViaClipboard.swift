// macos/Classes/AutoPasteTextService.swift

import Cocoa
import ApplicationServices

/// A service that types your text via CGEvents—no clipboard involved.
public class PasteIntoCursorViaClipboard {

    // Flip to `true` for deep diagnostics.
    private static let logVerbose = false

    // MARK: - Clipboard-based paste

    /// Pastes text by temporarily placing it on the clipboard and simulating Command+V.
    /// Restores the original clipboard content after pasting.
    ///
    /// Behavior:
    /// - Uses only `setString` to publish text.
    /// - No fixed sleeps.
    /// - Returns `false` if we cannot confirm publish before ⌘V, or if we exceed the post-paste ceiling.
    @discardableResult
    public static func paste(_ text: String) -> Bool {
        guard !text.isEmpty else { return true }

        let pb = NSPasteboard.general

        // 1) Save current clipboard
        let savedItems = copyPasteboardItemsData(from: pb)

        // 2) Publish our text as *plain string* (your original approach)
        let changeBeforeWrite = pb.changeCount
        pb.clearContents()
        guard pb.setString(text, forType: .string) else {
            NSLog("AutoPasteTextService: failed to set string on pasteboard")
            restorePasteboardFromData(savedItems, pasteboard: pb)
            return false
        }

        // 3) Preflight publish: confirm changeCount advanced and string equals what we set.
        guard preflightPublish(pasteboard: pb,
                               previousChangeCount: changeBeforeWrite,
                               expectedString: text,
                               timeout: 0.6) else {
            NSLog("AutoPasteTextService: could not confirm pasteboard publish in time")
            restorePasteboardFromData(savedItems, pasteboard: pb)
            return false
        }
        let changeAfterWrite = pb.changeCount

        // 4) Fire ⌘V exactly as in your original code.
        guard emulateCommandV() else {
            restorePasteboardFromData(savedItems, pasteboard: pb)
            return false
        }

        // 5) Post-paste bounded wait (NO fixed delay):
        //    Many apps touch the pasteboard immediately after a paste (e.g., sanitize or re-copy).
        //    We wait for a *new* changeCount (> changeAfterWrite). That’s our best cross-app signal
        //    that the paste round-trip completed and it’s safe to restore without racing.
        let postPasteOK = waitForPostPasteSignal(pasteboard: pb,
                                                 baselineChangeCount: changeAfterWrite,
                                                 timeout: 0.6)

        // 6) Restore the original clipboard
        restorePasteboardFromData(savedItems, pasteboard: pb)

        if !postPasteOK {
            // We didn't see a post-paste signal in time. This is the case you reported; return `false`
            // so callers can handle it (and, importantly, you won’t get a silent “success”).
            NSLog("AutoPasteTextService: post-paste signal not observed before ceiling — paste may have used old clipboard in this app")
        }

        return postPasteOK
    }

    // MARK: - EXACT same ⌘V emulation as before (factored)

    @inline(__always)
    private static func emulateCommandV() -> Bool {
        guard let source = CGEventSource(stateID: .hidSystemState) else {
            NSLog("AutoPasteTextService: failed to create CGEventSource for clipboard paste")
            return false
        }
        // 0x09 = kVK_ANSI_V
        guard let keyDownEvent = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: true),
              let keyUpEvent   = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: false) else {
            NSLog("AutoPasteTextService: failed to create Command+V events")
            return false
        }
        keyDownEvent.flags = .maskCommand
        keyUpEvent.flags   = .maskCommand
        keyDownEvent.post(tap: .cghidEventTap)
        keyUpEvent.post(tap: .cghidEventTap)
        return true
    }

    // MARK: - Timing helpers (no arbitrary sleeps)

    /// Confirm the pasteboard reflects our write: changeCount advanced AND reading .string yields expected text.
    private static func preflightPublish(pasteboard pb: NSPasteboard,
                                         previousChangeCount: Int,
                                         expectedString: String,
                                         timeout: TimeInterval) -> Bool {
        let deadline = CFAbsoluteTimeGetCurrent() + timeout
        func ok() -> Bool {
            guard pb.changeCount > previousChangeCount else { return false }
            return pb.string(forType: .string) == expectedString
        }
        if ok() { return true }
        while CFAbsoluteTimeGetCurrent() < deadline {
            CFRunLoopRunInMode(.defaultMode, 1.0/240.0, true) // tiny runloop tick
            if ok() { return true }
        }
        return false
    }

    /// Wait for a likely "paste completed" signal: changeCount advances again after ⌘V.
    /// This is heuristic (reads don't change changeCount; many apps *do* write).
    /// We bound the wait and return false if we never see it.
    private static func waitForPostPasteSignal(pasteboard pb: NSPasteboard,
                                               baselineChangeCount: Int,
                                               timeout: TimeInterval) -> Bool {
        // Early exit: if the app already touched the pasteboard instantly.
        if pb.changeCount > baselineChangeCount { return true }

        let deadline = CFAbsoluteTimeGetCurrent() + timeout
        while CFAbsoluteTimeGetCurrent() < deadline {
            CFRunLoopRunInMode(.defaultMode, 1.0/240.0, true)
            if pb.changeCount > baselineChangeCount {
                return true
            }
        }
        return false
    }

    // MARK: - Save

    struct SavedPasteboardItem {
        var data: [NSPasteboard.PasteboardType: Data]
        var promised: [NSPasteboard.PasteboardType]
        var typeOrder: [NSPasteboard.PasteboardType]
    }

    private static func copyPasteboardItemsData(from pb: NSPasteboard) -> [SavedPasteboardItem] {
        guard let items = pb.pasteboardItems else { return [] }
        var saved: [SavedPasteboardItem] = []
        for (idx, item) in items.enumerated() {
            var have: [NSPasteboard.PasteboardType: Data] = [:]
            var promised: [NSPasteboard.PasteboardType] = []
            var filteredTypes: [NSPasteboard.PasteboardType] = []
            let types = item.types

            if logVerbose {
                NSLog("Saved item \(idx): available types = \(types.map { $0.rawValue })")
            }

            for t in types {
                let s = t.rawValue
                // Skip unstable flavors
                if s.contains("0x") || s.contains(".pid.") || s.hasPrefix("com.microsoft.ole.source.") {
                    if logVerbose { NSLog("Saved item \(idx): SKIPPING session-specific type '\(s)'") }
                    continue
                }
                if let d = item.data(forType: t), !d.isEmpty {
                    have[t] = d
                    filteredTypes.append(t)
                    if logVerbose { NSLog("Saved item \(idx): type '\(s)' = \(d.count) bytes") }
                } else {
                    promised.append(t)
                    if logVerbose { NSLog("Saved item \(idx): type '\(s)' is PROMISED or empty") }
                }
            }
            saved.append(.init(data: have, promised: promised, typeOrder: filteredTypes))
        }
        return saved
    }

    // MARK: - Restore (quiet)

    private final class SavedProvider: NSObject, NSPasteboardItemDataProvider {
        let payload: [NSPasteboard.PasteboardType: Data]
        init(payload: [NSPasteboard.PasteboardType: Data]) { self.payload = payload }
        func pasteboard(_ pb: NSPasteboard?, item: NSPasteboardItem, provideDataForType t: NSPasteboard.PasteboardType) {
            if let d = payload[t] { _ = item.setData(d, forType: t) }
        }
    }

    private static func restorePasteboardFromData(_ savedItems: [SavedPasteboardItem], pasteboard pb: NSPasteboard) {
        guard !savedItems.isEmpty else { return }
        var newItems: [NSPasteboardItem] = []
        for s in savedItems {
            let it = NSPasteboardItem()
            for t in s.typeOrder {
                if let d = s.data[t] {
                    if t == .string, let str = String(data: d, encoding: .utf8) {
                        _ = it.setString(str, forType: .string)
                    } else {
                        _ = it.setData(d, forType: t)
                    }
                }
            }
            newItems.append(it)
        }
        pb.clearContents()
        _ = pb.writeObjects(newItems)
    }
}
