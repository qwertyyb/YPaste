//
//  PasteItemsController.swift
//  YPaste
//
//  Created by marchyang on 2019/10/21.
//  Copyright © 2019 qwertyyb. All rights reserved.
//

import Cocoa

class PasteItemsController: NSArrayController {
    
    static let selectionChange = Notification.Name(rawValue: "selectionChange")
    static let totalChange = Notification.Name(rawValue: "totalChange")
    
    override init(content: Any?) {
        super.init(content: content)

        managedObjectContext = CoreDataManager.shared.bgContext
        sortDescriptors = [NSSortDescriptor(key: "updated_at", ascending: false)]
        entityName = "PasteItem"
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(fetchNextPage),
            name: MainView.reachBottomNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            forName: PasteboardHandler.historyUpdateNotification,
            object: nil,
            queue: nil) { (notification) in
            self.resetPage()
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    var page = 1
    @objc var total: Int {
        get {
            return try! (managedObjectContext?.count(for: defaultFetchRequest()))!
        }
    }
    
    override func fetch(with fetchRequest: NSFetchRequest<NSFetchRequestResult>?, merge: Bool) throws {
        fetchRequest?.fetchOffset = 0
        fetchRequest?.fetchLimit = page * 30
        try! super.fetch(with: fetchRequest, merge: merge)
        NotificationCenter.default.post(name: PasteItemsController.totalChange, object: nil)
    }
    func resetPage () {
        page = 1
        self.fetch(nil)
    }
    @objc func fetchNextPage() {
        if (arrangedObjects as! [PasteItem]).count >= self.total {
            return
        }
        page += 1
        self.fetch(nil)
    }
    
    override func remove(_ sender: Any?) {
        let selectedIndex = self.selectionIndex
        if selectedObjects != nil  && selectedObjects!.count > 0 {
            let pasteItems = selectedObjects as! [PasteItem]
            self.managedObjectContext?.mergePolicy = NSMergePolicy.overwrite
            self.managedObjectContext?.delete(pasteItems[0])
            try! self.managedObjectContext?.save()
            self.setSelectionIndex(selectedIndex)
        }
    }
    
    func favoriteItem(pasteItem: PasteItem, favorite: Bool? = true) {
        self.managedObjectContext?.mergePolicy = NSMergePolicy.overwrite
        pasteItem.favorite = favorite!
        try! self.managedObjectContext?.save()
        fetch(nil)
    }
    
    func deleteItem(pasteItem: PasteItem) {
        self.managedObjectContext?.mergePolicy = NSMergePolicy.overwrite
        self.managedObjectContext?.delete(pasteItem)
        try! self.managedObjectContext?.save()
        fetch(nil)
    }
    
    static let shared = PasteItemsController()
}
