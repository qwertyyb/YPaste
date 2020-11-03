//
//  ListView.swift
//  YPaste
//
//  Created by marchyang on 2020/1/20.
//  Copyright © 2020 qwertyyb. All rights reserved.
//

import Cocoa
import Carbon
import HotKey

class ListView: NSStackView {
    
    @objc var list: [PasteItem] = [] {
        didSet {
            update()
        }
    }
    @objc var selectionIndex: Int = 0 {
        didSet {
            if self.selectionIndex >= 100000 { return }
            let views = self.views(in: .center)
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
        alignment = .centerX
        spacing = 8
        edgeInsets = NSEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        bind(
            NSBindingName("list"),
            to: PasteItemsController.shared,
            withKeyPath: "arrangedObjects",
            options: nil
        )
        bind(
            NSBindingName("selectionIndex"),
            to: PasteItemsController.shared,
            withKeyPath: "selectionIndex",
            options: nil
        )
    }
    
    func update() {
        let views = (PasteItemsController.shared.arrangedObjects as! [PasteItem])
            .enumerated()
            .map { (index, pasteItem) -> ListItemView in
                let itemView = ListItemView(
                    pasteItem: pasteItem,
                    itemIndex: index,
                    enableActions: true
                )
                if (index == selectionIndex) {
                    itemView.active()
                }
                return itemView
            }
        setViews(views, in: .center)
    }
    
    
    override func keyDown(with event: NSEvent) {
        let controller = PasteItemsController.shared

        switch Int(event.keyCode) {
        case kVK_DownArrow:
            controller.selectNext(self)
            break;

        case kVK_UpArrow:
            controller.selectPrevious(self)
            if controller.selectionIndex == 0 {
                let pv = superview?.superview?.previousValidKeyView?.previousValidKeyView?.previousValidKeyView
                self.window?.makeFirstResponder(pv)
            }
            break;
            
        case kVK_Delete:
            controller.remove(self)
            break;
            
        case kVK_Return:
            PasteboardHandler.shared.paste(pasteItem: list[self.selectionIndex])
            self.window?.windowController?.close()

        default:
            print("default")
        }
    }
}
