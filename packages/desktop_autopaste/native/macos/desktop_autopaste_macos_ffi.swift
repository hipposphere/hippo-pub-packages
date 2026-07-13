import AppKit
import ApplicationServices
import Foundation

private func writeUtf8(
  _ buffer: UnsafeMutablePointer<CChar>?,
  _ capacity: UInt32,
  _ message: String
) {
  guard let buffer, capacity > 0 else {
    return
  }

  let bytes = Array(message.utf8)
  let maxCopy = Int(capacity) - 1
  let copyCount = min(bytes.count, maxCopy)

  if copyCount > 0 {
    for i in 0..<copyCount {
      buffer[i] = CChar(bitPattern: bytes[i])
    }
  }
  buffer[copyCount] = 0
}

private struct SavedPasteboardItem {
  var data: [NSPasteboard.PasteboardType: Data]
  var typeOrder: [NSPasteboard.PasteboardType]
}

private struct SavedPasteboard {
  var items: [SavedPasteboardItem]
}

// Paste calls may overlap while a previous delayed restore is pending. Keep the
// first external clipboard snapshot until the latest paste transaction finishes
// so an intermediate injected value is never treated as user clipboard data.
// These values are only accessed from the main thread.
private var activePasteboardSnapshot: SavedPasteboard?
private var activePasteboardChangeCount: Int?
private var activePasteGeneration: UInt64 = 0

enum PasteResult {
  case ok
  case error(code: Int32, message: String)
}

func desktopAutopasteMacosPasteIntoCursorViaClipboardResult(_ text: String) -> PasteResult {
  let runPaste: () -> PasteResult = {
    guard !text.isEmpty else {
      return .ok
    }

    let pasteboard = NSPasteboard.general
    preparePasteboardTransaction(pasteboard: pasteboard)
    guard let savedPasteboard = activePasteboardSnapshot else {
      return .error(code: 1, message: "Failed to snapshot pasteboard")
    }
    activePasteGeneration &+= 1
    let pasteGeneration = activePasteGeneration

    let changeBeforeWrite = pasteboard.changeCount
    pasteboard.clearContents()
    guard pasteboard.setString(text, forType: .string) else {
      restorePasteboard(savedPasteboard, pasteboard: pasteboard)
      clearActivePasteboardTransaction()
      return .error(code: 1, message: "Failed to write to pasteboard")
    }
    let injectedChangeCount = pasteboard.changeCount
    activePasteboardChangeCount = injectedChangeCount

    guard preflightPublish(
      pasteboard: pasteboard,
      previousChangeCount: changeBeforeWrite,
      expectedString: text,
      timeout: 0.6
    ) else {
      restorePasteboardIfUnchanged(
        savedPasteboard,
        pasteboard: pasteboard,
        expectedChangeCount: injectedChangeCount,
        expectedString: text
      )
      clearActivePasteboardTransaction()
      return .error(code: 1, message: "Pasteboard publish preflight failed")
    }

    guard emulateCommandV() else {
      restorePasteboardIfUnchanged(
        savedPasteboard,
        pasteboard: pasteboard,
        expectedChangeCount: injectedChangeCount,
        expectedString: text
      )
      clearActivePasteboardTransaction()
      return .error(code: 1, message: "Failed to emulate Command+V")
    }
    // Do not synchronously wait for a post-paste signal here. Flutter text
    // fields often consume Cmd+V asynchronously on the app event loop, and
    // waiting inline can race/delay delivery.
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
      guard pasteGeneration == activePasteGeneration else {
        return
      }
      restorePasteboardIfUnchanged(
        savedPasteboard,
        pasteboard: pasteboard,
        expectedChangeCount: injectedChangeCount,
        expectedString: text
      )
      clearActivePasteboardTransaction()
    }

    return .ok
  }

  if Thread.isMainThread {
    return runPaste()
  }
  return DispatchQueue.main.sync(execute: runPaste)
}

func desktopAutopasteMacosPasteIntoCursorViaClipboard(_ text: String) -> Bool {
  switch desktopAutopasteMacosPasteIntoCursorViaClipboardResult(text) {
  case .ok:
    return true
  case .error:
    return false
  }
}

func desktopAutopasteMacosPasteFromClipboardResult(prePasteDelayMs: Int32) -> PasteResult {
  let runPaste: () -> PasteResult = {
    let delayMs = max(0, prePasteDelayMs)
    if delayMs > 0 {
      Thread.sleep(forTimeInterval: Double(delayMs) / 1000.0)
    }

    guard emulateCommandV() else {
      return .error(code: 1, message: "Failed to emulate Command+V")
    }
    return .ok
  }

  if Thread.isMainThread {
    return runPaste()
  }
  return DispatchQueue.main.sync(execute: runPaste)
}

@objcMembers
public final class DesktopAutopasteMacosBridge: NSObject {
  public static func pasteIntoCursorViaClipboard(_ text: String) -> Bool {
    desktopAutopasteMacosPasteIntoCursorViaClipboard(text)
  }
}

@_cdecl("desktop_autopaste_paste_into_cursor_via_clipboard")
public func desktop_autopaste_paste_into_cursor_via_clipboard(
  _ textUtf8: UnsafePointer<CChar>?,
  _ prePasteDelayMs: Int32,
  _ pasteShortcut: Int32,
  _ errorUtf8: UnsafeMutablePointer<CChar>?,
  _ errorUtf8Capacity: UInt32
) -> Int32 {
  _ = prePasteDelayMs
  _ = pasteShortcut
  guard let textUtf8 else {
    writeUtf8(errorUtf8, errorUtf8Capacity, "Missing text")
    return 2
  }

  guard let text = String(validatingUTF8: textUtf8) else {
    writeUtf8(errorUtf8, errorUtf8Capacity, "Invalid UTF-8 text")
    return 2
  }
  let result = desktopAutopasteMacosPasteIntoCursorViaClipboardResult(text)

  switch result {
  case .ok:
    writeUtf8(errorUtf8, errorUtf8Capacity, "")
    return 0
  case let .error(code, message):
    writeUtf8(errorUtf8, errorUtf8Capacity, message)
    return code
  }
}

@_cdecl("desktop_autopaste_paste_from_clipboard")
public func desktop_autopaste_paste_from_clipboard(
  _ prePasteDelayMs: Int32,
  _ pasteShortcut: Int32,
  _ errorUtf8: UnsafeMutablePointer<CChar>?,
  _ errorUtf8Capacity: UInt32
) -> Int32 {
  _ = pasteShortcut
  let result = desktopAutopasteMacosPasteFromClipboardResult(
    prePasteDelayMs: prePasteDelayMs
  )

  switch result {
  case .ok:
    writeUtf8(errorUtf8, errorUtf8Capacity, "")
    return 0
  case let .error(code, message):
    writeUtf8(errorUtf8, errorUtf8Capacity, message)
    return code
  }
}

@_cdecl("desktop_autopaste_get_focused_text_field_context_json")
public func desktop_autopaste_get_focused_text_field_context_json(
  _ maxCharsBefore: Int32,
  _ maxCharsAfter: Int32,
  _ enableScreenReader: Int32,
  _ contextJsonUtf8: UnsafeMutablePointer<CChar>?,
  _ contextJsonUtf8Capacity: UInt32,
  _ errorUtf8: UnsafeMutablePointer<CChar>?,
  _ errorUtf8Capacity: UInt32
) -> Int32 {
  _ = maxCharsBefore
  _ = maxCharsAfter
  _ = enableScreenReader

  guard contextJsonUtf8 != nil, contextJsonUtf8Capacity > 0 else {
    writeUtf8(errorUtf8, errorUtf8Capacity, "Missing output buffer")
    return 2
  }

  writeUtf8(
    contextJsonUtf8,
    contextJsonUtf8Capacity,
    "{\"available\":false,\"reason\":\"unsupportedOnMacOS\"}"
  )
  writeUtf8(errorUtf8, errorUtf8Capacity, "")
  return 0
}

@_cdecl("desktop_autopaste_edit_focused_text_field")
public func desktop_autopaste_edit_focused_text_field(
  _ operations: UnsafeRawPointer?,
  _ operationCount: UInt32,
  _ errorUtf8: UnsafeMutablePointer<CChar>?,
  _ errorUtf8Capacity: UInt32
) -> Int32 {
  _ = operations
  _ = operationCount
  writeUtf8(errorUtf8, errorUtf8Capacity, "unsupportedOnMacOS")
  return 3
}

private func emulateCommandV() -> Bool {
  guard let source = CGEventSource(stateID: .hidSystemState) else {
    return false
  }

  guard
    let keyDownEvent = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: true),
    let keyUpEvent = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: false)
  else {
    return false
  }

  keyDownEvent.flags = .maskCommand
  keyUpEvent.flags = .maskCommand
  keyDownEvent.post(tap: .cghidEventTap)
  keyUpEvent.post(tap: .cghidEventTap)
  return true
}

private func preflightPublish(
  pasteboard: NSPasteboard,
  previousChangeCount: Int,
  expectedString: String,
  timeout: TimeInterval
) -> Bool {
  let deadline = CFAbsoluteTimeGetCurrent() + timeout

  func ok() -> Bool {
    guard pasteboard.changeCount > previousChangeCount else {
      return false
    }
    return pasteboard.string(forType: .string) == expectedString
  }

  if ok() {
    return true
  }

  while CFAbsoluteTimeGetCurrent() < deadline {
    CFRunLoopRunInMode(.defaultMode, 1.0 / 240.0, true)
    if ok() {
      return true
    }
  }

  return false
}

private func waitForPostPasteSignal(
  pasteboard: NSPasteboard,
  baselineChangeCount: Int,
  timeout: TimeInterval
) -> Bool {
  if pasteboard.changeCount > baselineChangeCount {
    return true
  }

  let deadline = CFAbsoluteTimeGetCurrent() + timeout
  while CFAbsoluteTimeGetCurrent() < deadline {
    CFRunLoopRunInMode(.defaultMode, 1.0 / 240.0, true)
    if pasteboard.changeCount > baselineChangeCount {
      return true
    }
  }

  return false
}

private func preparePasteboardTransaction(pasteboard: NSPasteboard) {
  if let expectedChangeCount = activePasteboardChangeCount,
    pasteboard.changeCount != expectedChangeCount
  {
    // An external writer changed the clipboard while a restore was pending.
    // Treat the new contents as the next transaction's baseline.
    clearActivePasteboardTransaction()
  }

  if activePasteboardSnapshot == nil {
    activePasteboardSnapshot = copyPasteboard(from: pasteboard)
  }
}

private func clearActivePasteboardTransaction() {
  activePasteboardSnapshot = nil
  activePasteboardChangeCount = nil
}

private func copyPasteboard(from pasteboard: NSPasteboard) -> SavedPasteboard {
  guard let items = pasteboard.pasteboardItems else {
    return SavedPasteboard(items: [])
  }

  var saved: [SavedPasteboardItem] = []
  saved.reserveCapacity(items.count)

  for item in items {
    var dataByType: [NSPasteboard.PasteboardType: Data] = [:]
    var typeOrder: [NSPasteboard.PasteboardType] = []

    for type in item.types {
      // Reading every advertised type materializes promised clipboard data
      // while its original owner is still available.
      if let data = item.data(forType: type) {
        dataByType[type] = data
        typeOrder.append(type)
      }
    }

    saved.append(
      SavedPasteboardItem(data: dataByType, typeOrder: typeOrder)
    )
  }

  return SavedPasteboard(items: saved)
}

private func restorePasteboardIfUnchanged(
  _ savedPasteboard: SavedPasteboard,
  pasteboard: NSPasteboard,
  expectedChangeCount: Int,
  expectedString: String
) {
  guard pasteboard.changeCount == expectedChangeCount,
    pasteboard.string(forType: .string) == expectedString
  else {
    return
  }

  restorePasteboard(savedPasteboard, pasteboard: pasteboard)
}

private func restorePasteboard(
  _ savedPasteboard: SavedPasteboard,
  pasteboard: NSPasteboard
) {
  let savedItems = savedPasteboard.items

  var newItems: [NSPasteboardItem] = []
  newItems.reserveCapacity(savedItems.count)

  for saved in savedItems {
    let item = NSPasteboardItem()

    for type in saved.typeOrder {
      guard let data = saved.data[type] else {
        continue
      }
      if type == .string, let text = String(data: data, encoding: .utf8) {
        _ = item.setString(text, forType: .string)
      } else {
        _ = item.setData(data, forType: type)
      }
    }

    newItems.append(item)
  }

  pasteboard.clearContents()
  if !newItems.isEmpty {
    _ = pasteboard.writeObjects(newItems)
  }
}
