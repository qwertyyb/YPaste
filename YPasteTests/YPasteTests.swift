//
//  YPasteTests.swift
//  YPasteTests
//
//  Created by 虚幻 on 2019/9/6.
//  Copyright © 2019 qwertyyb. All rights reserved.
//

import XCTest
@testable import YPaste

class YPasteTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    private func getAutoLaunch() -> Bool {
        let launchFolder = "\(NSHomeDirectory())/Library/LaunchAgents"
        let launchPath = "\(launchFolder)/\(Bundle.main.bundleIdentifier!).plist"
        let dict = NSDictionary.init(contentsOfFile: launchPath)
        let value = dict?.value(forKey: "RunAtLoad")
        return value as! Bool
    }
    
    func test_autoLaunch_active() {
        YPaste.shared.autoLaunch()
        XCTAssertTrue(getAutoLaunch(), "开机自启激活正常")
    }
    func test_autoLaunch_deactive() {
        YPaste.shared.autoLaunch(active: false)
        XCTAssertFalse(getAutoLaunch(), "开机自启禁用正常")
    }

}
