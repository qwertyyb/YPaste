//
//  PreferencesWindowController.swift
//  YPaste
//
//  Created by marchyang on 2019/10/18.
//  Copyright © 2019 qwertyyb. All rights reserved.
//

import Cocoa

enum HotKeyType {
    case history
    case favorite
}

class PreferencesWindowController: NSWindowController, NSWindowDelegate {

    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.delegate = self
        clearKeyEvent()
    }
    
    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        NSApp.activate(ignoringOtherApps: true)
        self.window?.delegate = self
    }
    func windowWillClose(_ notification: Notification) {
        clearKeyEvent()
    }
    
    private var listenKeyActivate = false
    private var eventHandler: Any?
    
    private func convertToKeyName(_ hotKeySymbolString: String) -> String {
        var keyNames: [String] = []
        for symbol in hotKeySymbolString {
            switch symbol {
            case "⌘":
                keyNames.append("command")
                break
            case "⌃":
                keyNames.append("control")
                break
            case "⌥":
                keyNames.append("option")
                break
            case "⇧":
                keyNames.append("shift")
                break
            default:
                keyNames.append(symbol.lowercased())
            }
        }
        return keyNames.joined(separator: "+")
    }
    
    private func convertKeyNameToSymbol(_ hotKeyString: String) -> String {
        var symbolString = ""
        for keyName in hotKeyString.split(separator: "+") {
            switch keyName {
                case "command":
                    symbolString.append("⌘")
                    break
                case "control":
                    symbolString.append("⌃")
                    break
                case "option":
                    symbolString.append("⌥")
                    break
                case "shift":
                    symbolString.append("⇧")
                    break
                default:
                    symbolString.append(keyName.uppercased())
            }
        }
        return symbolString
    }

    @IBOutlet weak var hotKey: NSButton!
    
    private var curHotKey = HotKeyType.history
    @IBAction func onLaunchAtLogin(_ sender: NSButton) {
        let delegate = NSApp.delegate as! AppDelegate
        if sender.state == .on {
            delegate.app.autoLaunch(active: true)
        } else {
            delegate.app.autoLaunch(active: false)
        }
    }
    @IBAction func hotKeyClicked(_ sender: NSButton) {
        clearKeyEvent()
        hotKey.title = "输入快捷键"
        curHotKey = .history
        eventHandler = NSEvent.addLocalMonitorForEvents(matching: .keyDown, handler: self.handleKeyEvent)
    }
    private func handleKeyEvent(with event: NSEvent) -> NSEvent? {
        if event.modifierFlags.description == "" { return event }
        let keyName = event.modifierFlags.description + event.charactersIgnoringModifiers!.uppercased()
        if curHotKey == .history {
            hotKey.title = keyName
            UserDefaults.standard.setValue(convertToKeyName(keyName), forKey: "hotKey")
        }
        HotkeyHandler.shared.register()
        clearKeyEvent()
        return event
    }
    private func clearKeyEvent() {
        if eventHandler != nil {
            NSEvent.removeMonitor(eventHandler!)
            eventHandler = nil
        }
        hotKey.title = convertKeyNameToSymbol(UserDefaults.standard.string(forKey: "hotKey")!)
    }
}
