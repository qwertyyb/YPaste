//
//  YPaste.swift
//  YPaste
//
//  Created by 虚幻 on 2019/9/6.
//  Copyright © 2019 qwertyyb. All rights reserved.
//

import Foundation
import HotKey

class YPaste {
    private var hotkey: HotKey?
    
    var handler: HotKey.Handler? {
        get { return self.hotkey?.keyDownHandler }
        set (handler) { self.hotkey?.keyDownHandler = handler }
    }
    
    func start() {
        registerHotKey()
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
        hotkey?.keyDownHandler = { NSApp.mainWindow?.setIsVisible(true) }
    }
}
