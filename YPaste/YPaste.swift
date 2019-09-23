//
//  YPaste.swift
//  YPaste
//
//  Created by 虚幻 on 2019/9/6.
//  Copyright © 2019 qwertyyb. All rights reserved.
//

import Foundation
import HotKey
import Cocoa


class YPaste {
    typealias historyChangeCallback = () -> Void
    private var hotkey: HotKey?
    var hotKeyHandler: HotKey.Handler? {
        get { return self.hotkey?.keyDownHandler }
        set (handler) { self.hotkey?.keyDownHandler = handler }
    }
    var onHistoryChange: historyChangeCallback?
    
    private let pasteboard = NSPasteboard.general
    private var lastChangeCount: Int = 0
    
    init() {
        registerHotKey()
        listeningPasteBoard()
    }
    
    
    private func listeningPasteBoard() {
        Timer.scheduledTimer(timeInterval: 1.0,
                             target: self,
                             selector: #selector(checkForChangesInPasteboard),
                             userInfo: nil,
                             repeats: true)
    }
    
    @objc
    private func checkForChangesInPasteboard() {
        guard pasteboard.changeCount != lastChangeCount else {
            return
        }
        
        if let lastItem = pasteboard.string(forType: NSPasteboard.PasteboardType.string) {
            let saveContext = (NSApp.delegate as! AppDelegate).persistentContainer.newBackgroundContext()
            let fetchRequest = NSFetchRequest<PasteItem>(entityName: "PasteItem")
            fetchRequest.predicate = NSPredicate(format: "value = %@ and type = %@", lastItem, "text")
            let pasteItems = try? saveContext.fetch(fetchRequest);
            // 已存在,只更新时间,不存在时,添加一条记录
            if pasteItems == nil || pasteItems?.count == 0 {
                let pasteItem = NSEntityDescription.insertNewObject(forEntityName: "PasteItem", into: saveContext) as! PasteItem
                pasteItem.type = "text"
                pasteItem.value = lastItem
                pasteItem.updated_at = Date()
                try? saveContext.save()
            } else {
                pasteItems?[0].updated_at = Date()
                try? saveContext.save()
            }
            onHistoryChange?()
        }
        
        lastChangeCount = pasteboard.changeCount
    }
    
    private func registerHotKey() {
//        guard let keybindingString = UserDefaults.standard.string(forKey: hotKeyStore) else {
//            return
//        }
        let keybindingString = "command+shift+v"
        var keysList = keybindingString.split(separator: "+")
        
        guard let keyString = keysList.popLast() else {
            return
        }
        guard let key = Key(string: String(keyString)) else {
            return
        }
        
        var modifiers: NSEvent.ModifierFlags = []
        for keyString in keysList {
            switch keyString {
            case "command":
                modifiers.insert(.command)
            case "control":
                modifiers.insert(.control)
            case "option":
                modifiers.insert(.option)
            case "shift":
                modifiers.insert(.shift)
            default: ()
            }
        }
        
        hotkey = HotKey(key: key, modifiers: modifiers)
    }
    
    private func checkAccess() -> Bool{
        let options : NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString: false]
        let accessibilityEnabled = AXIsProcessTrustedWithOptions(options)
        return accessibilityEnabled
    }
    
    func paste(pasteItem: PasteItem){
        self.pasteboard.declareTypes([NSPasteboard.PasteboardType.string], owner: nil)
        self.pasteboard.setString(pasteItem.value!, forType: NSPasteboard.PasteboardType.string)
        DispatchQueue.main.async {
            if !self.checkAccess() {
                let alert = NSAlert()
                alert.window.level = .popUpMenu
                alert.alertStyle = .warning
                alert.window.title = "warning"
                alert.messageText = "The Application need accessibility permission to paste automatically"
                alert.addButton(withTitle: "open accessibility preferences")
                let denyBtn = alert.addButton(withTitle: "deny")
                denyBtn.refusesFirstResponder = true
                if alert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn {
                    NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
                }
            }
            // Based on https://github.com/Clipy/Clipy/blob/develop/Clipy/Sources/Services/PasteService.swift.
            NSWorkspace.shared.menuBarOwningApplication?.activate(options: NSApplication.ActivationOptions.activateIgnoringOtherApps)
            Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { (timer) in
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
    }
}
