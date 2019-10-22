//
//  ScrollView.swift
//  YPaste
//
//  Created by marchyang on 2019/10/21.
//  Copyright © 2019 qwertyyb. All rights reserved.
//

import Cocoa

class ScrollView: NSScrollView {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        contentView.postsBoundsChangedNotifications = true
        NotificationCenter.default.addObserver(self, selector: #selector(contentViewDidChangeBounds), name: NSView.boundsDidChangeNotification, object: nil)
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    @objc private func contentViewDidChangeBounds(_ notification: Notification) {
        guard let documentView = self.documentView else { return }

        let clipView = self.contentView
        if clipView.bounds.origin.y == 0 {
            print("top")
        } else if clipView.bounds.origin.y + clipView.bounds.height == documentView.bounds.height {
            let notification = Notification(name: Notification.Name(rawValue: "scrollerview-ToReachBottom"), object: nil)
            NotificationCenter.default.post(notification)

        }
    }
    
}
