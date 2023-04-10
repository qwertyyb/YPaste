//
//  SearchField.swift
//  YPaste
//
//  Created by marchyang on 2019/10/22.
//  Copyright © 2019 qwertyyb. All rights reserved.
//

import Cocoa
import HotKey

class SearchField: NSSearchField, NSSearchFieldDelegate {
    
    static let arrowDownKeyDownNotification = NSNotification.Name("searchField:arrowDownKeyDownNotification")
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.borderColor = .clear
        layer?.borderWidth = 0
        layer?.cornerRadius = 10
        sendsWholeSearchString = true
        sendsSearchStringImmediately = false
        delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(setStringValue), name: ViewStore.keywordChangedNotification, object: nil)
    }
    
    override func keyUp(with event: NSEvent) {
        if event.keyCode == Key.downArrow.carbonKeyCode {
            NotificationCenter.default.post(name: SearchField.arrowDownKeyDownNotification, object: self)
        }
    }
    
    func controlTextDidEndEditing(_ obj: Notification) {
        ViewStore.shared.setKeyword(self.stringValue)
    }
    
    @objc
    func setStringValue() {
        self.stringValue = ViewStore.shared.keyword
    }
}
