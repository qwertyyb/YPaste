//
//  MainViewController.swift
//  YPaste
//
//  Created by 虚幻 on 2019/9/5.
//  Copyright © 2019 qwertyyb. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    let mainView = MainView()
    let container = NSView()
    
    private var constraint: NSLayoutConstraint?
    private var popupPosition: PopupPosition = Config.shared.popupPosition
    
    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        container.wantsLayer = true
        container.layer?.backgroundColor = .clear
        container.translatesAutoresizingMaskIntoConstraints = false
        mainView.wantsLayer = true
        mainView.layer?.backgroundColor = .clear
        mainView.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(mainView)
        NSLayoutConstraint.activate([
            mainView.widthAnchor.constraint(equalTo: container.widthAnchor),
            mainView.heightAnchor.constraint(equalTo: container.heightAnchor)
        ])
        view = container
    }
    
    func slideOut() {
        mainView.frame = NSRect.zero
        popupPosition = Config.shared.popupPosition
        constraint = Config.shared.getInitialConstraint(mainView: mainView, containerView: container)
        NSLayoutConstraint.activate([
            constraint!,
            mainView.widthAnchor.constraint(equalTo: container.widthAnchor),
            mainView.heightAnchor.constraint(equalTo: container.heightAnchor)
        ])
        NSAnimationContext.runAnimationGroup { (ctx) in
            ctx.duration = 0.3
            ctx.timingFunction = .init(name: .easeIn)
            ctx.completionHandler = {
                self.view.window?.hasShadow = true
            }
            self.constraint!.animator().constant = 0
        }
        view.becomeFirstResponder()
    }
    func slideIn(callback: @escaping () -> Void) {
        self.view.window?.hasShadow = false
        NSAnimationContext.runAnimationGroup { (ctx) in
            ctx.duration = 0.3
            ctx.timingFunction = .init(name: .easeOut)
            ctx.completionHandler = {
                self.constraint?.constant = 0
                NSLayoutConstraint.deactivate([self.constraint!])
                callback()
            }
            var val: CGFloat = 0
            let popupPosition = self.popupPosition
            if popupPosition == .top || popupPosition == .bottom {
                val = self.view.window?.frame.height ?? 0
            } else {
                val = self.view.window?.frame.width ?? 0
            }
            if (popupPosition == .top || popupPosition == .left) {
                val = -val
            }
            self.constraint!.animator().constant = val
        }
    }
    
    override func viewWillAppear() {
        if let listView = mainView.scrollView.documentView as? ListView {
            listView.orientation = Config.shared.scrollDirection
            listView.alignment = listView.orientation == .horizontal ? .centerY : .centerX
        }
        ViewStore.shared.start()
        
        self.mainView.scrollView.becomeFirstResponder()
    }
    override func viewDidDisappear() {
        ViewStore.shared.reset()
        ViewStore.shared.pause()
        // 多向前滚动一些距离，给选中框留下一些空间
        mainView.scrollView.documentView?.scroll(NSPoint(x: -100, y: -100))
    }
}

