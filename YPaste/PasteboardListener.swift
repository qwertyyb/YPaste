//
//  PasteboardListener.swift
//  YPaste
//
//  Created by 虚幻 on 2023/4/9.
//  Copyright © 2023 qwertyyb. All rights reserved.
//

import Foundation
import AppKit

typealias OnNewData = (_ data: NSPasteboardItem) -> Void

class PasteboardListener {
    static let newDataNotification = Notification.Name("PasteboardListener.newDataNotification")
    
    let onNewData: OnNewData
    
    private var timer: Timer?
    
    init(onNewData: @escaping OnNewData) {
        self.onNewData = onNewData
        start()
    }
    
    func start() {
        if timer != nil {
            self.stop()
        }
        timer = Timer.scheduledTimer(
            timeInterval: 0.3,
            target: self,
            selector: #selector(checkForChangesInPasteboard),
            userInfo: nil,
            repeats: true)
    }
    
    func stop() {
        if let timer = self.timer {
            timer.invalidate()
        }
    }
    
    private let pasteboard = NSPasteboard.general
    private var lastChangeCount: Int = NSPasteboard.general.changeCount

    @objc
    private func checkForChangesInPasteboard() {
        guard pasteboard.changeCount != lastChangeCount else {
            return
        }
        lastChangeCount = pasteboard.changeCount
        self.changeHandler()
    }
    
    private func changeHandler() {
        
        if let item = pasteboard.pasteboardItems?.first {
            onNewData(item)
            NotificationCenter.default.post(
                name: PasteboardListener.newDataNotification,
                object: nil,
                userInfo: [
                    "data": item,
                ]
            )
        }
    }
}
