//
//  MainWindow.swift
//  YPaste
//
//  Created by marchyang on 2019/11/1.
//  Copyright © 2019 qwertyyb. All rights reserved.
//

import Cocoa
import HotKey

class MainWindow: NSWindow {
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
    
    private var monitor: Any? = nil
    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        
        self.styleMask = .init(arrayLiteral: .fullSizeContentView, .borderless)
        contentViewController = MainViewController()
        isOpaque = false
        backgroundColor = .clear
        level = .popUpMenu
        isReleasedWhenClosed = false
        hidesOnDeactivate = false
    }
    
    override func makeKeyAndOrderFront(_ sender: Any?) {
        super.makeKeyAndOrderFront(sender)
        
        (contentViewController as? MainViewController)?.slideOut()
        
        monitor = NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDown) { (event) in
            let location = NSEvent.mouseLocation
            if !self.frame.contains(location) {
                self.close()
            }
        }
    }
    
    override func close() {
        if let viewController = contentViewController as? MainViewController {
            viewController.slideIn(callback: {
                if let monitor = self.monitor {
                    NSEvent.removeMonitor(monitor)
                    self.monitor = nil
                }
                super.close()
            })
        }
    }
}
