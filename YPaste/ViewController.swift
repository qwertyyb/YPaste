//
//  ViewController.swift
//  YPaste
//
//  Created by 虚幻 on 2019/9/5.
//  Copyright © 2019 qwertyyb. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTableViewDelegate {
    
    var selectedPasteItem: PasteItem?
    @objc let managedObjectContext: NSManagedObjectContext
    override var acceptsFirstResponder: Bool { return true }
    
    required init?(coder: NSCoder) {
        self.managedObjectContext = (NSApp.delegate as! AppDelegate).persistentContainer.viewContext
        super.init(coder: coder)
        ValueTransformer.setValueTransformer(SummaryTransformer(), forName: .summaryTransformerName)
    }

    @objc let sortByUpdateTime = [NSSortDescriptor(key: "updated_at", ascending: false)]
    
    func app() -> AppDelegate {
        return NSApplication.shared.delegate as! AppDelegate
    }
    
    @IBOutlet weak var searchField: NSSearchField!
    @IBOutlet var arrayController: NSArrayController!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear() {
        tableView.scrollRowToVisible(0)
        arrayController.setSelectionIndex(0)
    }
    
    override func viewDidDisappear() {
        arrayController.filterPredicate = nil
    }
    
    @IBOutlet weak var tableView: NSTableView!
    @IBAction func tableViewClicked(_ sender: Any) {
        let pasteItems = arrayController.selectedObjects as? [PasteItem]
        if (pasteItems == nil) { return }
        app().app.paste(pasteItem: (pasteItems?.first)!)
    }
    override func keyDown(with event: NSEvent) {
        let key = Key(carbonKeyCode: UInt32(event.keyCode))
        if key == Key.return {
            let pasteItems = arrayController.selectedObjects as? [PasteItem]
            if (pasteItems == nil) { return }
            app().app.paste(pasteItem: (pasteItems?.first)!)
        }
        if key == Key.downArrow {
            
        }
    }
}

