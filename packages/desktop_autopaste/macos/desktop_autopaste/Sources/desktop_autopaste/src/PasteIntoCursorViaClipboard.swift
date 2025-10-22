// macos/Classes/AutoPasteTextService.swift

import Cocoa
import ApplicationServices

/// A service that types your text via CGEvents—no clipboard involved.
public class PasteIntoCursorViaClipboard {
 
    // MARK: - Clipboard-based paste

    /// Pastes text by temporarily placing it on the clipboard and simulating Command+V.
    /// Restores the original clipboard content after pasting.
    @discardableResult
    public static func paste(_ text: String) -> Bool {
        guard !text.isEmpty else { return true }
        
        let pasteboard = NSPasteboard.general
        
        // Copy data from all pasteboard items BEFORE clearing
        // We can't reuse NSPasteboardItem objects, so we need to copy the data
        let savedItemsData = copyPasteboardItemsData(from: pasteboard)

        usleep(100_000) // 100ms
        
        // Set the new text to the clipboard
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)

        usleep(25_000) // 25ms
        
        // Simulate Command+V
        guard let source = CGEventSource(stateID: .hidSystemState) else {
            NSLog("AutoPasteTextService: failed to create CGEventSource for clipboard paste")
            restorePasteboardFromData(savedItemsData, pasteboard: pasteboard)
            return false
        }
        
        // Create Command+V key events (0x09 = kVK_ANSI_V)
        guard let keyDownEvent = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: true),
              let keyUpEvent = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: false) else {
            NSLog("AutoPasteTextService: failed to create Command+V events")
            restorePasteboardFromData(savedItemsData, pasteboard: pasteboard)
            return false
        }
        
        // Set Command flag
        keyDownEvent.flags = .maskCommand
        keyUpEvent.flags = .maskCommand
        
        // Post the events
        keyDownEvent.post(tap: .cghidEventTap)
        keyUpEvent.post(tap: .cghidEventTap)

        usleep(50_000) // 50ms

        // Restore the original clipboard content
        restorePasteboardFromData(savedItemsData, pasteboard: pasteboard)
        
        return true
    }
    

struct SavedPasteboardItem {
    var data: [NSPasteboard.PasteboardType: Data]   // concrete bytes we managed to read
    var promised: [NSPasteboard.PasteboardType]     // types that returned nil
    var typeOrder: [NSPasteboard.PasteboardType]    // original order we observed
}

private static func copyPasteboardItemsData(from pb: NSPasteboard) -> [SavedPasteboardItem] {
    guard let items = pb.pasteboardItems else { return [] }
    var saved: [SavedPasteboardItem] = []
    for (idx, item) in items.enumerated() {
        var have: [NSPasteboard.PasteboardType: Data] = [:]
        var promised: [NSPasteboard.PasteboardType] = []
        var filteredTypes: [NSPasteboard.PasteboardType] = []
        let types = item.types
        
        NSLog("Saved item \(idx): available types = \(types.map { $0.rawValue })")
        
        for t in types {
            let typeStr = t.rawValue
            
            // Skip session-specific types that contain memory addresses or process IDs
            // These are dynamically generated and won't be valid when restored
            if typeStr.contains("0x") || typeStr.contains(".pid.") {
                NSLog("Saved item \(idx): SKIPPING session-specific type '\(typeStr)' (contains memory address or PID)")
                continue
            }
            
            // Skip Microsoft dynamic OLE source types
            if typeStr.hasPrefix("com.microsoft.ole.source.") {
                NSLog("Saved item \(idx): SKIPPING Microsoft OLE source type '\(typeStr)' (session-specific)")
                continue
            }
            
            if let d = item.data(forType: t) {
                // Skip types with 0 bytes - they're likely invalid or session-specific
                if d.count == 0 {
                    NSLog("Saved item \(idx): SKIPPING empty type '\(typeStr)' (0 bytes)")
                    continue
                }
                have[t] = d
                filteredTypes.append(t)
                NSLog("Saved item \(idx): type '\(typeStr)' = \(d.count) bytes")
            } else {
                promised.append(t)
                NSLog("Saved item \(idx): type '\(typeStr)' is PROMISED (no immediate data)")
            }
        }
        saved.append(.init(data: have, promised: promised, typeOrder: filteredTypes))
        NSLog("Saved item \(idx): TOTAL \(have.count) data types, \(promised.count) promised, \(types.count - filteredTypes.count - promised.count) skipped")
    }
    return saved
}



// Restore


final class SavedProvider: NSObject, NSPasteboardItemDataProvider {
    let payload: [NSPasteboard.PasteboardType: Data]
    init(payload: [NSPasteboard.PasteboardType: Data]) { self.payload = payload }
    func pasteboard(_ pb: NSPasteboard?, item: NSPasteboardItem, provideDataForType t: NSPasteboard.PasteboardType) {
        if let d = payload[t] { _ = item.setData(d, forType: t) }
    }
}

private static func restorePasteboardFromData(_ savedItems: [SavedPasteboardItem], pasteboard pb: NSPasteboard) {
    guard !savedItems.isEmpty else { return }

    NSLog("=== RESTORING CLIPBOARD ===")
    var newItems: [NSPasteboardItem] = []
    for (index, s) in savedItems.enumerated() {
        let it = NSPasteboardItem()

        // Use EXACT original type order to preserve Word's expectations
        // Word may check specific type ordering or combinations
        NSLog("Restore item \(index): restoring \(s.typeOrder.count) types in original order")
        
        var restoredCount = 0
        var skippedCount = 0
        
        // Set data in the exact original order - ONLY restore types we have data for
        for t in s.typeOrder {
            if let d = s.data[t] {
                if t == .string, let str = String(data: d, encoding: .utf8) {
                    let success = it.setString(str, forType: .string)
                    NSLog("Restore item \(index): type '\(t.rawValue)' as string = \(success)")
                } else {
                    let success = it.setData(d, forType: t)
                    NSLog("Restore item \(index): type '\(t.rawValue)' (\(d.count) bytes) = \(success)")
                }
                restoredCount += 1
            } else {
                // This was a promised type - we can't restore it
                NSLog("Restore item \(index): SKIPPING promised type '\(t.rawValue)' (no data available)")
                skippedCount += 1
            }
        }

        NSLog("Restore item \(index): restored \(restoredCount) types, skipped \(skippedCount) promised types")
        newItems.append(it)
    }

    pb.clearContents()
    let success = pb.writeObjects(newItems)
    
    NSLog("Restored \(newItems.count) pasteboard items, writeObjects success = \(success)")
    NSLog("=== CLIPBOARD RESTORED ===")
}





}