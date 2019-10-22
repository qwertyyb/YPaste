//
//  MainWindowController.swift
//  YPaste
//
//  Created by 虚幻 on 2019/9/6.
//  Copyright © 2019 qwertyyb. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController, NSWindowDelegate {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        NotificationCenter.default.addObserver(self, selector: #selector(openWindow), name: HotkeyHandler.openFavoriteNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(openWindow), name: HotkeyHandler.openHistoryNotification, object: nil)
    }
    
    @objc func openWindow() {
        self.window?.setFrameTopLeftPoint(NSEvent.mouseLocation)
        self.window?.makeKeyAndOrderFront(self)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.level = NSWindow.Level.popUpMenu

        (self.contentViewController as! ViewController).arrayController.addObserver(self, forKeyPath: "arrangedObjects", options: [.new], context: nil)
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "arrangedObjects" {
            (self.contentViewController as! ViewController).arrayController.setSelectionIndex(0)
        }
        
    }

}
