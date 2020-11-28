//
//  MainWindowController.swift
//  YPaste
//
//  Created by 虚幻 on 2019/9/6.
//  Copyright © 2019 qwertyyb. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
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
        win.setFrame(
            NSRect(origin: Config.shared.windowOrigin, size: Config.shared.windowSize),
            display: true
        )
        
        // shouldnt activate this app, will cause current active app blur, then cant paste
//            NSApp.activate(ignoringOtherApps: true)
        win.makeKeyAndOrderFront(nil)
        
        (window?.contentViewController as! MainViewController).slideOut()
    }
    
    override func close() {
        if let viewController = window?.contentViewController as? MainViewController {
            viewController.slideIn(callback: super.close)
        }
    }
    
}
