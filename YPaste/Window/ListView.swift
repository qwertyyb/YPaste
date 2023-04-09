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
    
    func mouseMoved(with event: NSEvent) -> NSEvent {
        let targetView = self.window?.contentView?.hitTest(event.locationInWindow)
        guard let view = targetView else { return event }
        if let itemView = getItemView(innerView: view) {
            ViewStore.shared.setSelectedIndex(itemView.index)
        }
        return event
    }
    
    override var acceptsFirstResponder: Bool {
        get { return true }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private var observers: [Any] = []
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        translatesAutoresizingMaskIntoConstraints = false
        spacing = 8
        edgeInsets = NSEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
        
        NSEvent.addLocalMonitorForEvents(matching: .mouseMoved, handler: self.mouseMoved(with:))
        
        updateListView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateListView), name: ViewStore.listChangedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateSelectedView), name: ViewStore.selectedChangedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadNextPage), name: MainView.reachBottomNotification, object: nil)
    }
    
    
    
    @objc
    func loadNextPage() {
        ViewStore.shared.nextPage()
    }
    
    @objc
    func updateListView() {
        let views = ViewStore.shared.list
            .enumerated()
            .map { (index, pasteItem) -> ListItemView in
                let itemView = ListItemView(
                    pasteItem: pasteItem,
                    itemIndex: index,
                    enableActions: true
                )
                if (index == ViewStore.shared.selectedIndex) {
                    itemView.active()
                }
                return itemView
            }
        setViews(views, in: .center)
    }
    
    @objc
    func updateSelectedView() {
        let selectedIndex = ViewStore.shared.selectedIndex
        let views = self.views(in: .center)
        
        scrollToVisible(views[selectedIndex].frame)
        views.forEach { (view) in
            (view as! ListItemView).deactive()
        }
        (views[selectedIndex] as? ListItemView)?.active()
        
        guard self.window != nil else { return }
        guard UserDefaults.standard.bool(forKey: "popover") else { return }
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { (timer) in
            guard views[selectedIndex].window != nil else { return }
        }
    }
    
    override func keyDown(with event: NSEvent) {
        switch Int(event.keyCode) {
        case kVK_Delete:
            ViewStore.shared.removeSelected()
            break;
            
        case kVK_Return:
            if let selected = ViewStore.shared.selected {
                PasteboardAction.shared.paste(pasteItem: selected)
                self.window?.windowController?.close()
            }
            break;
            
        case kVK_LeftArrow:
            if Config.shared.scrollDirection == .horizontal {
                ViewStore.shared.selectPrev()
            }
            break;
        
        case kVK_RightArrow:
            if Config.shared.scrollDirection == .horizontal {
                ViewStore.shared.selectNext()
            }
            break;

        case kVK_DownArrow:
            if Config.shared.scrollDirection == .vertical {
                ViewStore.shared.selectNext()
            }
            break;

        case kVK_UpArrow:
            if Config.shared.scrollDirection == .vertical {
                ViewStore.shared.selectPrev()
                if ViewStore.shared.selectedIndex == 0 {
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
