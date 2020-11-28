//
//  AppDelegate.swift
//  YPaste
//
//  Created by 虚幻 on 2019/9/5.
//  Copyright © 2019 qwertyyb. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    lazy var app = YPaste.shared
    
    lazy var coreDataManager = CoreDataManager()

    private var statusItem :NSStatusItem? = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    let preferencesWindowController = PreferencesWindowController.init(windowNibName: NSNib.Name(NSString("Preferences")))
    
    @IBOutlet weak var menu: NSMenu!
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSApp.appearance = NSAppearance(named: .aqua)
//        app = YPaste.shared
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
            app.autoLaunch(active: true)
        }
    }
    
    @IBAction func openPreferences(_ sender: AnyObject?) {
        preferencesWindowController.showWindow(self)
    }
    
    @IBAction func openMainWindow(_ sender: AnyObject?) {
        app.mainWindowController.openWindow()
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        // Save changes in the application's managed object context before the application terminates.
        let context = CoreDataManager.shared.bgContext
        
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

