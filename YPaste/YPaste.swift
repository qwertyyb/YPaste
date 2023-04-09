//
//  YPaste.swift
//  YPaste
//
//  Created by 虚幻 on 2019/9/6.
//  Copyright © 2019 qwertyyb. All rights reserved.
//

import Foundation
import HotKey
import Cocoa

public extension NSApplication {
    
    func relaunch(afterDelay seconds: TimeInterval = 0.5) -> Never {
        let task = Process()
        task.launchPath = "/bin/sh"
        task.arguments = ["-c", "sleep \(seconds); open \"\(Bundle.main.bundlePath)\""]
        task.launch()
        
        self.terminate(nil)
        exit(0)
    }
}

class YPaste {
    
    let pasteboardHandler = PasteboardAction.shared
    let hotkeyHandler = HotkeyHandler.shared
    var mainWindow: MainWindow = MainWindow()
    let listener: PasteboardListener

    init() {
        listener = PasteboardListener(onNewData: { data in
            Store.shared.addOrUpdateRecord(data)
        })
        
        NotificationCenter.default.addObserver(self, selector: #selector(showWindow), name: HotkeyHandler.requestOpenWindowNotification, object: nil)
        
        showWindow()
    }
    
    @objc
    func showWindow() {
        NSApp.activate(ignoringOtherApps: true)
        // 等待当前应用激活后再拉起窗口
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { timer in
            self.mainWindow.setFrame(
                NSRect(origin: Config.shared.windowOrigin, size: Config.shared.windowSize),
                display: true
            )
            self.mainWindow.makeKeyAndOrderFront(self)
        })
    }
    
    func autoLaunch(active: Bool = true) {
        let launchFolder = "\(NSHomeDirectory())/Library/LaunchAgents"
        let launchPath = "\(launchFolder)/\(Bundle.main.bundleIdentifier!).plist"
        let dict = NSMutableDictionary()
        let arr = NSMutableArray()
        arr.add(Bundle.main.executablePath!)
        arr.add("-runMode")
        arr.add("autoLaunched")
        dict.setObject(active, forKey: NSMutableString("RunAtLoad"))
        dict.setObject(Bundle.main.bundleIdentifier!, forKey: NSMutableString("Label"))
        dict.setObject(arr, forKey: NSMutableString("ProgramArguments"))
        dict.write(toFile: launchPath, atomically: false)
    }
    
    static let shared = YPaste()
}
