//
//  MainWindowController.swift
//  YPaste
//
//  Created by 虚幻 on 2019/9/6.
//  Copyright © 2019 qwertyyb. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.level = NSWindow.Level.popUpMenu
        
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        appDelegate.app.handler = {
            self.window?.setFrameTopLeftPoint(NSEvent.mouseLocation)
            self.window?.makeKeyAndOrderFront(self)
            NSApp.activate(ignoringOtherApps: true)
        }
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }

}
