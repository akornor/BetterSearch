//
//  AppDelegate.swift
//  BetterSearch
//
//  Created by Raymond Akornor on 6/22/19.
//  Copyright © 2019 FiniteLoop. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    var eventMonitor: EventMonitor?
    let popoverView = NSPopover()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem.button?.image = NSImage(named: NSImage.Name("logo"))
        statusItem.button?.target = self
        statusItem.button?.action = #selector(showApp)
        
        popoverView.contentViewController = ViewController.getViewController()
        
        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            if let strongSelf = self, strongSelf.popoverView.isShown {
                strongSelf.closePopover(sender: event)
            }
        }
        let firstRun = UserDefaults.standard.bool(forKey: "firstRun")
        if (!firstRun && !development){
            NSLog("Indexing messages...")
            try! DataStore.shared.db?.execute("""
                CREATE VIRTUAL TABLE IF NOT EXISTS MessageSearch USING fts5(guid UNINDEXED, text, date UNINDEXED, handle_id UNINDEXED);
                INSERT INTO MessageSearch SELECT guid, text, date, handle_id FROM message;
                -- Triggers to keep the message index up to date.
                CREATE TRIGGER IF NOT EXISTS update_message_index AFTER INSERT ON message BEGIN
                  INSERT INTO MessageSearch(guid, text, date, handle_id) VALUES (new.guid, new.text, new.date, new.handle_id);
                END;
            """)
            UserDefaults.standard.set(true, forKey: "firstRun")
        }
    }
    
    @objc func showApp() {
        if popoverView.isShown{
            closePopover(sender: nil)
        }else{
            guard let button = statusItem.button else {
                fatalError("Unable to find status item button.")
            }
            popoverView.behavior = .transient
            popoverView.animates = false
            popoverView.show(relativeTo: button.bounds, of: button, preferredEdge: .maxY)
            eventMonitor?.start()
        }
    }
    
    func closePopover(sender: Any?) {
        popoverView.performClose(sender)
        eventMonitor?.stop()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    
}

