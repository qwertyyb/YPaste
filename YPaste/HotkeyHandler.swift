//
//  HotkeyHandler.swift
//  YPaste
//
//  Created by marchyang on 2019/10/22.
//  Copyright © 2019 qwertyyb. All rights reserved.
//

import Foundation
import HotKey

class HotkeyHandler {
    private var openHistoryHotkey: HotKey?
    
    init() {
        UserDefaults.standard.register(defaults: ["hotKey": "command+shift+v"])
    }
    
    static let openWindowNotification = Notification.Name("openWindowNotification")
    
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
        let hotKeyString = UserDefaults.standard.string(forKey: "hotKey")
        let keyCombo = getKeyComboFromString(hotKeyString!)
        openHistoryHotkey = HotKey(
            keyCombo: keyCombo,
            keyDownHandler: {
                NotificationCenter.default.post(name: HotkeyHandler.openWindowNotification, object: nil)
            },
            keyUpHandler: nil
        )
    }
    
    static let shared = HotkeyHandler()
}
