//
//  MainView.swift
//  YPaste
//
//  Created by marchyang on 2020/1/20.
//  Copyright © 2020 qwertyyb. All rights reserved.
//

import Cocoa

class MainView: NSStackView {
    
    let searchField = SearchField(string: "")
    let scrollView = ScrollView()
    let footerView = NSTextField(string: "YPaste")
    
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        orientation = .vertical
        edgeInsets = NSEdgeInsets.init(top: 20, left: 6, bottom: 20, right: 6)
        translatesAutoresizingMaskIntoConstraints = false
        alignment = .left
        
        addView(searchField, in: .top)
        NSLayoutConstraint.activate([
            searchField.leftAnchor.constraint(equalTo: leftAnchor),
            searchField.rightAnchor.constraint(equalTo: rightAnchor, constant: -18)
        ])
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.hasVerticalScroller = true
        scrollView.verticalScroller?.isHidden = true
        scrollView.drawsBackground = false
        scrollView.documentView = ListView()
        scrollView.verticalScroller?.controlSize = .mini
        addView(scrollView, in: .center)
        
        NSLayoutConstraint.activate([
          scrollView.leftAnchor.constraint(equalTo: leftAnchor),
          scrollView.rightAnchor.constraint(equalTo: rightAnchor),
          scrollView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 20),
          scrollView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -(NSScreen.main?.visibleFrame.origin.y ?? 100)),
        ])
        
        footerView.alignment = .center
        footerView.backgroundColor = .clear
        footerView.isBordered = false
        footerView.alphaValue = 0.3
        addView(footerView, in: .bottom)
        
        searchField.bind(.predicate, to: PasteItemsController.shared, withKeyPath: "fetchPredicate", options: [NSBindingOption.predicateFormat: "self.value contains[cd] $value"])
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
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func update() {
        (scrollView.documentView as! ListView).update()
    }
}
