//
//  MainView.swift
//  YPaste
//
//  Created by marchyang on 2020/1/20.
//  Copyright © 2020 qwertyyb. All rights reserved.
//

import Cocoa
import Carbon

class MainView: NSVisualEffectView {
    
    static let reachBottomNotification = Notification.Name("reachBottomNotification")
    
    let searchField = SearchField(string: "")
    let scrollView = NSScrollView()
    let titleView = NSStackView()
    let footerView = NSTextField(string: "YPaste")
    
    private var observers: [NSObjectProtocol] = []
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
        layer?.backgroundColor = .clear
        
        addSearchView()

        addTitleView()

        addScrollView()

        addFooterView()
        
        searchField.bind(
            .predicate,
            to: PasteItemsController.shared,
            withKeyPath: "fetchPredicate",
            options: [NSBindingOption.predicateFormat: "self.value contains[cd] $value"]
        )

        let observer = NotificationCenter.default.addObserver(
            forName: PasteItemsController.totalChange,
            object: nil,
            queue: nil) { (notification) in
                self.updateCount()
        }
        observers.append(observer)

        observers.append(NotificationCenter.default.addObserver(
            forName: ListView.reachTopNotification,
            object: nil,
            queue: nil) { (notification) in
            print(notification)
            self.window?.makeFirstResponder(self.searchField)
        })

        observers.append(NotificationCenter.default.addObserver(
            forName: SearchField.arrowDownKeyDownNotification,
            object: nil,
            queue: nil) { (notification) in
            self.window?.makeFirstResponder(self.scrollView)
            PasteItemsController.shared.setSelectionIndex(0)
        })
    }

    func addSearchView () {
        searchField.translatesAutoresizingMaskIntoConstraints = false
        searchField.centersPlaceholder = true
        addSubview(searchField)
        NSLayoutConstraint.activate([
            searchField.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            searchField.centerXAnchor.constraint(equalTo: centerXAnchor),
            searchField.widthAnchor.constraint(greaterThanOrEqualToConstant: 320),
            searchField.heightAnchor.constraint(greaterThanOrEqualToConstant: 24),
        ])
    }
    
    func addTitleView () {
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

        titleView.orientation = .horizontal
        titleView.addView(title, in: .leading)
        titleView.addView(clear, in: .trailing)
        titleView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(titleView)
        NSLayoutConstraint.activate([
            titleView.leftAnchor.constraint(equalTo: leftAnchor, constant: 18),
            titleView.rightAnchor.constraint(equalTo: rightAnchor, constant: -18),
            titleView.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 12),
            titleView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    func addScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.hasVerticalScroller = false
        scrollView.drawsBackground = false
        scrollView.verticalScroller = nil
        scrollView.documentView = ListView()
        // 到底时，加载下一页
        scrollView.contentView.postsBoundsChangedNotifications = true
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(scrollViewBoundsHandler),
            name: NSView.boundsDidChangeNotification,
            object: nil
        )
        scrollView.contentView.automaticallyAdjustsContentInsets = false
        scrollView.contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.contentView.contentInsets = NSEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.centerXAnchor.constraint(equalTo: centerXAnchor),
            scrollView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 6),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -28),
            scrollView.widthAnchor.constraint(equalTo: widthAnchor, constant: -24),
            scrollView.contentView.widthAnchor.constraint(equalTo: widthAnchor, constant: -24),
            scrollView.contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
        ])
    }
    
    func addFooterView() {
        footerView.alignment = .center
        footerView.backgroundColor = .clear
        footerView.isBordered = false
        footerView.alphaValue = 0.3
        footerView.isEditable = false
        footerView.font = .labelFont(ofSize: 12)
        addSubview(footerView)
        footerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            footerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            footerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6)
        ])
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
    
    @objc private func scrollViewBoundsHandler(_ notification: Notification) {
        guard let documentBounds = scrollView.documentView?.frame else { return }
        let insets = scrollView.contentView.contentInsets
        
        let clipBounds = scrollView.contentView.bounds
        
        let bottomDistance = Config.shared.scrollDirection == .vertical
                ? documentBounds.height - (clipBounds.origin.y + clipBounds.height) + insets.bottom
                : documentBounds.width - (clipBounds.origin.x + clipBounds.width) + insets.right
        if bottomDistance != 0 { return }

        let notification = Notification(
            name: MainView.reachBottomNotification,
            object: nil)
        NotificationCenter.default.post(notification)
    }
}
