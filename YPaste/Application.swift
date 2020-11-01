//
//  Application.swift
//  YPaste
//
//  Created by 虚幻 on 2020/11/1.
//  Copyright © 2020 qwertyyb. All rights reserved.
//

import Cocoa
import Carbon
import SwiftUI
import Combine

class GlobalPublisher {
    let keyEventPublisher = PassthroughSubject<NSEvent, Never>()
    
    let keywordPublisher = PassthroughSubject<String, Never>()
    
    static let shared = GlobalPublisher()
}

class Application: NSApplication {
    override func sendEvent(_ event: NSEvent) {
        if event.type == .keyDown {
            print(event)
            Store.shared.keyEvent = event
            GlobalPublisher.shared.keyEventPublisher.send(event)
            if event.keyCode == kVK_Delete {
                Store.shared.keyword = String(Store.shared.keyword.dropLast())
            } else if event.characters != nil {
                guard let reg = try? NSRegularExpression(pattern: "^[a-zA-Z]+$") else {
                    super.sendEvent(event)
                    return
                }
                if let match = reg.firstMatch(
                    in: event.characters!,
                    options: [],
                    range: NSRange(location: 0, length: event.characters!.count)
                ) {
                    Store.shared.keyword += event.characters![Range(match.range, in: event.characters!)!]
                }
            }
            GlobalPublisher.shared.keywordPublisher.send(Store.shared.keyword)
        }
        
        super.sendEvent(event)
    }
}
