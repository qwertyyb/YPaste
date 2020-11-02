//
//  HotkeyHandler.swift
//  YPaste
//
//  Created by marchyang on 2019/10/22.
//  Copyright © 2019 qwertyyb. All rights reserved.
//

import Foundation
import HotKey

enum OpenType {
    case history
    case favorite
    case all
    case order
}

class HotkeyHandler {
    private var openHistoryHotkey: HotKey?
    private var openFavoriteHotkey: HotKey?
    private var openOrderHotkey: HotKey?
    private var pasteHotkey: HotKey?
    
    
    init() {
        UserDefaults.standard.register(defaults: ["hotKey": "command+shift+v"])
        UserDefaults.standard.register(defaults: ["favoriteHotKey": "command+shift+f"])
        UserDefaults.standard.register(defaults: ["activeHotKey": "command+shift+c"])
    }
    
    static let openWindowNotification = Notification.Name("openWindowNotification")

    var openType = OpenType.history {
        didSet {
            if self.openType != .order {
                pasteHotkey = nil
            } else {
                registerOrderPaste()
            }
        }
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
        return KeyCombo(key: key, modifiers: modifiers)
    }
    func register() {
        var hotKeyString = UserDefaults.standard.string(forKey: "hotKey")
        var keyCombo = getKeyComboFromString(hotKeyString!)
        openHistoryHotkey = HotKey(keyCombo: keyCombo, keyDownHandler: {
            self.openType = .history
            NotificationCenter.default.post(name: HotkeyHandler.openWindowNotification, object: nil)
        }, keyUpHandler: nil)
        
        hotKeyString = UserDefaults.standard.string(forKey: "favoriteHotKey")
        keyCombo = getKeyComboFromString(hotKeyString!)
        openFavoriteHotkey = HotKey(keyCombo: keyCombo, keyDownHandler: {
            self.openType = .favorite
            NotificationCenter.default.post(name: HotkeyHandler.openWindowNotification, object: nil)
        }, keyUpHandler: nil)
        
        hotKeyString = UserDefaults.standard.string(forKey: "activeHotKey")
        keyCombo = getKeyComboFromString(hotKeyString!)
        openOrderHotkey = HotKey(keyCombo: keyCombo, keyDownHandler: {
            if self.openType == .order {
                self.openType = .history
//                return YPaste.shared.mainWindowController.close()
            }
            self.openType = .order
            PasteboardHandler.shared.orderedItems = []
            NotificationCenter.default.post(name: HotkeyHandler.openWindowNotification, object: nil)
        }, keyUpHandler: nil)
        
        
    }
    
    private func registerOrderPaste () {
        pasteHotkey = HotKey(key: .v, modifiers: .command, keyDownHandler: {
            let pasteboard = PasteboardHandler.shared
            if let objectId = pasteboard.orderedItems.first {
                let managedContext = (NSApp.delegate as! AppDelegate).persistentContainer.viewContext
                let pasteItem = managedContext.object(with: objectId) as! PasteItem
                pasteboard.ignoreNextItems = true
//                PasteboardHandler.shared.paste(pasteItem: pasteItem)
                pasteboard.orderedItems.removeFirst()
                Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { (timer) in
                    if let nextId = pasteboard.orderedItems.first {
                        let pasteItem = managedContext.object(with: nextId) as! PasteItem
                        NSPasteboard.general.setString(pasteItem.value!, forType: .string)
                        Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false) { (timer) in
                            pasteboard.ignoreNextItems = false
                        }
                    } else {
                        pasteboard.ignoreNextItems = false
                        NotificationCenter.default.post(name: PasteboardHandler.pastedNotification, object: nil)
                        self.openType = .history
                    }
                }
            }
        })
    }
    
    static let shared = HotkeyHandler()
}
