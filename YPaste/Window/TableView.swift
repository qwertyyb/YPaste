//
//  TableView.swift
//  YPaste
//
//  Created by marchyang on 2019/10/22.
//  Copyright © 2019 qwertyyb. All rights reserved.
//

import Cocoa
import HotKey


class TableView: NSTableView, NSTableViewDelegate {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "SearchField-KeyUp"), object: nil, queue: nil) { (notification) in
            if notification.userInfo!["keyCode"] as! UInt16 == Key.downArrow.carbonKeyCode {
                self.window?.makeFirstResponder(self)
            }
        }
        NSEvent.addLocalMonitorForEvents(matching: NSEvent.EventTypeMask.mouseMoved) { (event) -> NSEvent? in
            var location = event.locationInWindow
            var visibleRect = self.visibleRect
            let originY = visibleRect.origin.y
            visibleRect.origin.y = 0
            guard visibleRect.contains(location) else { return event }
            location.y = self.frame.height - (visibleRect.height - location.y) - originY
            let row = self.row(at: location)
            if row == -1 {
                return event
            }
            self.window?.makeFirstResponder(self)
            self.selectRowIndexes(IndexSet.init(arrayLiteral: self.numberOfRows - row - 1), byExtendingSelection: false)
            return event
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    static let rowRemovedNotification = Notification.Name("rowRemovedNotification")
    override func keyDown(with event: NSEvent) {
        if self.selectedRow == 0 && event.keyCode == Key.upArrow.carbonKeyCode {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "TableView-ReachTop"), object: nil, userInfo: nil)
        } else if event.keyCode == Key.delete.carbonKeyCode {
            NotificationCenter.default.post(name: TableView.rowRemovedNotification, object: nil)
        }
        super.keyDown(with: event)
    }
    
    @objc override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
    }
    
}
