//
//  YPaste.swift
//  YPaste
//
//  Created by 虚幻 on 2019/9/6.
//  Copyright © 2019 qwertyyb. All rights reserved.
//

import Foundation
import Magnet
import Cocoa


class YPaste {
    typealias historyChangeCallback = () -> Void
    private var hotkey: HotKey?
    var hotKeyHandler: (() -> Void)?
    var hotKeyString: String? {
        didSet {
            self.hotkey?.unregister()
            let keyCombo = getKeyComboFromString(hotKeyString!)
            registerHotKey(keyCombo: keyCombo)
        }
    }
    var onHistoryChange: historyChangeCallback?
    
    private let pasteboard = NSPasteboard.general
    private var lastChangeCount: Int = 0
    
    init() {
        UserDefaults.standard.register(defaults: ["hotKey": "command+shift+v"])
        hotKeyString = UserDefaults.standard.string(forKey: "hotKey")
        let keyCombo = getKeyComboFromString(hotKeyString!)
        registerHotKey(keyCombo: keyCombo)
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
    
    private func getKeyComboFromString(_ string: String) -> KeyCombo {
        var keysList = string.split(separator: "+")
        
        let keyString = keysList.popLast()
        let key = Key(string: String(keyString!))!
        
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
        return KeyCombo(keyCode: Int(key.carbonKeyCode), cocoaModifiers: modifiers)!
    }
    func registerHotKey(keyCombo: KeyCombo) {
        hotkey = HotKey(identifier: Bundle.main.bundleIdentifier!, keyCombo: keyCombo) { (hotkey) in
            if self.hotKeyHandler != nil { self.hotKeyHandler!() }
        }
        hotkey?.register()
    }
    
    private func checkAccess(prompt: Bool = false) -> Bool {
        let checkOptionPromptKey = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
        let opts = [checkOptionPromptKey: prompt] as CFDictionary
        return AXIsProcessTrustedWithOptions(opts)
    }
    
    func autoLaunch(active: Bool = true) {
        let launchFolder = "\(NSHomeDirectory())/Library/LaunchAgents"
        let launchPath = "\(launchFolder)/\(Bundle.main.bundleIdentifier!).plist"
        let dict = NSMutableDictionary()
        let arr = NSMutableArray()
        arr.add(Bundle.main.executablePath!)
        arr.add("-runMode")
        arr.add("autoLaunched")
        dict.setObject(active, forKey: NSMutableString("RunAtLoad"))
        dict.setObject(Bundle.main.bundleIdentifier!, forKey: NSMutableString("Label"))
        dict.setObject(arr, forKey: NSMutableString("ProgramArguments"))
        dict.write(toFile: launchPath, atomically: false)
    }
    
    static let shared = YPaste()
    
    func paste(pasteItem: PasteItem){
        self.pasteboard.declareTypes([NSPasteboard.PasteboardType.string], owner: nil)
        self.pasteboard.setString(pasteItem.value!, forType: NSPasteboard.PasteboardType.string)
        DispatchQueue.main.async {
            if !self.checkAccess() {
                let _ = self.checkAccess(prompt: true)
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
