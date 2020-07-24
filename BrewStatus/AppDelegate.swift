//
//  AppDelegate.swift
//  BrewStatus
//
//  Created by Brennan Walsh
//  mail@brennanwal.sh
//  @iambrennanwalsh
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {

    var statusItem: NSStatusItem?
    var serviceMenu: NSMenu?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        serviceMenu = ServiceMenu()
        statusItem!.button!.image = NSImage(named: "MenuIcon")
        statusItem!.button!.image?.isTemplate = true
        statusItem!.menu = serviceMenu
    }
    
}
