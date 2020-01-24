//
//  ListView.swift
//  YPaste
//
//  Created by marchyang on 2020/1/20.
//  Copyright © 2020 qwertyyb. All rights reserved.
//

import Cocoa
import HotKey

class ListView: NSStackView {
    
    @objc var list: [PasteItem] = [] {
        didSet {
            update()
        }
    }
    @objc var selectionIndex: Int = 0 {
        didSet {
            print(oldValue, self.selectionIndex)
            if self.selectionIndex >= 100000 { return }
            let views = self.views(in: .leading)
            guard views.count > self.selectionIndex else { return }
            
            let selected = views[self.selectionIndex]
            scrollToVisible(selected.frame)
            views.forEach { (view) in
                (view as! ListItemView).deactive()
            }
            (selected as! ListItemView).active()
            
            guard self.window != nil else { return }
            guard UserDefaults.standard.bool(forKey: "popover") else { return }
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { (timer) in
                guard views[self.selectionIndex].window != nil else { return }
                Popover.shared.updateContent(pasteItem: self.list[self.selectionIndex])
                Popover.shared.show(relativeTo: .zero, of: views[self.selectionIndex], preferredEdge: .maxX)
            }
        }
    }
    
    
    override var isFlipped: Bool {
        get { return true }
    }
    
    override func mouseMoved(with event: NSEvent) {
        if HotkeyHandler.shared.openType == .order {
            return
        }
        var point = event.locationInWindow
        let bounds = self.enclosingScrollView?.contentView.bounds ?? self.bounds
        let originY = self.enclosingScrollView?.frame.origin.y ?? 100
        point.y = visibleRect.origin.y + bounds.height + originY - point.y
        var view = self.hitTest(point)
        if view?.className == "YPaste.ListItemView" {
        } else if view?.superview?.className == "YPaste.ListItemView"  {
            view = view?.superview
        } else {
            return
        }
        let itemView = view as! ListItemView
        PasteItemsController.shared.setSelectionIndex(itemView.index)
    }
    
    private var trackingArea: NSTrackingArea?
    override func updateTrackingAreas() {
        super.updateTrackingAreas()

        if let trackingArea = self.trackingArea {
            self.removeTrackingArea(trackingArea)
        }

        let options: NSTrackingArea.Options = [.mouseMoved, .activeAlways]
        let trackingArea = NSTrackingArea(rect: self.enclosingScrollView?.contentView.bounds ?? self.bounds, options: options, owner: self, userInfo: nil)
        self.addTrackingArea(trackingArea)
    }
    
    override var acceptsFirstResponder: Bool {
        get { return true }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        orientation = .vertical
        alignment = .leading
        spacing = 8
        
        translatesAutoresizingMaskIntoConstraints = false
        
        bind(.init("list"), to: PasteItemsController.shared, withKeyPath: "arrangedObjects", options: nil)
        bind(.init("selectionIndex"), to: PasteItemsController.shared, withKeyPath: "selectionIndex", options: nil)
    }
    
    func update() {
        print(selectionIndex)
        var index = 0
        let views = (PasteItemsController.shared.arrangedObjects as! [PasteItem]).map({ (pasteItem) -> ListItemView in
            let itemView = ListItemView(pasteItem: pasteItem,
                                        itemIndex: index,
                                        enableActions: HotkeyHandler.shared.openType != .order)
            if (index == selectionIndex) {
                itemView.active()
            }
        
            index += 1
            return itemView
        })
        setViews(views, in: .leading)
    }
    
    
    override func keyDown(with event: NSEvent) {
        if event.keyCode == Key.downArrow.carbonKeyCode {
            PasteItemsController.shared.selectNext(self)
        } else if event.keyCode == Key.upArrow.carbonKeyCode {
            PasteItemsController.shared.selectPrevious(self)
            if PasteItemsController.shared.selectionIndex == 0 {
                self.window?.makeFirstResponder(self.superview?.superview?.previousKeyView)
            }
        } else if event.keyCode == Key.delete.carbonKeyCode {
            PasteItemsController.shared.remove(self)
        } else if event.keyCode == Key.return.carbonKeyCode {
            PasteboardHandler.shared.paste(pasteItem: list[self.selectionIndex])
            self.window?.windowController?.close()
        }
    }
}
