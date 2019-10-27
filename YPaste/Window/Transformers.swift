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

class TimeTransformer: ValueTransformer {
    override func transformedValue(_ value: Any?) -> Any? {
        if value == nil { return value }
        let date = value as! Date
        let ts = lround(-date.timeIntervalSinceNow)
        let s = ts % 60
        let m = Int(ts / 60) % 60
        let h = Int(ts / 3600) % 24
        let d = Int(ts / 3600 / 24)
        var output = ""
        if d > 0 { output += "\(d)天" }
        if d > 2 {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm MM-dd"
            return formatter.string(from: date)
        }
        if h > 0 { output += "\(h)小时" }
        if d > 0 {
            return output + "前"
        }
        if m > 0 { output += "\(m)分" }
        if h > 0 {
            return output + "前"
        }
        if s > 0 { output += "\(s)秒" }
        return output + "前"
    }
}

extension NSValueTransformerName {
    static let summaryTransformerName = NSValueTransformerName(rawValue: "SummaryTransformer")
    static let timeTransformerName = NSValueTransformerName(rawValue: "TimeTransformer")
}

