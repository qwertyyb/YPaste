//
//  PasteHandlerTests.swift
//  YPasteTests
//
//  Created by 虚幻 on 2020/1/9.
//  Copyright © 2020 qwertyyb. All rights reserved.
//

import XCTest
@testable import YPaste

class PasteboardHandlerTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_listen_notification() {
        NSPasteboard.general.declareTypes([NSPasteboard.PasteboardType.string], owner: nil)
        let timestamp = Date().timeIntervalSince1970
        NSPasteboard.general.setString("\(timestamp)", forType: NSPasteboard.PasteboardType.string)
        NSPasteboard.general.setString("\(timestamp)", forType: NSPasteboard.PasteboardType.string)

        let notification = XCTNSNotificationExpectation(name: PasteboardHandler.changeNotification)
        notification.handler = {(notification) -> Bool in
            let info = notification.userInfo
            if let item = info!["pasteItem"] {
                let pasteItem = item as! PasteItem
                return pasteItem.value == "\(timestamp)"
            }
            return false
        }
        let result = XCTWaiter.wait(for: [notification], timeout: 1)
        XCTAssertTrue(result == .completed, "测试监听剪切板发送change notification")
    }
    
    func test_listen_history_is_correct() {
        NSPasteboard.general.declareTypes([NSPasteboard.PasteboardType.string], owner: nil)
        let timestamp = "hello"
        NSPasteboard.general.setString("\(timestamp)", forType: NSPasteboard.PasteboardType.string)
        

        let notification = XCTNSNotificationExpectation(name: PasteboardHandler.changeNotification)
        XCTWaiter.wait(for: [notification], timeout: 1)
        
        let fetch: NSFetchRequest<PasteItem> = PasteItem.fetchRequest()
        fetch.fetchLimit = 1
        fetch.sortDescriptors = [NSSortDescriptor(key: "updated_at", ascending: false)]
        let ctx = CoreDataManager.shared.bgContext
        let results = try? ctx.fetch(fetch)
        print(results![0].value)
        
        XCTAssertTrue(results != nil && results!.count > 0 && results![0].value == "hello", "测试监听剪切板写入历史记录中")
    }
    
    func test_listen_favorite_is_correct() {
        NSPasteboard.general.declareTypes([NSPasteboard.PasteboardType.string], owner: nil)
        let timestamp = "hello"
        NSPasteboard.general.setString("\(timestamp)", forType: NSPasteboard.PasteboardType.string)
        
        XCTWaiter.wait(for: [XCTNSNotificationExpectation(name: PasteboardHandler.changeNotification)], timeout: 0.4)
        
        NSPasteboard.general.setString("\(timestamp)", forType: NSPasteboard.PasteboardType.string)
        XCTWaiter.wait(for: [XCTNSNotificationExpectation(name: PasteboardHandler.changeNotification)], timeout: 0.4)

        let fetch: NSFetchRequest<PasteItem> = PasteItem.fetchRequest()
        fetch.fetchLimit = 1
        fetch.sortDescriptors = [NSSortDescriptor(key: "updated_at", ascending: false)]
        let ctx = CoreDataManager.shared.bgContext
        let results = try? ctx.fetch(fetch)
        
        XCTAssertTrue(results != nil && results!.count > 0 && results![0].value == "hello" && results![0].favorite == true, "测试监听剪切板写入历史记录中")
    }
    
    func test_paste_is_correct() {
        NSPasteboard.general.declareTypes([NSPasteboard.PasteboardType.string], owner: nil)
        let timestamp = "paste value"
        NSPasteboard.general.setString("\(timestamp)", forType: NSPasteboard.PasteboardType.string)
        
        XCTWaiter.wait(for: [XCTNSNotificationExpectation(name: PasteboardHandler.changeNotification)], timeout: 0.4)
        
        let fetch: NSFetchRequest<PasteItem> = PasteItem.fetchRequest()
        fetch.fetchLimit = 1
        fetch.sortDescriptors = [NSSortDescriptor(key: "updated_at", ascending: false)]
        let ctx = CoreDataManager.shared.bgContext
        let results = try? ctx.fetch(fetch)
        
        PasteboardHandler.shared.paste(pasteItem: results![0])
        let result = XCTWaiter.wait(for: [XCTNSNotificationExpectation(name: PasteboardHandler.changeNotification)], timeout: 0.5)
        XCTAssertTrue(result == .completed, "粘贴行为触发事件正常")
        
        let val = NSPasteboard.general.string(forType: .string)
        XCTAssertTrue(val == "paste value", "粘贴内容被复制到剪切paste value板")
    }

}
