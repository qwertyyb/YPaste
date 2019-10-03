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
        let delegate = NSApp.delegate as! AppDelegate
        if sender.state == .on {
            delegate.app.autoLaunch(active: true)
        } else {
            delegate.app.autoLaunch(active: false)
        }
    }
}
