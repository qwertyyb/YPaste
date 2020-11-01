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
import Combine

class MainWindow: NSPanel {
    
//    private let publisher = PassthroughSubject<NSEvent, Never>() // private

//    var keyEventPublisher: AnyPublisher<NSEvent, Never> { // public
//        publisher.eraseToAnyPublisher()
//    }
    
    override var canBecomeKey: Bool {
        get { return true }
    }
    
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        let key = Key(carbonKeyCode: UInt32(event.keyCode))
        if [Key.upArrow, Key.downArrow].contains(key) {
            return false
        }
        return true
    }

    
    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        
        self.styleMask = .init(arrayLiteral: .fullSizeContentView, .borderless)
//        contentViewController = MainViewController()
        let hostingView = NSHostingView(
            rootView: PasteListView()
                .environment(\.managedObjectContext, (NSApp.delegate as! AppDelegate).persistentContainer.viewContext)
                .environment(\.keyPublisher, GlobalPublisher.shared.keyEventPublisher)
//                .environmentObject(Store.shared)
        )
        contentView = hostingView
        isFloatingPanel = true
    }
    
    override func keyDown(with event: NSEvent) {
        print("window key:")
//        keyEventPubliser.send(<#T##input: NSEvent##NSEvent#>)
    }
}
