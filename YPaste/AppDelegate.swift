//
//  AppDelegate.swift
//  YPaste
//
//  Created by 虚幻 on 2019/9/5.
//  Copyright © 2019 qwertyyb. All rights reserved.
//

import Cocoa
import RealmSwift

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var app: YPaste?

    private var statusItem :NSStatusItem? = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    let preferencesWindowController = PreferencesWindowController.init(windowNibName: NSNib.Name(NSString("Preferences")))
    
    func coreData2Realm() {
        let realm = try! Realm()
        
        let saveContext = self.persistentContainer.newBackgroundContext()
        let fetchRequest: NSFetchRequest<PasteItem> = PasteItem.fetchRequest()
        fetchRequest.returnsObjectsAsFaults = false
        let pasteItems = try! saveContext.fetch(fetchRequest);
        print(pasteItems.count)
        let mItems = pasteItems.map { (pasteItem) -> MPasteItem in
            return MPasteItem(value: [
                "type": pasteItem.type ?? "text",
                "value": pasteItem.value ?? "value",
                "favorite": pasteItem.favorite,
                "updated_at": pasteItem.updated_at ?? Date()
            ])
        }
        try! realm.write({ () -> Void in
            realm.deleteAll()
            realm.add(mItems)
        })
    }
    
    @IBOutlet weak var menu: NSMenu!
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem?.button!.image = NSImage(named: "statusImage")
        statusItem?.menu = menu
        
        ValueTransformer.setValueTransformer(SummaryTransformer(), forName: .summaryTransformerName)
        ValueTransformer.setValueTransformer(TimeTransformer(), forName: .timeTransformerName)
        
        let environments = ProcessInfo.processInfo.environment
        if environments["dont_check_permission_at_startup"] != "yes" {
            //  check permission
            let _ = PasteboardHandler.shared.checkAccess(prompt: true)
        }
        
        if UserDefaults.standard.bool(forKey: "launchAtLogin") {
            app?.autoLaunch(active: true)
        }
        
        // Inside your application(application:didFinishLaunchingWithOptions:)

        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 3,

            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 2) {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
//                    migration.enumerateObjects(ofType: MPasteItem.className()) { oldObject, newObject in
//                        // combine name fields into a single field
//                        oldObject!["favorite"] = false
////                        newObject!["fullName"] = "\(firstName) \(lastName)"
//                    }
                }
            })

        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config

        // Now that we've told Realm how to handle the schema change, opening the file
        // will automatically perform the migration
        _ = try! Realm()
        
//        coreData2Realm()
        
        app = YPaste.shared
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        
    }
    
    func applicationWillResignActive(_ notification: Notification) {
        NSApp.keyWindow?.close()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "YPaste")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error)")
            }
        })
        return container
    }()
    
    @IBAction func openPreferences(_ sender: AnyObject?) {
        preferencesWindowController.showWindow(self)
    }
    
    @IBAction func openMainWindow(_ sender: AnyObject?) {
        HotkeyHandler.shared.openType = .history
        app?.mainWindowController.openWindow()
    }
    @IBAction func openOrderPaste(_ sender: AnyObject?) {
        HotkeyHandler.shared.openType = .order
        PasteboardHandler.shared.orderedItems = []
        app?.mainWindowController.openWindow()
    }
    
    // MARK: - Core Data Saving and Undo support

    @IBAction func saveAction(_ sender: AnyObject?) {
        // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
        let context = persistentContainer.viewContext

        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing before saving")
        }
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Customize this code block to include application-specific recovery steps.
                let nserror = error as NSError
                NSApplication.shared.presentError(nserror)
            }
        }
    }

    func windowWillReturnUndoManager(window: NSWindow) -> UndoManager? {
        // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
        return persistentContainer.viewContext.undoManager
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        // Save changes in the application's managed object context before the application terminates.
        let context = persistentContainer.viewContext
        
        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing to terminate")
            return .terminateCancel
        }
        
        if !context.hasChanges {
            return .terminateNow
        }
        
        do {
            try context.save()
        } catch {
            let nserror = error as NSError

            // Customize this code block to include application-specific recovery steps.
            let result = sender.presentError(nserror)
            if (result) {
                return .terminateCancel
            }
            
            let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saves error question message")
            let info = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saves error question info");
            let quitButton = NSLocalizedString("Quit anyway", comment: "Quit anyway button title")
            let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
            let alert = NSAlert()
            alert.messageText = question
            alert.informativeText = info
            alert.addButton(withTitle: quitButton)
            alert.addButton(withTitle: cancelButton)
            
            let answer = alert.runModal()
            if answer == .alertSecondButtonReturn {
                return .terminateCancel
            }
        }
        // If we got here, it is time to quit.
        return .terminateNow
    }

}

