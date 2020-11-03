//
//  MainWindowController.swift
//  YPaste
//
//  Created by 虚幻 on 2019/9/6.
//  Copyright © 2019 qwertyyb. All rights reserved.
//

import Cocoa
import HotKey

class MainWindowController: NSWindowController {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        NotificationCenter.default.addObserver(self, selector: #selector(openWindow), name: HotkeyHandler.openWindowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(close), name: PasteboardHandler.pastedNotification, object: nil)
    }
    override init(window: NSWindow?) {
        super.init(window: window)
        
        NotificationCenter.default.addObserver(self, selector: #selector(openWindow), name: HotkeyHandler.openWindowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(close), name: PasteboardHandler.pastedNotification, object: nil)

        NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDown) { (event) in
            if self.window == nil { return }
            let location = NSEvent.mouseLocation
            if !self.window!.frame.contains(location) {
                self.close()
            }
        }
        
        openWindow()
    }


    @objc func openWindow() {
        guard let win = self.window else { return }
        if win.isVisible {
            self.close()
        }

        let x = NSScreen.main?.frame.minX ?? 0
        let y = NSScreen.main?.frame.minY ?? 0
        let menuBarHeight = NSMenu.menuBarVisible() ? NSApplication.shared.mainMenu?.menuBarHeight ?? 24 : 0
        let height = (NSScreen.main?.frame.height ?? NSScreen.screens.first!.frame.height) - menuBarHeight
        win.setFrame(NSMakeRect(x, y, 360, height), display: true)
        
        // shouldnt activate this app, will cause current active app blur, then cant paste
//            NSApp.activate(ignoringOtherApps: true)
        win.makeKeyAndOrderFront(nil)
        
        (window?.contentViewController as! MainViewController).slideOut()
    }
    
    override func close() {
        if let viewController = window?.contentViewController as? MainViewController {
            viewController.slideIn(callback: super.close)
        }
        Popover.shared.clear()
        Popover.shared.close()
    }
    
}
