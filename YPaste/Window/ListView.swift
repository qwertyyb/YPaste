//
//  ListView.swift
//  YPaste
//
//  Created by marchyang on 2020/1/20.
//  Copyright © 2020 qwertyyb. All rights reserved.
//

import Cocoa
import Carbon

class ListView: NSStackView {
    
    static let reachTopNotification = NSNotification.Name("listview:reachtop")
    
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
            }
        }
    }
    
    
    override var isFlipped: Bool {
        get { return true }
    }
    
    func getItemView(innerView: NSView) -> ListItemView? {
        var curView: NSView? = innerView
        while (curView != nil && curView?.className != "YPaste.ListItemView") {
            curView = curView?.superview
        }
        return curView as? ListItemView
    }
    
    override func mouseMoved(with event: NSEvent) {
        let targetView = self.window?.contentView?.hitTest(event.locationInWindow)
        guard let view = targetView else { return }
        if let itemView = getItemView(innerView: view) {
            PasteItemsController.shared.setSelectionIndex(itemView.index)
        }
    }
    
    override var acceptsFirstResponder: Bool {
        get { return true }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override var spacing: CGFloat {
        get { 8 }
        set { }
    }
    
    override var edgeInsets: NSEdgeInsets {
        get { NSEdgeInsets(top: 8, left: 0, bottom: 0, right: 0) }
        set { }
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        orientation = Config.shared.scrollDirection
        alignment = orientation == .horizontal ? .centerY : .centerX
        translatesAutoresizingMaskIntoConstraints = false
        
        NSEvent.addGlobalMonitorForEvents(matching: .mouseMoved, handler: self.mouseMoved(with:))
        
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
        case kVK_Delete:
            controller.remove(self)
            break;
            
        case kVK_Return:
            PasteboardHandler.shared.paste(pasteItem: list[self.selectionIndex])
            self.window?.windowController?.close()
            
        case kVK_LeftArrow:
            if Config.shared.scrollDirection == .horizontal {
                controller.selectPrevious(self)
            }
            break;
        
        case kVK_RightArrow:
            if Config.shared.scrollDirection == .horizontal {
                controller.selectNext(self)
            }
            break;

        case kVK_DownArrow:
            if Config.shared.scrollDirection == .vertical {
                controller.selectNext(self)
            }
            break;

        case kVK_UpArrow:
            if Config.shared.scrollDirection == .vertical {
                controller.selectPrevious(self)
                if controller.selectionIndex == 0 {
                    NotificationCenter.default.post(
                        name: ListView.reachTopNotification,
                        object: self
                    )
                }
            } else {
                NotificationCenter.default.post(
                    name: ListView.reachTopNotification,
                    object: self
                )
            }
            break;

        default:
            print("default")
        }
    }
}
