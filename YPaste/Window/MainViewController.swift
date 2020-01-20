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
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        view = NSView()
    }
    
    override func viewWillAppear() {
        let mainView = MainView()
        mainView.alphaValue = HotkeyHandler.shared.openType == .order ? 0.4 : 1
        mainView.updateFooter(string: HotkeyHandler.shared.openType == .favorite ? "YPaste - 收藏" : "YPaste - 历史")
        if HotkeyHandler.shared.openType == .order { mainView.removeSearchView() }
        view = mainView
    }
    override func viewDidDisappear() {
        view = NSView()
        PasteItemsController.shared.fetchPredicate = nil
        PasteItemsController.shared.resetPage()
        PasteItemsController.shared.setSelectionIndex(0)
    }

}

