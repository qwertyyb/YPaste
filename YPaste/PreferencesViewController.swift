//
//  PreferencesViewController.swift
//  YPaste
//
//  Created by 虚幻 on 2019/9/8.
//  Copyright © 2019 qwertyyb. All rights reserved.
//

import Cocoa

class PreferencesViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    @IBAction func onLaunchAtLogin(_ sender: NSButton) {
        if sender.state == .on {
            NSApp.enableRelaunchOnLogin()
        } else {
            NSApp.disableRelaunchOnLogin()
        }
    }
}
