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
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "TableView-ReachTop"), object: nil, queue: nil) { (notification) in
            self.window?.makeFirstResponder(self)
        }
//        self.setFrameOrigin(NSMakePoint(self.frame.origin.x, self.frame.origin.y - 10))
//        self.setFrameSize(NSMakeSize(self.frame.width, self.frame.height + 8))
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    override func keyUp(with event: NSEvent) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SearchField-KeyUp"), object: nil, userInfo: ["keyCode": event.keyCode])
        super.keyDown(with: event)
    }
}
