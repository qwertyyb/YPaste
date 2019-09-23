//
//  ViewController.swift
//  YPaste
//
//  Created by 虚幻 on 2019/9/5.
//  Copyright © 2019 qwertyyb. All rights reserved.
//

import Cocoa
import HotKey

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
    
    @IBOutlet var arrayController: NSArrayController!

    override func viewDidLoad() {
        arrayController.selectsInsertedObjects = true
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var tableView: NSTableView!
    
    override func viewDidAppear() {
        arrayController.fetch(self)
        arrayController.setSelectionIndex(0)
    }
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
    }
}

