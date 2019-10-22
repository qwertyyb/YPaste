//
//  PreferencesWindowController.swift
//  YPaste
//
//  Created by marchyang on 2019/10/18.
//  Copyright © 2019 qwertyyb. All rights reserved.
//

import Cocoa

class PreferencesWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
    
        
        let symbolString = convertKeyNameToSymbol(HotkeyHandler.shared.hotKeyString!)
        hotKey.title = symbolString
    }
    
    override func showWindow(_ sender: Any?) {
        NSApp.activate(ignoringOtherApps: true)
        super.showWindow(sender)
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
        eventHandler = NSEvent.addLocalMonitorForEvents(matching: .keyDown, handler: self.handleKeyEvent)
    }
    private func handleKeyEvent(with event: NSEvent) -> NSEvent? {
        if event.modifierFlags.description == "" { return event }
        hotKey.title = event.modifierFlags.description + event.charactersIgnoringModifiers!.uppercased()
        HotkeyHandler.shared.hotKeyString = convertToKeyName(hotKey.title)
        clearKeyEvent()
        return event
    }
    private func clearKeyEvent() {
        if eventHandler != nil {
            NSEvent.removeMonitor(eventHandler!)
            eventHandler = nil
        }
    }
}
