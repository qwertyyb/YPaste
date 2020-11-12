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
        if [Key.upArrow, Key.downArrow, Key.leftArrow, Key.rightArrow].contains(key) {
            return false
        }
        return true
    }
    
    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        
        self.styleMask = .init(arrayLiteral: .fullSizeContentView, .nonactivatingPanel, .borderless)
        contentViewController = MainViewController()
        isOpaque = false
        backgroundColor = .clear
        level = .popUpMenu
//        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
//        isFloatingPanel = true
        isReleasedWhenClosed = false
        hidesOnDeactivate = false
    }
}
