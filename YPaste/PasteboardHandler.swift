//
//  PasteBoardHandler.swift
//  YPaste
//
//  Created by marchyang on 2019/10/22.
//  Copyright © 2019 qwertyyb. All rights reserved.
//

import Cocoa

class PasteboardHandler {
    var orderedItems: [NSManagedObjectID] = []
    var ignoreNextItems: Bool = false
    
    private let pasteboard = NSPasteboard.general
    private var lastChangeCount: Int = 0
    private var lastItem: String?
    private var lastTime: Date = Date()
    
    static let changeNotification = Notification.Name(rawValue: "HistoryChangeNotification")
    static let pastedNotification = Notification.Name(rawValue: "PastedNotification")
    
    private func isFavorite(string: String) -> Bool {
        if string == lastItem && lastTime.timeIntervalSinceNow > TimeInterval(-0.6) {
            return true
        }
        return false
    }
    
    @objc
    private func checkForChangesInPasteboard() {
        guard pasteboard.changeCount != lastChangeCount else {
            return
        }
        if let curItem = pasteboard.string(forType: NSPasteboard.PasteboardType.string) {
            if ignoreNextItems {
                lastChangeCount = pasteboard.changeCount
                NotificationCenter.default.post(name: PasteboardHandler.changeNotification, object: nil, userInfo: nil)
                return
            }
            let isFavorite = self.isFavorite(string: curItem)
            lastItem = curItem
            lastTime = Date()
            let predicate = NSPredicate(format: "value = %@ and type = %@", curItem, "text")
            let saveContext = (NSApp.delegate as! AppDelegate).persistentContainer.newBackgroundContext()
            let fetchRequest: NSFetchRequest<PasteItem> = PasteItem.fetchRequest()
            fetchRequest.predicate = predicate
            fetchRequest.returnsObjectsAsFaults = false
            let pasteItems = try? saveContext.fetch(fetchRequest);
            // 已存在,只更新时间,不存在时,添加一条记录
            if pasteItems == nil || pasteItems?.count == 0 {
                let pasteItem = NSEntityDescription.insertNewObject(forEntityName: "PasteItem", into: saveContext) as! PasteItem
                pasteItem.type = "text"
                pasteItem.value = curItem
                pasteItem.favorite = isFavorite
                pasteItem.updated_at = Date()
                try? saveContext.save()
                self.orderedItems.append(pasteItem.objectID)
                NotificationCenter.default.post(name: PasteboardHandler.changeNotification, object: nil, userInfo: ["pasteItem": pasteItem])
            } else if (pasteItems != nil && pasteItems!.count > 0) {
                let existItem = pasteItems![0]
                existItem.updated_at = Date()
                existItem.favorite = existItem.favorite ? true : isFavorite
                NotificationCenter.default.post(name: PasteboardHandler.changeNotification, object: nil, userInfo: ["pasteItem": pasteItems![0]])
                self.orderedItems.append(pasteItems![0].objectID)
                try? saveContext.save()
            }
        }
        
        lastChangeCount = pasteboard.changeCount
    }
    
    func startListener() {
        Timer.scheduledTimer(timeInterval: 0.3,
                             target: self,
                             selector: #selector(checkForChangesInPasteboard),
                             userInfo: nil,
                             repeats: true)
    }
    
    func checkAccess(prompt: Bool = false) -> Bool {
        let checkOptionPromptKey = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
        let opts = [checkOptionPromptKey: prompt] as CFDictionary
        return AXIsProcessTrustedWithOptions(opts)
    }
    
    
    func paste(pasteItem: PasteItem){
        print(NSWorkspace.shared.frontmostApplication)
        self.pasteboard.declareTypes([NSPasteboard.PasteboardType.string], owner: nil)
        self.pasteboard.setString(pasteItem.value!, forType: NSPasteboard.PasteboardType.string)
        DispatchQueue.main.async {
            if !self.checkAccess() {
                let _ = self.checkAccess(prompt: true)
            }
            // Based on https://github.com/Clipy/Clipy/blob/develop/Clipy/Sources/Services/PasteService.swift.
            
            let vCode = UInt16(0x09)
            let source = CGEventSource(stateID: .combinedSessionState)
            // Disable local keyboard events while pasting
            source?.setLocalEventsFilterDuringSuppressionState([.permitLocalMouseEvents, .permitSystemDefinedEvents], state: .eventSuppressionStateSuppressionInterval)
            
            let keyVDown = CGEvent(keyboardEventSource: source, virtualKey: vCode, keyDown: true)
            let keyVUp = CGEvent(keyboardEventSource: source, virtualKey: vCode, keyDown: false)
            keyVDown?.flags = .maskCommand
            keyVUp?.flags = .maskCommand
            keyVDown?.post(tap: .cgAnnotatedSessionEventTap)
            keyVUp?.post(tap: .cgAnnotatedSessionEventTap)
        }
    }
    
    static let shared = PasteboardHandler()
}
