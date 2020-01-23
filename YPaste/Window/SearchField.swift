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
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    override func keyUp(with event: NSEvent) {
        if event.keyCode == Key.downArrow.carbonKeyCode {            self.window?.makeFirstResponder(self.nextKeyView)
        }
    }
}
