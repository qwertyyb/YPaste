//
//  MainWindow.swift
//  YPaste
//
//  Created by marchyang on 2019/11/1.
//  Copyright © 2019 qwertyyb. All rights reserved.
//

import Cocoa
import HotKey
import SwiftUI
import Carbon

class MainWindow: NSPanel {
    override var canBecomeKey: Bool {
        get { return true }
    }
    
//    var hostingView: NSHostingView<PasteListView>
    
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        let key = Key(carbonKeyCode: UInt32(event.keyCode))
        if [Key.upArrow, Key.downArrow].contains(key) {
            return false
        }
        return true
    }

    
    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        
        let hostingView = NSHostingView(
            rootView: PasteListView()
                    .environment(\.managedObjectContext, (NSApp.delegate as! AppDelegate).persistentContainer.viewContext)
        )
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        
        self.styleMask = .init(arrayLiteral: .fullSizeContentView, .borderless)
//        contentViewController = MainViewController()
        contentView = hostingView
        isFloatingPanel = true
    }
    
    override func keyDown(with event: NSEvent) {
        print(event)
        if (event.keyCode == kVK_DownArrow) {
            print("arrow-down")
            (self.contentView as! NSHostingView<PasteListView>).rootView.selectNext()
//            (hostingView.rootView as! PasteListView).selectNext()
        }
        if (event.keyCode == kVK_UpArrow) {
            print("arrow-up")
//            (hostingView.rootView as! PasteListView).selectPrev()
        }
    }
}
