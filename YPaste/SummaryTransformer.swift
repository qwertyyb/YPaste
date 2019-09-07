//
//  SummaryTransformer.swift
//  YPaste
//
//  Created by 虚幻 on 2019/9/7.
//  Copyright © 2019 qwertyyb. All rights reserved.
//

import Cocoa

class SummaryTransformer: ValueTransformer {
    override func transformedValue(_ value: Any?) -> Any? {
        if (value == nil) { return value }
        let str = value as! String
        let trimmedTitle = str.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        return trimmedTitle
    }
}

extension NSValueTransformerName {
    static let summaryTransformerName = NSValueTransformerName(rawValue: "SummaryTransformer")
}

