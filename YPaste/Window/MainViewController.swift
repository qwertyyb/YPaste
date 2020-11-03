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
    
    private var leftContraint: NSLayoutConstraint?
    
    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        container.addSubview(mainView)
        container.wantsLayer = true
        container.layer?.backgroundColor = .clear
        mainView.wantsLayer = true
        mainView.layer?.backgroundColor = .init(red: 0.88, green: 0.88, blue: 0.88, alpha: 1)
        mainView.translatesAutoresizingMaskIntoConstraints = false

        leftContraint = mainView.leftAnchor.constraint(equalTo: container.leftAnchor, constant: -400)
        NSLayoutConstraint.activate([
            leftContraint!,
            mainView.widthAnchor.constraint(equalTo: container.widthAnchor),
            mainView.topAnchor.constraint(equalTo: container.topAnchor),
            mainView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])
        view = container
    }
    
    func slideOut() {
        NSAnimationContext.runAnimationGroup { (ctx) in
            ctx.duration = 0.2
            ctx.timingFunction = .init(name: .easeIn)
            leftContraint?.animator().constant = 0
        }
        view.becomeFirstResponder()
    }
    func slideIn(callback: @escaping () -> Void) {
        NSAnimationContext.runAnimationGroup { (ctx) in
            ctx.duration = 0.2
            ctx.timingFunction = .init(name: .easeOut)
            leftContraint?.animator().constant = -400
        } completionHandler: {
            callback()
        }
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

