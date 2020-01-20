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
    
    override init(content: Any?) {
        super.init(content: content)
    }
    
    override var arrangedObjects: Any {
        get {
            if (HotkeyHandler.shared.openType == .order) {
                return PasteboardHandler.shared.orderedItems.map { (objectId) -> PasteItem in
                    return self.managedObjectContext?.object(with: objectId) as! PasteItem
                }
            }
            return super.arrangedObjects
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        NotificationCenter.default.addObserver(self, selector: #selector(fetchNextPage), name: Notification.Name(rawValue: "scrollerview-ToReachBottom"), object: nil)
        self.addObserver(self, forKeyPath: "fetchPredicate", options: [.new], context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(remove(_:)), name: TableView.rowRemovedNotification, object: nil)
        NotificationCenter.default.addObserver(forName: PasteboardHandler.changeNotification, object: nil, queue: nil) { (notification) in
            self.resetPage()
        }
        
        managedObjectContext = (NSApp.delegate as! AppDelegate).persistentContainer.viewContext
        sortDescriptors = [NSSortDescriptor(key: "updated_at", ascending: false)]
    }
    
    var page = 1
    var total: Int {
        get {
            return try! (managedObjectContext?.count(for: defaultFetchRequest()))!
        }
    }
    
    override func fetch(with fetchRequest: NSFetchRequest<NSFetchRequestResult>?, merge: Bool) throws {
        fetchRequest?.fetchOffset = 0
        fetchRequest?.fetchLimit = page * 30
        try! super.fetch(with: fetchRequest, merge: merge)
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
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "fetchPredicate") {
            self.resetPage()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "fetchPredicateChanged"), object: nil)
        }
    }
    
    override func defaultFetchRequest() -> NSFetchRequest<NSFetchRequestResult> {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = super.defaultFetchRequest()
        if HotkeyHandler.shared.openType == .favorite {
            var predicate = fetchRequest.predicate
            if predicate != nil {
                let origin = predicate!.predicateFormat
                predicate = NSPredicate(format: "\(origin) and favorite = 1")
            } else {
                predicate = NSPredicate(format: "favorite = 1")
            }
            fetchRequest.predicate = predicate
        }
        return fetchRequest
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
}
