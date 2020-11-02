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
            GlobalPublisher.shared.keyEventPublisher.send(event)
        }
        
        super.sendEvent(event)
    }
}
