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

typealias SimplePasteItemData = (type: NSPasteboard.PasteboardType, data: Data)

extension PasteItem {
    func getString() -> NSAttributedString? {
        if (type == "text") {
            return NSAttributedString(string: value ?? "[空]")
        }
        
        guard let data = data,
              let type = type else {
            return NSAttributedString(string: "[空]")
        }
        let pType = NSPasteboard.PasteboardType(rawValue: type)
        if pType == .string {
            return NSAttributedString(string: String(data: data, encoding: .utf8) ?? "[error data]")
        }
        if let str = NSAttributedString(pasteboardPropertyList: data, ofType: pType) {
            return str
        }
        if let url = URL(dataRepresentation: data, relativeTo: nil) {
            return NSAttributedString(string: url.absoluteString)
        }
        return nil
    }
    
    func getImage() -> NSImage? {
        guard let data = data else {
            return nil
        }
        return NSImage(data: data)
    }
    var content: NSPasteboardWriting? {
        getImage() ?? getString()
    }
}

class PasteboardHandler {
    var orderedItems: [NSManagedObjectID] = []
    var ignoreNextItems: Bool = false
    
    let supportTypes: [NSPasteboard.PasteboardType] = [
        .URL,
        .fileURL,
        .rtf,
        .rtfd,
        .html,
        .pdf,
        .png,
        .ruler,
        .string,
        .tiff
    ]
    
    private let pasteboard = NSPasteboard.general
    private var lastChangeCount: Int = NSPasteboard.general.changeCount
    
    static let pasteboardChangeNotification = Notification.Name(rawValue: "pasteboardChangeNotification")
    static let historyUpdateNotification = Notification.Name(rawValue: "HistoryUpdateNotification")
    static let pastedNotification = Notification.Name(rawValue: "PastedNotification")
    
    @objc
    private func checkForChangesInPasteboard() {
        guard pasteboard.changeCount != lastChangeCount else {
            return
        }
        lastChangeCount = pasteboard.changeCount
        NotificationCenter.default.post(name: PasteboardHandler.pasteboardChangeNotification, object: nil, userInfo: nil)
    }
    
    func startListener() {
        Timer.scheduledTimer(
            timeInterval: 0.3,
            target: self,
            selector: #selector(checkForChangesInPasteboard),
            userInfo: nil,
            repeats: true)
        
        NotificationCenter.default.addObserver(
            forName: PasteboardHandler.pasteboardChangeNotification,
            object: nil,
            queue: nil) { (notification) in
            self.changeHandler()
        }
    }
    
    /**
     * 获取粘贴板项目的唯一hash, 计算每种类型的hash值，然后计算最终的hash值
     * @param {NSPasteboardItem} item 要计算的粘贴板项目
     */
    private func getPasteItemHash(_ item: NSPasteboardItem) -> String? {
        var hashes = item.types.map { (type) -> String in
            guard let data = item.data(forType: type) else {
                return ""
            }
            return type.rawValue + SHA256.hash(data: data).hexStr
        }.filter { (str) -> Bool in
            return !str.isEmpty
        }
        if hashes.isEmpty {
            return nil
        }
        hashes.sort()
        return SHA256.hash(data: hashes.joined().data(using: .utf8)!).hexStr
    }
    
    /**
     * 获取粘贴板内容的简介，用于显示在预览中
     * @param {NSPasteboardItem} item  粘贴板项目
     * @returns {(type: NSPasteboard.PasteboardType, data: Data)} 类型和内容，如果类型不在supportTypes列表中，则返回nil
     */
    private func getShownTypeData(_ item: NSPasteboardItem) -> SimplePasteItemData? {
        for type in supportTypes {
            if let data = item.data(forType: type) {
                return (type: type, data: data)
            }
        }
        return nil
    }
    
    /**
     * 根据粘贴板内容获取对应的历史记录
     * @param {NSPasteboardItem} item   粘贴板内容
     * @returns {PasteItem} 如果此粘贴板内容在历史中已记录过，则返回记录的第一条数据，否则返回nil
     */
    private func getExistHistoryItem(_ item: NSPasteboardItem) -> PasteItem? {
        guard let itemHash = getPasteItemHash(item) else {
            return nil
        }
        let predicate = NSPredicate(format: "data_hash = %@", itemHash)
        let saveContext = CoreDataManager.shared.viewContext
        let fetchRequest: NSFetchRequest<PasteItem> = PasteItem.fetchRequest()
        fetchRequest.predicate = predicate
        fetchRequest.returnsObjectsAsFaults = false
        let pasteItems = try? saveContext.fetch(fetchRequest);
        return pasteItems?.first
    }
    
    /**
     * 从粘贴板内容新增一条历史记录
     * @param {NSPasteboardItem} item   粘贴板内容
     * @returns {PasteItem} 返回新创建的历史记录，不支持则返回nil
     */
    private func createNewHistoryItem(_ item: NSPasteboardItem) -> PasteItem? {
        let ctx = CoreDataManager.shared.viewContext
        guard let typeData = getShownTypeData(item),
              let itemHash = getPasteItemHash(item) else {
            return nil
        }
        
        let pasteItem = PasteItem(context: ctx)
        pasteItem.updated_at = Date()
        pasteItem.favorite = false
        pasteItem.data = typeData.data
        pasteItem.type = typeData.type.rawValue
        if item.types.contains(.string) {
            pasteItem.value = item.string(forType: .string)
        }
        item.types.forEach { (type) in
            guard let data = item.data(forType: type) else {
                return
            }
            let contentItem = PasteItemContent(context: ctx)
            contentItem.type = type.rawValue
            contentItem.data = data
            pasteItem.addToContents(contentItem)
        }
        print("new pasteitem with hash:", itemHash)
        pasteItem.data_hash = itemHash
        try! ctx.save()
        return pasteItem
    }
    
    private func updateItemDate(_ pasteItem: PasteItem) -> PasteItem {
        pasteItem.updated_at = Date()
        try! pasteItem.managedObjectContext?.save()
        return pasteItem
    }
    
    private func changeHandler() {
        pasteboard.pasteboardItems?.forEach({ (item) in
            itemHandler(item)
        })
    }
    
    private func itemHandler(_ pasteItem: NSPasteboardItem) {
//        print("item hash:", getPasteItemHash(pasteItem))
        if let existsItem = getExistHistoryItem(pasteItem) {
            print("update item")
            // 历史中存在此项目，则只更新时间
            let _ = updateItemDate(existsItem)
        } else {
            print("create item")
            let _ = createNewHistoryItem(pasteItem)
        }
        NotificationCenter.default.post(
            name: PasteboardHandler.historyUpdateNotification,
            object: nil,
            userInfo: nil
        )
    }
    
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
    
    func writeToPasteboard(historyItem: PasteItem) {
        if (historyItem.type == "text") {
            pasteboard.declareTypes([.string], owner: nil)
            pasteboard.setString(historyItem.value!, forType: .string)
        } else {
            pasteboard.clearContents()
            let contents = historyItem.contents?.allObjects as! [PasteItemContent]
            let types = contents.map({ (content) -> NSPasteboard.PasteboardType in
                NSPasteboard.PasteboardType(content.type!)
            })
            pasteboard.declareTypes(types, owner: nil)
            contents.forEach({ (content) in
                pasteboard.setData(content.data, forType: .init(content.type!))
            })
        }
    }
    
    func triggerPaste() {
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
        DispatchQueue.main.async {
            self.triggerPaste()
        }
    }
    
    @objc
    func clearHistory(_ sender: Any?) {
        print("clear")
        let ctx = CoreDataManager.shared.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "PasteItem")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try! ctx.execute(deleteRequest)
        NotificationCenter.default.post(
            name: PasteboardHandler.historyUpdateNotification,
            object: nil,
            userInfo: nil
        )
    }
    
    static let shared = PasteboardHandler()
}


