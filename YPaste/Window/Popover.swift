//
//  Popover.swift
//  YPaste
//
//  Created by 虚幻 on 2019/11/1.
//  Copyright © 2019 qwertyyb. All rights reserved.
//

import Cocoa

class Popover: NSPopover {
    override init() {
        super.init()
        let viewController = NSViewController()
        self.contentViewController = viewController
        self.contentSize = NSMakeSize(320, 240)
        self.behavior = .semitransient
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func updateContent(pasteItem: PasteItem) {
        var str = pasteItem.value!
        if (str.count > 1000) {
            let end = str.index(str.startIndex, offsetBy: 1000)
            let range = Range<String.Index>(uncheckedBounds: (lower: str.startIndex, upper: end))
            str = String(str[range]) + "..."
        }
        let view = NSTextField(labelWithString: str)
        view.cell?.wraps = true
        view.cell?.lineBreakMode = .byCharWrapping
        self.contentViewController!.view = view
    }
    
    func clear () {
        let view = NSTextField()
        self.contentViewController!.view = view
    }
}
