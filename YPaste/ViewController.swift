//
//  ViewController.swift
//  YPaste
//
//  Created by 虚幻 on 2019/9/5.
//  Copyright © 2019 qwertyyb. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    var pasteItems: [PasteItem] = []
    @objc let managedObjectContext: NSManagedObjectContext
    
    required init?(coder: NSCoder) {
        self.managedObjectContext = (NSApp.delegate as! AppDelegate).persistentContainer.viewContext
        super.init(coder: coder)
    }
    
    func app() -> AppDelegate {
        return NSApplication.shared.delegate as! AppDelegate
    }
    
//    lazy var managedObjectContext: NSManagedObjectContext = {
//        return app().persistentContainer.viewContext
//    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pasteItem = PasteItem(context: app().persistentContainer.viewContext)
        pasteItem.type = "text"
        pasteItem.value = "我是你爸爸"
        pasteItem.updated_at = Date()
        try! pasteItem.managedObjectContext!.save()
        
        
        let fetchRequest = NSFetchRequest<PasteItem>(entityName: "PasteItem")
        self.pasteItems = try! app().persistentContainer.viewContext.fetch(fetchRequest)

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

