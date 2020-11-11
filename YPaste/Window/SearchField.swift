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
    
    static let arrowDownKeyDownNotification = NSNotification.Name("searchField:arrow-down-key-down")
    
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
        layer?.borderColor = .clear
        layer?.borderWidth = 0
        layer?.cornerRadius = 10
    }
    
    override func keyUp(with event: NSEvent) {
        if event.keyCode == Key.downArrow.carbonKeyCode {
            NotificationCenter.default.post(name: SearchField.arrowDownKeyDownNotification, object: self)
        }
    }
}
