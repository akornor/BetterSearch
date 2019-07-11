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
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var eventMonitor: EventMonitor?
    let popoverView = NSPopover()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem.button?.title = "🕹"
        statusItem.button?.target = self
        statusItem.button?.action = #selector(showSettings)
        
        popoverView.contentViewController = ViewController.getFreshController()
        
        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            if let strongSelf = self, strongSelf.popoverView.isShown {
                strongSelf.closePopover(sender: event)
            }
        }
    }
    
    @objc func showSettings() {
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

