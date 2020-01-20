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
    let popover = Popover()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.delegate = self

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "fetchPredicateChanged"), object: nil, queue: nil) { (notification) in
            self.scrollRowToVisible(0)
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "SearchField-KeyUp"), object: nil, queue: nil) { (notification) in
            if notification.userInfo!["keyCode"] as! UInt16 == Key.downArrow.carbonKeyCode {
                self.window?.makeFirstResponder(self)
            }
        }
        NotificationCenter.default.addObserver(forName: NSWindow.willCloseNotification, object: nil, queue: nil) { (notification) in
            self.popover.clear()
            self.popover.close()
        }
        
//        self.window?.makeFirstResponder(self)
        NSEvent.addLocalMonitorForEvents(matching: NSEvent.EventTypeMask.init(arrayLiteral: .mouseMoved, NSEvent.EventTypeMask.scrollWheel)) { (event) -> NSEvent? in
            return self.selectItemAtMouseLocation(with: event)
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
//        super.mouseDown(with: event)
        let _ = self.selectItemAtMouseLocation(with: event)
        pasteSelected()
    }
    
    @IBOutlet var arrayController: PasteItemsController!
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if self.window == nil || !UserDefaults.standard.bool(forKey: "popover") { return }
        let objects = self.arrayController.arrangedObjects as! [PasteItem]
        if let selectedRow = self.rowView(atRow: self.selectedRow, makeIfNecessary: false), objects.count > self.selectedRow {
            let selectedPasteItem = objects[self.selectedRow]
            /* 在到达可视区域的底部后，继续使用按向下方向键，会出现选中行尚未可见，但本方法已被调用的情况
               根据文档，NSPopover.show当目标视图不可见时，该方法不会产生任何行为，所以导致位置不能及时得到更新
               为了解决如上情况，延迟执行show方法
             */
            Timer.scheduledTimer(withTimeInterval: 0.01, repeats: false) { (timer) in
                self.popover.updateContent(pasteItem: selectedPasteItem)
                self.popover.show(relativeTo: self.frame, of: selectedRow, preferredEdge: .maxX)
            }
        }
    }
    
    override func keyUp(with event: NSEvent) {
        let key = Key(carbonKeyCode: UInt32(event.keyCode))
        if key == Key.return {
            pasteSelected()
        }
    }
    
    func selectItemAtMouseLocation(with event: NSEvent) -> NSEvent {
//      print(event)
        var location = event.locationInWindow
        var visibleRect = self.visibleRect
        let originY = visibleRect.origin.y
        visibleRect.origin.y = 0
        guard visibleRect.contains(location) else { return event }
        location.y = self.frame.height - (visibleRect.height - location.y) - originY
        let row = self.row(at: location)
        if row == -1 {return event }
        self.window?.makeFirstResponder(self)
        self.selectRowIndexes(IndexSet.init(arrayLiteral: self.numberOfRows - row - 1), byExtendingSelection: false)
        return event
    }
    
    @objc func pasteSelected () {
        let pasteItems = self.arrayController.selectedObjects as? [PasteItem]
        if (pasteItems?.first == nil) { return }
        PasteboardHandler.shared.paste(pasteItem: (pasteItems?.first)!)
        NotificationCenter.default.post(name: PasteboardHandler.pastedNotification, object: nil)
    }
}
