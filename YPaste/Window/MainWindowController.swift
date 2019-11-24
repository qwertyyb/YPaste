//
//  MainWindowController.swift
//  YPaste
//
//  Created by 虚幻 on 2019/9/6.
//  Copyright © 2019 qwertyyb. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController, NSWindowDelegate {
    
    var clickOutCloseWindowMonitor: Any?
    
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        return true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        NotificationCenter.default.addObserver(self, selector: #selector(openWindow), name: HotkeyHandler.openFavoriteNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(openWindow), name: HotkeyHandler.openHistoryNotification, object: nil)
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
        self.window?.setFrameTopLeftPoint(NSEvent.mouseLocation)
        self.window?.makeKeyAndOrderFront(self)
        self.window?.level = NSWindow.Level.popUpMenu
        self.window?.title = HotkeyHandler.shared.openType == .favorite ? "YPaste - 收藏" : "YPaste - 历史"
        
        clearMonitor()
        clickOutCloseWindowMonitor = NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDown) { (event) in
            if self.window == nil { return }
            let location = NSEvent.mouseLocation
            if !self.window!.frame.contains(location) {
                self.close()
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
