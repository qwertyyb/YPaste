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
    
    let pasteboardHandler = PasteboardHandler.shared
    let hotkeyHandler = HotkeyHandler.shared
    let mainWindowController: MainWindowController = MainWindowController(window: MainWindow())
    
    
    private var observation: NSKeyValueObservation?

    init() {
        hotkeyHandler.register()
        pasteboardHandler.startListener()
        observation = UserDefaults.standard.observe(\.popupPosition) { (userDefaults, changes) in
//            self.mainWindowController.contentViewController = MainViewController()
            let alert = NSAlert()
            alert.messageText = "need restart to apply changes"
            alert.runModal()
            NSApp.relaunch()
        }
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
