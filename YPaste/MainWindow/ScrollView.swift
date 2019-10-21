//
//  ScrollView.swift
//  YPaste
//
//  Created by marchyang on 2019/10/21.
//  Copyright © 2019 qwertyyb. All rights reserved.
//

import Cocoa

class ScrollView: NSScrollView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    override func scrollWheel(with event: NSEvent) {
        super.scrollWheel(with: event)
        guard let documentView = self.documentView, let scroller = self.verticalScroller,
            event.scrollingDeltaY < 0
        else { return }
        let scrollDistance = CGFloat(scroller.doubleValue) * documentView.frame.height
        if (documentView.frame.height - scrollDistance < 100) {
            let notification = Notification(name: Notification.Name(rawValue: "scrollerview-ToReachBottom"), object: nil)
            NotificationCenter.default.post(notification)
        }
    }
    
    
    
}
