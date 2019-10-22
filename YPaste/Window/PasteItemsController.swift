//
//  PasteItemsController.swift
//  YPaste
//
//  Created by marchyang on 2019/10/21.
//  Copyright © 2019 qwertyyb. All rights reserved.
//

import Cocoa

class PasteItemsController: NSArrayController {
    override init(content: Any?) {
        super.init(content: content)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        NotificationCenter.default.addObserver(self, selector: #selector(fetchNextPage), name: Notification.Name(rawValue: "scrollerview-ToReachBottom"), object: nil)
        self.addObserver(self, forKeyPath: "fetchPredicate", options: [.new], context: nil)
    }
    
    var page = 1
    var total: Int {
        get {
            return try! (managedObjectContext?.count(for: defaultFetchRequest()))!
        }
    }
    
    override func fetch(with fetchRequest: NSFetchRequest<NSFetchRequestResult>?, merge: Bool) throws {
        if fetchRequest != nil {
            fetchRequest?.fetchOffset = 0
            fetchRequest?.fetchLimit = page * 30
            var predicate = fetchRequest?.predicate
            if predicate != nil {
                let origin = predicate!.predicateFormat
                predicate = NSPredicate(format: "\(origin) and favorite = \(NSNumber.init(booleanLiteral: HotkeyHandler.shared.openType == .favorite))")
            } else {
                predicate = NSPredicate(format: "favorite = \(NSNumber.init(booleanLiteral: HotkeyHandler.shared.openType == .favorite))")
            }
            fetchRequest?.predicate = predicate
        }
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
}
