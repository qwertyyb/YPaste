//
//  ViewController.swift
//  YPaste
//
//  Created by 虚幻 on 2019/9/5.
//  Copyright © 2019 qwertyyb. All rights reserved.
//

import Cocoa
import HotKey

class ViewController: NSViewController {
    
    var selectedPasteItem: PasteItem?
    @objc let managedObjectContext: NSManagedObjectContext
    override var acceptsFirstResponder: Bool { return true }

    
    required init?(coder: NSCoder) {
        self.managedObjectContext = (NSApp.delegate as! AppDelegate).persistentContainer.viewContext
        super.init(coder: coder)
        ValueTransformer.setValueTransformer(SummaryTransformer(), forName: .summaryTransformerName)
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "fetchPredicateChanged"), object: nil, queue: nil) { (notification) in
            self.tableView.scrollRowToVisible(0)
        }
        NotificationCenter.default.addObserver(forName: PasteboardHandler.changeNotification, object: nil, queue: nil) { (notification) in
            self.arrayController.resetPage()
        }
    }

    @objc let sortByUpdateTime = [NSSortDescriptor(key: "updated_at", ascending: false)]
    
    func app() -> AppDelegate {
        return NSApplication.shared.delegate as! AppDelegate
    }
    
    @IBOutlet weak var searchField: NSSearchField!
    @IBOutlet var arrayController: PasteItemsController!
    
    override func viewWillAppear() {
        arrayController.resetPage()
        tableView.scrollRowToVisible(0)
        arrayController.setSelectionIndex(0)
    }
    
    override func viewDidDisappear() {
        arrayController.fetchPredicate = nil
    }
    
    @IBOutlet weak var tableView: NSTableView!
    @IBAction func tableViewClicked(_ sender: Any) {
        let pasteItems = arrayController.selectedObjects as? [PasteItem]
        if (pasteItems == nil) { return }
        PasteboardHandler.shared.paste(pasteItem: (pasteItems?.first)!)
    }
    override func keyUp(with event: NSEvent) {
        let key = Key(carbonKeyCode: UInt32(event.keyCode))
        if key == Key.return {
            let pasteItems = arrayController.selectedObjects as? [PasteItem]
            if (pasteItems == nil) { return }
            PasteboardHandler.shared.paste(pasteItem: (pasteItems?.first)!)
        }
        if key == Key.downArrow {
        }
    }

}
