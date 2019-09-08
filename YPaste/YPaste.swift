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

class YPaste {
    private var hotkey: HotKey?
    var handler: HotKey.Handler? {
        get { return self.hotkey?.keyDownHandler }
        set (handler) { self.hotkey?.keyDownHandler = handler }
    }
    
    let pasteboard = NSPasteboard.general
    private var lastChangeCount: Int = 0
    
    init() {
        registerHotKey()
        listeningPasteBoard()
    }
    
    
    func listeningPasteBoard() {
        Timer.scheduledTimer(timeInterval: 1.0,
                             target: self,
                             selector: #selector(checkForChangesInPasteboard),
                             userInfo: nil,
                             repeats: true)
    }
    
    @objc
    private func checkForChangesInPasteboard() {
        guard pasteboard.changeCount != lastChangeCount else {
            return
        }
        
        if let lastItem = pasteboard.string(forType: NSPasteboard.PasteboardType.string) {
            let saveContext = (NSApp.delegate as! AppDelegate).persistentContainer.newBackgroundContext()
            let fetchRequest = NSFetchRequest<PasteItem>(entityName: "PasteItem")
            fetchRequest.predicate = NSPredicate(format: "value = %@ and type = %@", lastItem, "text")
            let pasteItems = try? saveContext.fetch(fetchRequest);
            // 已存在,只更新时间,不存在时,添加一条记录
            if pasteItems == nil || pasteItems?.count == 0 {
                let pasteItem = NSEntityDescription.insertNewObject(forEntityName: "PasteItem", into: saveContext) as! PasteItem
                pasteItem.type = "text"
                pasteItem.value = lastItem
                pasteItem.updated_at = Date()
                try? saveContext.save()
            } else {
                pasteItems?[0].updated_at = Date()
                try? saveContext.save()
            }
        }
        
        lastChangeCount = pasteboard.changeCount
    }
    
    private func registerHotKey() {
//        guard let keybindingString = UserDefaults.standard.string(forKey: hotKeyStore) else {
//            return
//        }
        let keybindingString = "command+shift+v"
        var keysList = keybindingString.split(separator: "+")
        
        guard let keyString = keysList.popLast() else {
            return
        }
        guard let key = Key(string: String(keyString)) else {
            return
        }
        
        var modifiers: NSEvent.ModifierFlags = []
        for keyString in keysList {
            switch keyString {
            case "command":
                modifiers.insert(.command)
            case "control":
                modifiers.insert(.control)
            case "option":
                modifiers.insert(.option)
            case "shift":
                modifiers.insert(.shift)
            default: ()
            }
        }
        
        hotkey = HotKey(key: key, modifiers: modifiers)
    }
    
    func paste(pasteItem: PasteItem){
        // Based on https://github.com/Clipy/Clipy/blob/develop/Clipy/Sources/Services/PasteService.swift.
        pasteboard.declareTypes([NSPasteboard.PasteboardType.string], owner: nil)
        pasteboard.setString(pasteItem.value!, forType: NSPasteboard.PasteboardType.string)
        NSWorkspace.shared.menuBarOwningApplication?.activate(options: NSApplication.ActivationOptions.activateIgnoringOtherApps)
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { (timer) in
            let vCode = UInt16(0x09)
            let source = CGEventSource(stateID: .combinedSessionState)
            // Disable local keyboard events while pasting
            source?.setLocalEventsFilterDuringSuppressionState([.permitLocalMouseEvents, .permitSystemDefinedEvents],
                                                               state: .eventSuppressionStateSuppressionInterval)
            
            let keyVDown = CGEvent(keyboardEventSource: source, virtualKey: vCode, keyDown: true)
            let keyVUp = CGEvent(keyboardEventSource: source, virtualKey: vCode, keyDown: false)
            keyVDown?.flags = .maskCommand
            keyVUp?.flags = .maskCommand
            keyVDown?.post(tap: .cgAnnotatedSessionEventTap)
            keyVUp?.post(tap: .cgAnnotatedSessionEventTap)
        }
    }
    
    func checkUpdate() {
        let url = "https://api.github.com/repos/qwertyyb/YPaste/releases/latest"
        var urlFetch = URLRequest(url: URL(string: url)!)
        urlFetch.addValue("token 2043b93ba0023253a19d96d2dc60205c74f0eade", forHTTPHeaderField: "Authorization")
        let dataTask = URLSession.shared.dataTask(with: urlFetch) { (data, response, error) in
            if error != nil {
                print("check update, network error: " +  error.debugDescription)
                return
            }
            let r = (response as! HTTPURLResponse)
            if r.statusCode != 200 {
                print("check update error, http error: " + String(r.statusCode))
                return
            }
            let obj = try? JSONSerialization.jsonObject(with: data!, options:[]) as! [String: Any]
            let latestVersion = Int((obj?["tag_name"] as! String).replacingOccurrences(of: ".", with: ""))
            
            let runningVersion = Int((Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String).replacingOccurrences(of: ".", with: ""))
            if latestVersion! > runningVersion! {
                return
            }
            // find new version
            let updateInformation = obj?["body"] as! String
            
            DispatchQueue.main.async {
                let alert = NSAlert()
                alert.messageText = "a new version " + (obj?["tag_name"] as! String) + " was found, update or not?"
                alert.informativeText = "version information: " + updateInformation
                alert.alertStyle = NSAlert.Style.informational
                let confirmButton = alert.addButton(withTitle: "confirm")
                confirmButton.highlight(true)
                let cancelBtn = alert.addButton(withTitle: "cancel")
                cancelBtn.refusesFirstResponder = false
                let ok = alert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn
                if ok {
                    self.updateApp((obj?["assets"] as! [[String: Any]])[0]["browser_download_url"] as! String)
                }
            }
        }
        dataTask.resume()
    }
    
    func updateApp (_ downloadURL: String) {
        NSWorkspace.shared.openFile(downloadURL)
    }
}
