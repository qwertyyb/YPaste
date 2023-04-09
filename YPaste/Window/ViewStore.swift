//
//  ViewStore.swift
//  YPaste
//
//  Created by 虚幻 on 2023/4/9.
//  Copyright © 2023 qwertyyb. All rights reserved.
//

import Foundation

class ViewStore {
    private(set) var keyword: String = ""
    
    private var page: Int = 1
    private var size: Int = 10
    
    private(set) var total: Int = 0
    private(set) var list: [PasteItem] = []
    private(set) var selectedIndex: Int = 0
    
    var selected: PasteItem? {
        get {
            if selectedIndex >= 0 && selectedIndex < list.count {
                return list[selectedIndex]
            }
            return nil
        }
    }
    
    func setKeyword(_ value: String) {
        keyword = value
        page = 1
        selectedIndex = 0
        refresh()
    }
    
    func refresh(append: Bool = false) {
        var predicate: NSPredicate? = nil
        if keyword != "" {
            predicate = NSPredicate(format: "self.value contains[cd] %@", keyword)
        }
        let list = Store.shared
            .query(page: page, size: size, predicate: predicate)
        total = Store.shared.getTotal(predicate: predicate)
        if append {
            self.list += list
        } else {
            self.list = list
        }
        NotificationCenter.default.post(name: ViewStore.listChangedNotification, object: nil)
    }
    
    func nextPage() {
        let maxPage = Int(ceil(Double(total) / Double(size)))
        if page >= maxPage { return }
        page += 1
        refresh(append: true)
    }
    
    func prevPage() {
        if page <= 1 { return }
        page -= 1
        refresh()
    }
    
    func setSelectedIndex(_ index: Int) {
        if index < list.count {
            selectedIndex = index
            NotificationCenter.default.post(name: ViewStore.selectedChangedNotification, object: nil)
        }
    }
    
    func selectPrev() {
        if selectedIndex > 0 {
            setSelectedIndex(selectedIndex - 1)
        }
    }
    
    func selectNext() {
        if selectedIndex < list.count - 1 {
            setSelectedIndex(selectedIndex + 1)
        }
    }
    
    func remove(_ index: Int) {
        if index < list.count {
            Store.shared.remove(list[index])
            list.remove(at: index)
            // 删除后项目少于10个，刷新一下
            if (list.count < size) {
                self.refresh()
            } else {
                NotificationCenter.default.post(name: ViewStore.listChangedNotification, object: nil)
            }
        }
    }
    
    func removeSelected() {
        remove(selectedIndex)
    }
    
    @objc
    func reset() {
        page = 1
        selectedIndex = 0
        keyword = ""
        refresh()
    }
    
    func start() {
        observers.append(NotificationCenter.default.addObserver(self, selector: #selector(reset), name: Store.changedNotification, object: nil))
    }
    
    func pause() {
        observers.forEach { observer in
            NotificationCenter.default.removeObserver(observer)
        }
    }

    
    private var observers: [Any] = []
    private init() {
        refresh()
    }
    
    static let shared = ViewStore()
    
    static let listChangedNotification = Notification.Name("ViewStore.listChangedNotification")
    static let selectedChangedNotification = Notification.Name("ViewStore.selectedChangedNotification")
}
