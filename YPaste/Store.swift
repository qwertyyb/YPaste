//
//  Store.swift
//  YPaste
//
//  Created by 虚幻 on 2023/4/9.
//  Copyright © 2023 qwertyyb. All rights reserved.
//

import Foundation
import AppKit
import CryptoKit

typealias PasteItemData = (type: NSPasteboard.PasteboardType, data: Data)

class Store {
    static let shared = Store()

    static let changedNotification = Notification.Name("Store.changedNotification")

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
    
    func addOrUpdateRecord(_ data: NSPasteboardItem) {
        var savedItem: PasteItem? = nil
        if let existsItem = getExistHistoryItem(data) {
            // 历史中存在此项目，则只更新时间
            savedItem = updateItemDate(existsItem)
        } else {
            savedItem = createNewHistoryItem(data)
        }
        if savedItem != nil {
            NotificationCenter.default.post(
                name: Store.changedNotification,
                object: nil,
                userInfo: nil
            )
        }
    }
    
    func getTotal(predicate: NSPredicate? = nil) -> Int {
        let ctx = CoreDataManager.shared.bgContext
        let fetchReqeust = PasteItem.fetchRequest()
        fetchReqeust.predicate = predicate
        return try! ctx.count(for: fetchReqeust)
    }
    
    func query(page: Int = 1, size: Int = 10, predicate: NSPredicate? = nil) -> [PasteItem] {
        let fetchRequest = PasteItem.fetchRequest()
        fetchRequest.fetchOffset = (page - 1) * size
        fetchRequest.fetchLimit = size
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "updated_at", ascending: false)]
        return try! CoreDataManager.shared.bgContext.fetch(fetchRequest)
    }
    
    @objc
    func remove(_ pasteItem: PasteItem) {
        let ctx = CoreDataManager.shared.bgContext
        ctx.mergePolicy = NSMergePolicy.overwrite
        ctx.delete(pasteItem)
        try! ctx.save()
        NotificationCenter.default.post(
            name: Store.changedNotification,
            object: nil,
            userInfo: nil
        )
    }
    
    @objc
    func clear() {
        let ctx = CoreDataManager.shared.bgContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try! ctx.execute(deleteRequest)
        NotificationCenter.default.post(
            name: Store.changedNotification,
            object: nil,
            userInfo: nil
        )
    }
    
    private let entityName = "PasteItem"
    
    private init() {}

    /**
     * 获取粘贴板内容的简介，用于显示在预览中
     * @param {NSPasteboardItem} item  粘贴板项目
     * @returns {(type: NSPasteboard.PasteboardType, data: Data)} 类型和内容，如果类型不在supportTypes列表中，则返回nil
     */
    private func getTypeData(_ item: NSPasteboardItem) -> PasteItemData? {
        for type in supportTypes {
            if let data = item.data(forType: type) {
                return (type: type, data: data)
            }
        }
        return nil
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
     * 根据粘贴板内容获取对应的历史记录
     * @param {NSPasteboardItem} item   粘贴板内容
     * @returns {PasteItem} 如果此粘贴板内容在历史中已记录过，则返回记录的第一条数据，否则返回nil
     */
    private func getExistHistoryItem(_ item: NSPasteboardItem) -> PasteItem? {
        guard let itemHash = getPasteItemHash(item) else {
            return nil
        }
        let predicate = NSPredicate(format: "data_hash = %@", itemHash)
        let saveContext = CoreDataManager.shared.bgContext
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
        let ctx = CoreDataManager.shared.bgContext
        guard let typeData = getTypeData(item),
              let itemHash = getPasteItemHash(item) else {
            return nil
        }
        
        let pasteItem = PasteItem(context: ctx)
        pasteItem.updated_at = Date()
        pasteItem.favorite = false
        pasteItem.data = typeData.data
        pasteItem.type = typeData.type.rawValue
        if item.types.contains(.string) {
            pasteItem.value = item.string(forType: .string)!
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
        pasteItem.data_hash = itemHash
        try! ctx.save()
        return pasteItem
    }
    
    private func updateItemDate(_ pasteItem: PasteItem) -> PasteItem {
        pasteItem.updated_at = Date()
        try! pasteItem.managedObjectContext?.save()
        return pasteItem
    }
}
