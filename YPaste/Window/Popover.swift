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
        let view = NSTextField(labelWithString: pasteItem.value!)
        view.cell?.wraps = true
        view.cell?.lineBreakMode = .byCharWrapping
        self.contentViewController!.view = view
    }
}
