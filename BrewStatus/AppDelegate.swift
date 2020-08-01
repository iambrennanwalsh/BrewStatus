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
  
  // Defer expensive menu initialization until it's needed.
  lazy var serviceMenu: NSMenu = {
    return ServiceMenu()
  }()

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    if let button = statusItem!.button {
      button.image = NSImage(named: "MenuIcon")
      button.image?.isTemplate = true
      button.action = #selector(initServiceMenu(_:))
    }
  }
    
  @objc func initServiceMenu(_ sender: NSStatusBarButton) {
    statusItem!.menu = serviceMenu
    statusItem!.button!.performClick(self)
  }
    
}
