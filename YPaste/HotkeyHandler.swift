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
}

class HotkeyHandler {
    private var openHistoryHotkey: HotKey?
    private var openFavoriteHotkey: HotKey?
    
    
    init() {
        UserDefaults.standard.register(defaults: ["hotKey": "command+shift+v"])
        UserDefaults.standard.register(defaults: ["favoriteHotKey": "command+shift+f"])
    }
    
    static let openHistoryNotification = Notification.Name("openHistoryNotification")
    static let openFavoriteNotification = Notification.Name("openFavoriteNotification")
    var openType = OpenType.history
    
    
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
            NotificationCenter.default.post(name: HotkeyHandler.openHistoryNotification, object: nil)
        }, keyUpHandler: nil)
        
        hotKeyString = UserDefaults.standard.string(forKey: "favoriteHotKey")
        keyCombo = getKeyComboFromString(hotKeyString!)
        openFavoriteHotkey = HotKey(keyCombo: keyCombo, keyDownHandler: {
            self.openType = .favorite
            NotificationCenter.default.post(name: HotkeyHandler.openFavoriteNotification, object: nil)
        }, keyUpHandler: nil)
    }
    
    static let shared = HotkeyHandler()
}
