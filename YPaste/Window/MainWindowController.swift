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
        PasteboardHandler.shared.application = NSWorkspace.shared.frontmostApplication
        self.window?.setFrameTopLeftPoint(NSEvent.mouseLocation)
        self.window?.makeKeyAndOrderFront(self)
        NSApp.activate(ignoringOtherApps: true)
        self.window?.level = NSWindow.Level.popUpMenu
        self.window?.title = HotkeyHandler.shared.openType == .favorite ? "YPaste - 收藏" : "YPaste - 历史"
    }

}
