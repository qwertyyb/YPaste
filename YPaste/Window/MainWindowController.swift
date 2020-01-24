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
    
    private var monitors: [Any?] = []
    
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        return true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        NotificationCenter.default.addObserver(self, selector: #selector(openWindow), name: HotkeyHandler.openWindowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(close), name: PasteboardHandler.pastedNotification, object: nil)
        
        clearMonitor()
        monitors.append(NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDown) { (event) in
            if self.window == nil { return }
            let location = NSEvent.mouseLocation
            if !self.window!.frame.contains(location) {
                self.close()
            }
        })
    }
    override init(window: NSWindow?) {
        super.init(window: window)
        
        guard let win = self.window else { return }
        win.title = "YPaste"
        win.isOpaque = true
        win.level = NSWindow.Level.popUpMenu
        win.isReleasedWhenClosed = false
        win.hidesOnDeactivate = false
        
        openWindow()
        
        NotificationCenter.default.addObserver(self, selector: #selector(openWindow), name: HotkeyHandler.openWindowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(close), name: PasteboardHandler.pastedNotification, object: nil)
        
        clearMonitor()
        monitors.append(NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDown) { (event) in
            if self.window == nil { return }
            let location = NSEvent.mouseLocation
            if !self.window!.frame.contains(location) {
                self.close()
            }
        })
    }
    
    
    
    @objc func openWindow() {
        guard let win = self.window else { return }
        if win.isVisible {
            self.close()
        }
        win.ignoresMouseEvents = HotkeyHandler.shared.openType == .order
        clearMonitor()
        
        let x = NSScreen.main?.frame.minX ?? 0
        let y = NSScreen.main?.frame.minY ?? 0
        let menuBarHeight = NSMenu.menuBarVisible() ? NSApplication.shared.mainMenu?.menuBarHeight ?? 24 : 0
        let height = (NSScreen.main?.frame.height ?? NSScreen.screens.first!.frame.height) - menuBarHeight
        win.setFrame(NSMakeRect(0, 0, 400, 1080), display: true)
        
        if (HotkeyHandler.shared.openType != .order) {
            win.makeKeyAndOrderFront(nil)
            win.isOpaque = true
            win.backgroundColor = .init(red: 0.88, green: 0.88, blue: 0.88, alpha: 1)
            
            var event = NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDown) { (event) in
                if self.window == nil { return }
                let location = NSEvent.mouseLocation
                if !self.window!.frame.contains(location) {
                    self.close()
                }
            }
            monitors.append(event)
            event = NSEvent.addGlobalMonitorForEvents(matching: .mouseMoved) { (event) in
                guard self.window != nil else { return }
                let location = NSEvent.mouseLocation
                if !self.window!.frame.contains(location) {
                    Popover.shared.clear()
                    Popover.shared.close()
                }
            }
            monitors.append(event)
            
        } else {
            win.orderFrontRegardless()
            win.isOpaque = false
            win.backgroundColor = .init(white: 0, alpha: 0.2)
        }
        let anim = NSViewAnimation(duration: 0.25, animationCurve: .easeOut)
        anim.viewAnimations = [
            [
                NSViewAnimation.Key.target: win,
                NSViewAnimation.Key.startFrame: NSMakeRect(x - 200, y, 400, height),
                NSViewAnimation.Key.endFrame: NSMakeRect(x, y, 400, height)
            ]
        ]
        anim.start()
    }
    
    func windowWillClose(_ notification: Notification) {
        clearMonitor()
    }
    
    func clearMonitor() {
        monitors.forEach { (monitor) in
            NSEvent.removeMonitor(monitor as Any)
        }
        monitors = []
    }
    
    override func close() {
        if let win = self.window {
            let anim = NSViewAnimation(duration: 0.16, animationCurve: .easeIn)
            anim.viewAnimations = [
                [
                    NSViewAnimation.Key.target: win,
                    NSViewAnimation.Key.startFrame: NSMakeRect(win.frame.minX, win.frame.minY, win.frame.width, win.frame.height),
                    NSViewAnimation.Key.endFrame: NSMakeRect(win.frame.minX - win.frame.width / 2, win.frame.minY, win.frame.width, win.frame.height)
                ]
            ]
            anim.start()
            super.close()
        }
        Popover.shared.clear()
        Popover.shared.close()
    }
    
}
