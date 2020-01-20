//
//  MainWindowController.swift
//  YPaste
//
//  Created by 虚幻 on 2019/9/6.
//  Copyright © 2019 qwertyyb. All rights reserved.
//

import Cocoa
import HotKey

class MainWindowController: NSWindowController, NSWindowDelegate {
    
    private var clickOutCloseWindowMonitor: Any?
    
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        return true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        NotificationCenter.default.addObserver(self, selector: #selector(openWindow), name: HotkeyHandler.openWindowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(close), name: PasteboardHandler.pastedNotification, object: nil)
        
        clearMonitor()
        clickOutCloseWindowMonitor = NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDown) { (event) in
            if self.window == nil { return }
            let location = NSEvent.mouseLocation
            if !self.window!.frame.contains(location) {
                self.close()
            }
        }
    }
    
    
    
    @objc func openWindow() {
        if (HotkeyHandler.shared.openType != .order) {
            self.window?.setFrameTopLeftPoint(NSEvent.mouseLocation)
            self.window?.isOpaque = true
            self.window?.backgroundColor = NSColor.white
        } else {
            let x = NSScreen.main?.frame.minX ?? 0
            let y = NSScreen.main?.frame.maxY ?? 0
            self.window?.setFrameTopLeftPoint(NSMakePoint(x, y))
            self.window?.isOpaque = false
            self.window?.backgroundColor = NSColor.init(red: 1, green: 1, blue: 1, alpha: 0.4)
        }
        self.window?.makeKeyAndOrderFront(self)
        self.window?.ignoresMouseEvents = HotkeyHandler.shared.openType == .order
        self.window?.level = NSWindow.Level.popUpMenu
        self.window?.title = HotkeyHandler.shared.openType == .favorite ? "YPaste - 收藏" : "YPaste - 历史"
        clearMonitor()
        
        if (HotkeyHandler.shared.openType != .order) {
            clickOutCloseWindowMonitor = NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDown) { (event) in
                if self.window == nil { return }
                let location = NSEvent.mouseLocation
                if !self.window!.frame.contains(location) {
                    self.close()
                }
            }
        }
    }
    
    func windowWillClose(_ notification: Notification) {
        clearMonitor()
    }
    
    func clearMonitor() {
        if clickOutCloseWindowMonitor == nil { return }
        NSEvent.removeMonitor(clickOutCloseWindowMonitor!)
        clickOutCloseWindowMonitor = nil
    }
    
}
