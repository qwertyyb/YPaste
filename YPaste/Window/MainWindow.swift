//
//  MainWindow.swift
//  YPaste
//
//  Created by marchyang on 2019/11/1.
//  Copyright © 2019 qwertyyb. All rights reserved.
//

import Cocoa
import HotKey

class MainWindow: NSPanel {
    override var canBecomeKey: Bool {
        get { return true }
    }
    
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        let key = Key(carbonKeyCode: UInt32(event.keyCode))
        if [Key.upArrow, Key.downArrow].contains(key) {
            return false
        }
        return true
    }
}
