//
//  SearchField.swift
//  YPaste
//
//  Created by marchyang on 2019/10/22.
//  Copyright © 2019 qwertyyb. All rights reserved.
//

import Cocoa
import HotKey

class SearchField: NSSearchField {
    
    override var focusRingType: NSFocusRingType {
        get { .none }
        set {}
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.borderColor = NSColor(red:204.0/255.0, green:204.0/255.0, blue:204.0/255.0, alpha:1.0).cgColor
        layer?.borderWidth = 1.0
        layer?.cornerRadius = 10
    }
    
    override func keyUp(with event: NSEvent) {
        if event.keyCode == Key.downArrow.carbonKeyCode {
            self.window?.makeFirstResponder(nextValidKeyView?.nextValidKeyView?.nextValidKeyView)
        }
    }
}
