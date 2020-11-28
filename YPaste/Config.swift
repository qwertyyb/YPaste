//
//  Config.swift
//  YPaste
//
//  Created by marchyang on 2020/11/11.
//  Copyright © 2020 qwertyyb. All rights reserved.
//

import Foundation
import AppKit

@objc enum PopupPosition: Int {
    case top = 0
    case bottom = 1
    case left = 2
    case right = 3
}

extension UserDefaults {
    @objc dynamic var popupPosition: PopupPosition {
        get { PopupPosition(rawValue: integer(forKey: "popupPosition")) ?? .left }
        set { set(newValue, forKey: "popupPosition")}
    }
}

class Config {
    static let shared = Config()
    
    init() {
    }
    
    var popupPosition: PopupPosition = PopupPosition(rawValue: UserDefaults.standard.integer(forKey: "popupPosition")) ?? .left
    
    private var windowWidth: CGFloat {
        if (popupPosition == .bottom || popupPosition == .top) {
            return NSScreen.main?.frame.width ?? 0
        }
        return 368
    }
    
    private var windowHeight: CGFloat {
        if (popupPosition == .bottom || popupPosition == .top) {
            return 306
        }
        let menuBarHeight = NSMenu.menuBarVisible() ? NSApplication.shared.mainMenu?.menuBarHeight ?? 24 : 0
        let height = (NSScreen.main?.frame.height ?? NSScreen.screens.first!.frame.height) - menuBarHeight
        return height
    }
    
    var windowSize: CGSize {
        let size = NSSize(width: windowWidth, height: windowHeight)
        return size
        
    }
    
    var windowOrigin: NSPoint {
        let sr = NSScreen.main?.frame ?? .zero
        if (popupPosition == .top) {
            return NSPoint(x: sr.minX, y: sr.maxY - windowHeight)
        }
        if (popupPosition == .right) {
            return NSPoint(x: sr.maxX - windowWidth, y: sr.minY)
        }
        return sr.origin
    }
    
    func getInitialConstraint (mainView: NSView, containerView: NSView) -> NSLayoutConstraint {
        if (popupPosition == .bottom) {
            return mainView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 400)
        }
        if (popupPosition == .top) {
            return mainView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: -400)
        }
        if (popupPosition == .left) {
            return mainView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: -400)
        }
        return mainView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: 400)
    }
    
    func applyShowAnimateConstraint (constraint: NSLayoutConstraint) {
        NSAnimationContext.runAnimationGroup { (ctx) in
            ctx.duration = 0.3
            ctx.timingFunction = .init(name: .easeOut)
            constraint.animator().constant = 0
        }
    }
    
    func applyHideAnimateConstraint (constraint: NSLayoutConstraint, callback: @escaping () -> Void) {
        NSAnimationContext.runAnimationGroup { (ctx) in
            ctx.duration = 0.3
            ctx.timingFunction = .init(name: .easeIn)
            ctx.completionHandler = callback
            var val: CGFloat = -400
            if (popupPosition == .bottom || popupPosition == .right) {
                val = 400
            } else if (popupPosition == .top || popupPosition == .left) {
                val = -400
            }
            constraint.animator().constant = val
        }
    }
    
    var scrollDirection: NSUserInterfaceLayoutOrientation {
        if (popupPosition == .bottom || popupPosition == .top) {
            return .horizontal
        }
        return .vertical
    }
}
