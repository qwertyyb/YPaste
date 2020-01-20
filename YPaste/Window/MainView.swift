//
//  MainView.swift
//  YPaste
//
//  Created by marchyang on 2020/1/20.
//  Copyright © 2020 qwertyyb. All rights reserved.
//

import Cocoa

class MainView: NSStackView {
    
    let searchField = NSSearchField(string: "")
    let listView = ListView()
    var scrollView = ScrollView()
    var footerView = NSTextField(string: "YPaste")
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        orientation = .vertical
        
        edgeInsets = NSEdgeInsets.init(top: 20, left: 12, bottom: 20, right: 12)
        
        translatesAutoresizingMaskIntoConstraints = false

        alignment = .left
        
        addView(searchField, in: .top)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.hasVerticalScroller = true
        scrollView.verticalScroller?.isHidden = true
        scrollView.drawsBackground = false
        scrollView.documentView = listView
        scrollView.verticalScroller?.controlSize = .mini
        addView(scrollView, in: .center)
        
        NSLayoutConstraint.activate([
          scrollView.leftAnchor.constraint(equalTo: leftAnchor, constant: 12),
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
}
