//
//  MainViewController.swift
//  YPaste
//
//  Created by 虚幻 on 2019/9/5.
//  Copyright © 2019 qwertyyb. All rights reserved.
//

import Cocoa
import HotKey

class MainViewController: NSViewController, NSTabViewDelegate {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    let tab = NSTabView()

    let mainView = MainView()
    
    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        tab.tabPosition = .left
        tab.focusRingType = .none
        
        let historyItem = NSTabViewItem()
        historyItem.label = "历史"
        historyItem.view = mainView
        tab.addTabViewItem(historyItem)
        
        let favoriteItem = NSTabViewItem()
        favoriteItem.label = "收藏"
        favoriteItem.view = mainView
        tab.addTabViewItem(favoriteItem)
        
        tab.delegate = self
        view = NSView()
    }
    
    override func viewWillAppear() {
        mainView.alphaValue = HotkeyHandler.shared.openType == .order ? 0.4 : 1
        mainView.updateFooter(string: HotkeyHandler.shared.openType == .favorite ? "YPaste - 收藏" : "YPaste - 历史")
        if HotkeyHandler.shared.openType == .order {
            mainView.removeSearchView()
            mainView.update()
        } else {
            mainView.addSearchView()
        }
        
        PasteItemsController.shared.resetPage()
        PasteItemsController.shared.setSelectionIndex(0)
        
        tab.tabViewType = HotkeyHandler.shared.openType == .order ? .noTabsNoBorder : .leftTabsBezelBorder
        tab.selectTabViewItem(at: HotkeyHandler.shared.openType == .favorite ? 1 : 0)
        
        let stackView = NSStackView()
        stackView.addView(tab, in: .center)
        view = stackView
        self.mainView.scrollView.becomeFirstResponder()
    }
    override func viewDidDisappear() {
        PasteItemsController.shared.fetchPredicate = nil
        view = NSView()
    }
    
    func tabView(_ tabView: NSTabView, willSelect tabViewItem: NSTabViewItem?) {
        guard tabViewItem != nil else { return }
        let index = tabView.tabViewItems.firstIndex(of: tabViewItem!)
        if index == 0 {
            HotkeyHandler.shared.openType = .history
        } else {
            HotkeyHandler.shared.openType = .favorite
        }
        PasteItemsController.shared.fetch(self)
        PasteItemsController.shared.setSelectionIndex(0)
    }
}

