//
//  MainViewController.swift
//  YPaste
//
//  Created by 虚幻 on 2019/9/5.
//  Copyright © 2019 qwertyyb. All rights reserved.
//

import Cocoa
import HotKey

class MainViewController: NSViewController {
    
    @IBOutlet weak var tableView: TableView!
    @IBOutlet var arrayController: PasteItemsController!
    //    override var acceptsFirstResponder: Bool { return true }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    override func viewWillAppear() {
        arrayController.resetPage()
        tableView.scrollRowToVisible(0)
        arrayController.setSelectionIndex(0)
        self.view.alphaValue = HotkeyHandler.shared.openType == .order ? 0.4 : 1
    }
//    
    override func viewDidDisappear() {
        arrayController.fetchPredicate = nil
    }

}

