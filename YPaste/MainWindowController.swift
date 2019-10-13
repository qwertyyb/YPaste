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
        
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        appDelegate.app.hotKeyHandler = {
            self.window?.setFrameTopLeftPoint(NSEvent.mouseLocation)
            self.window?.makeKeyAndOrderFront(self)
            NSApp.activate(ignoringOtherApps: true)
            self.window?.delegate = self
        }
        print("init")
        appDelegate.app.onHistoryChange = {
            (self.contentViewController as! ViewController).arrayController.fetch(self)
        }
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.level = NSWindow.Level.popUpMenu

        (self.contentViewController as! ViewController).arrayController.addObserver(self, forKeyPath: "arrangedObjects", options: [.new], context: nil)
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "arrangedObjects" {
            print("select index 0")
            (self.contentViewController as! ViewController).arrayController.setSelectionIndex(0)
        }
        
    }

}
