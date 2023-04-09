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
        var str = value as! String
        str = str.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if (str.count > 100) {
            let start = str.index(str.startIndex, offsetBy: 0)
            let end = str.index(str.startIndex, offsetBy: 100)
            let range = Range<String.Index>(uncheckedBounds: (lower: start, upper: end))
            return String(str[range])
        }
        return str
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
        if d > 0 { output += "\(d)\(NSLocalizedString("label.Day", comment: "天"))" }
        if d > 2 {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm MM-dd"
            return formatter.string(from: date)
        }
        if h > 0 { output += "\(h)\(NSLocalizedString("label.Hours", comment: "小时"))" }
        if d > 0 {
            return output + NSLocalizedString("label.Ago", comment: "前")
        }
        if m > 0 { output += "\(m)\(NSLocalizedString("label.Minutes", comment: "分钟"))" }
        if h > 0 {
            return output + NSLocalizedString("label.Ago", comment: "前")
        }
        if s > 0 { output += "\(s)\(NSLocalizedString("label.Seconds", comment: "秒"))" }
        if s <= 0 { return NSLocalizedString("label.Now", comment: "此刻") }
        return output + NSLocalizedString("label.Ago", comment: "前")
    }
}

extension NSValueTransformerName {
    static let summaryTransformerName = NSValueTransformerName(rawValue: "SummaryTransformer")
    static let timeTransformerName = NSValueTransformerName(rawValue: "TimeTransformer")
}

