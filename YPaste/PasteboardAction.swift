//
//  PasteBoardHandler.swift
//  YPaste
//
//  Created by marchyang on 2019/10/22.
//  Copyright © 2019 qwertyyb. All rights reserved.
//

import Cocoa
import CryptoKit

extension Digest {
    var hexStr: String {
        Array(makeIterator()).map { String(format: "%02X", $0) }.joined()
    }
}

extension PasteItem {
    func getImage() -> NSImage? {
        guard let data = data else {
            return nil
        }
        return NSImage(data: data)
    }
}

class PasteboardAction {
    private init() {}
    
    /**
     * 检查粘贴权限
     * @param {Bool} prompt 如果没有权限，是否弹出询问授权弹窗
     * @returns {Bool} 是否授权
     */
    func checkAccess(prompt: Bool = false) -> Bool {
        let checkOptionPromptKey = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
        let opts = [checkOptionPromptKey: prompt] as CFDictionary
        return AXIsProcessTrustedWithOptions(opts)
    }
    
    private func writeToPasteboard(historyItem: PasteItem) {
        if (historyItem.type == "text") {
            NSPasteboard.general.declareTypes([.string], owner: nil)
            NSPasteboard.general.setString(historyItem.value!, forType: .string)
        } else {
            NSPasteboard.general.clearContents()
            let contents = historyItem.contents?.allObjects as! [PasteItemContent]
            let types = contents.map({ (content) -> NSPasteboard.PasteboardType in
                NSPasteboard.PasteboardType(content.type!)
            })
            NSPasteboard.general.declareTypes(types, owner: nil)
            contents.forEach({ (content) in
                NSPasteboard.general.setData(content.data, forType: .init(content.type!))
            })
        }
    }
    
    private func triggerPaste() {
        if !self.checkAccess() {
            let _ = self.checkAccess(prompt: true)
        }
        // Based on https://github.com/Clipy/Clipy/blob/develop/Clipy/Sources/Services/PasteService.swift.
        
        let vCode = UInt16(0x09)
        let source = CGEventSource(stateID: .combinedSessionState)
        // Disable local keyboard events while pasting
        source?.setLocalEventsFilterDuringSuppressionState([.permitLocalMouseEvents, .permitSystemDefinedEvents], state: .eventSuppressionStateSuppressionInterval)
        
        let keyVDown = CGEvent(keyboardEventSource: source, virtualKey: vCode, keyDown: true)
        let keyVUp = CGEvent(keyboardEventSource: source, virtualKey: vCode, keyDown: false)
        keyVDown?.flags = .maskCommand
        keyVUp?.flags = .maskCommand
        keyVDown?.post(tap: .cgAnnotatedSessionEventTap)
        keyVUp?.post(tap: .cgAnnotatedSessionEventTap)
    }
    
    /**
     * 粘贴内容到文本输入框
     * @param {PasteItem} pasteItem 要粘贴的历史记录
     */
    func paste(pasteItem: PasteItem){
        writeToPasteboard(historyItem: pasteItem)
        NSApp.hide(nil)
        DispatchQueue.main.async {
            self.triggerPaste()
        }
    }
    
    static let shared = PasteboardAction()
}

