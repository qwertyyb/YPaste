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
    }
    
    static let reachBottomNotification = Notification.Name("reachBottomNotification")
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        contentView.postsBoundsChangedNotifications = true
        NotificationCenter.default.addObserver(self, selector: #selector(contentViewDidChangeBounds), name: NSView.boundsDidChangeNotification, object: nil)
    }
    
    @objc private func contentViewDidChangeBounds(_ notification: Notification) {
        guard let documentView = self.documentView else { return }

        let clipView = self.contentView
        if clipView.bounds.origin.y + clipView.bounds.height == documentView.bounds.height {
            let notification = Notification(name: ScrollView.reachBottomNotification, object: nil)
            NotificationCenter.default.post(notification)

        }
    }
    
}
