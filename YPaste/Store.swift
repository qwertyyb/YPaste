//
//  Store.swift
//  YPaste
//
//  Created by 虚幻 on 2020/11/1.
//  Copyright © 2020 qwertyyb. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

class Store: ObservableObject {
    @Published var keyEvent: NSEvent = NSEvent()
    
    @Published var keyword: String = ""
    
    
    static let shared = Store()
}
