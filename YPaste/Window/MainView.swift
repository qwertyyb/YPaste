//
//  MainView.swift
//  YPaste
//
//  Created by marchyang on 2020/1/20.
//  Copyright © 2020 qwertyyb. All rights reserved.
//

import Cocoa
import Carbon

class MainView: NSStackView {
    
    static let reachBottomNotification = Notification.Name("reachBottomNotification")
    
    let searchField = SearchField(string: "")
    let scrollView = NSScrollView()
    let footerView = NSTextField(string: "YPaste")
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        orientation = .vertical
        edgeInsets = NSEdgeInsets.init(top: 12, left: 6, bottom: 12, right: 6)
        translatesAutoresizingMaskIntoConstraints = false
        alignment = .left
        wantsLayer = true
        spacing = 0
        layer?.backgroundColor = .clear
        
        addView(searchField, in: .top)
        NSLayoutConstraint.activate([
            searchField.leftAnchor.constraint(equalTo: leftAnchor, constant: 18),
            searchField.rightAnchor.constraint(equalTo: rightAnchor, constant: -18)
        ])
        
        let title = NSTextView()
        title.string = "历史记录"
        title.font = .boldSystemFont(ofSize: 20)
        title.backgroundColor = .clear
        title.isEditable = false
        
        let clear = NSButton(
            image: NSImage(named: "NSStopProgressFreestandingTemplate")!,
            target: PasteboardHandler.shared,
            action: #selector(PasteboardHandler.shared.clearHistory)
        )
        clear.isBordered = false
        
        let titleView = NSStackView()
        titleView.orientation = .horizontal
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addView(title, in: .leading)
        titleView.addView(clear, in: .trailing)

        addView(titleView, in: .center)
        NSLayoutConstraint.activate([
            titleView.leftAnchor.constraint(equalTo: leftAnchor, constant: 18),
            titleView.rightAnchor.constraint(equalTo: rightAnchor, constant: -18),
            titleView.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 12),
            titleView.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.hasVerticalScroller = false
        scrollView.drawsBackground = false
        scrollView.verticalScroller?.controlSize = .mini
        scrollView.verticalScroller = nil
        // 到底时，加载下一页
        scrollView.contentView.postsBoundsChangedNotifications = true
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(scrollViewBoundsHandler),
            name: NSView.boundsDidChangeNotification,
            object: nil
        )

        scrollView.documentView = ListView()
        
        scrollView.contentView.automaticallyAdjustsContentInsets = false
        scrollView.contentView.translatesAutoresizingMaskIntoConstraints = false
        addView(scrollView, in: .center)
        
        NSLayoutConstraint.activate([
            scrollView.centerXAnchor.constraint(equalTo: centerXAnchor),
            scrollView.topAnchor.constraint(equalTo: titleView.bottomAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -40),
            scrollView.widthAnchor.constraint(equalTo: widthAnchor),
            scrollView.contentView.widthAnchor.constraint(equalTo: widthAnchor),
            scrollView.documentView!.widthAnchor.constraint(equalTo: widthAnchor),
        ])
        
        footerView.alignment = .center
        footerView.backgroundColor = .clear
        footerView.isBordered = false
        footerView.alphaValue = 0.3
        addView(footerView, in: .bottom)
        
        searchField.bind(
            .predicate,
            to: PasteItemsController.shared,
            withKeyPath: "fetchPredicate",
            options: [NSBindingOption.predicateFormat: "self.value contains[cd] $value"]
        )
        
        NotificationCenter.default.addObserver(
            forName: PasteItemsController.totalChange,
            object: nil,
            queue: nil) { (notification) in
                self.updateCount()
        }
    }
    
    func removeSearchView () {
        setViews([], in: .top)
    }
    func addSearchView () {
        setViews([searchField], in: .top)
    }
    
    func updateFooter (string: String = "") {
        footerView.stringValue = string
    }
    
    func updateCount () {
        let str = "共有\(String(PasteItemsController.shared.total))条历史"
        footerView.stringValue = str
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func update() {
        (scrollView.documentView as! ListView).update()
    }
    
    override func keyDown(with event: NSEvent) {
        if event.keyCode == kVK_UpArrow {
            self.window?.makeFirstResponder(searchField)
        }
    }
    
    @objc private func scrollViewBoundsHandler(_ notification: Notification) {
        guard let documentView = scrollView.documentView else { return }

        let clipView = scrollView.contentView
        let bottomDistance = documentView.bounds.height - (clipView.bounds.origin.y + clipView.bounds.height)
        if bottomDistance == 0 {
            let notification = Notification(
                name: MainView.reachBottomNotification,
                object: nil)
            NotificationCenter.default.post(notification)

        }
    }
}
