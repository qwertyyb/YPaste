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

    let mainView = MainView()
    let container = NSView()
    
    private var constraint: NSLayoutConstraint?
    
    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        container.wantsLayer = true
        container.layer?.backgroundColor = .clear
        container.translatesAutoresizingMaskIntoConstraints = false
        mainView.wantsLayer = true
        mainView.layer?.backgroundColor = .clear
        mainView.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(mainView)
        constraint = Config.shared.getInitialConstraint(mainView: mainView, containerView: container)
        NSLayoutConstraint.activate([
            constraint!,
            mainView.widthAnchor.constraint(equalTo: container.widthAnchor),
            mainView.heightAnchor.constraint(equalTo: container.heightAnchor)
        ])
        view = container
    }
    
    func slideOut() {
        Config.shared.applyShowAnimateConstraint(constraint: constraint!)
        view.becomeFirstResponder()
    }
    func slideIn(callback: @escaping () -> Void) {
        print(self.view.frame)
        Config.shared.applyHideAnimateConstraint(constraint: constraint!, callback: callback)
    }
    
    override func viewWillAppear() {
        mainView.addSearchView()
        PasteItemsController.shared.resetPage()
        PasteItemsController.shared.setSelectionIndex(0)
        
        self.mainView.scrollView.becomeFirstResponder()
    }
    override func viewDidDisappear() {
        PasteItemsController.shared.fetchPredicate = nil
    }
}

