//
//  ServiceMenu.swift
//  BrewStatus
//
//  Created by Brennan Walsh
//  mail@brennanwal.sh
//  @iambrennanwalsh
//

import Cocoa

class ServiceMenu: NSMenu {
  
  let commandRunner = CommandRunner()
    
  var services: [Service] = [] {
    willSet { // This property observer repopulates the menu, when the services array is changed.
      removeAllItems()
      addHomebrewServicesMenuItem()
      newValue.isEmpty ? addNoServicesMenuItem() : populateMenu(newValue)
    }
  }
  
  init() {
    super.init(title: "")
    addLoadingMenuItem()
    addQuitMenuItem()
    runAsync({() -> [Service] in
      return self.commandRunner.getServices()
    })
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // Overriden to easily ensure all menu items have a proper target.
  override func addItem(_ newItem: NSMenuItem) {
    newItem.target = self
    super.addItem(newItem)
  }
  
  // Adds the "loading..." menu item at index 0.
  func addLoadingMenuItem() {
    let loadItem = NSMenuItem.init(title: "Loading...", action: nil, keyEquivalent: "")
    loadItem.isEnabled = false
    loadItem.tag = 1
    addItem(.separator())
    insertItem(loadItem, at: 0)
  }
  
  // Adds the "Homebrew Services" menu item.
  func addHomebrewServicesMenuItem() {
    let brewItem = NSMenuItem.init(title: "Homebrew Services", action: nil, keyEquivalent: "")
    brewItem.isEnabled = false
    brewItem.tag = 4
    addItem(brewItem)
    addItem(.separator())
  }
  
  // Adds the "No services found..." menu item.
  func addNoServicesMenuItem() {
    let noServicesItem = NSMenuItem.init(title: "No services available", action: nil, keyEquivalent: "")
    noServicesItem.isEnabled = false
    addItem(noServicesItem)
  }
  
  // Adds the "quit" menu item.
  func addQuitMenuItem() {
    let quitItem = NSMenuItem(title: "Quit", action: #selector(handleQuit(_:)), keyEquivalent: "q")
    quitItem.tag = 3
    addItem(.separator())
    addItem(quitItem)
  }
  
  // Adds the "start/stop" service menu items.
  func addServiceMenuItems(_ service: Service) {
    let item = NSMenuItem(title: service.name, action: #selector(handleOne(_:)), keyEquivalent: "")
    item.state = service.state == .running ? .on : service.state == .stopped ? .off : .mixed
    item.representedObject = service
    item.tag = 2
    addItem(item)
    addServiceMenuAlternates(service, item)
  }
  
  // Adds the hidden "restart" service menu items.
  func addServiceMenuAlternates(_ service: Service, _ menuItem: NSMenuItem) {
    let altItem = NSMenuItem(title: "Restart " + service.name, action: #selector(handleOne(_:)), keyEquivalent: "")
    altItem.tag = 2
    altItem.representedObject = service
    altItem.state = menuItem.state
    altItem.isAlternate = true
    altItem.isHidden = true
    altItem.keyEquivalentModifierMask = NSEvent.ModifierFlags.option
    addItem(altItem)
  }
  
  // Adds the "start/stop/restart all" menu items.
  func addStartStopAndRestartMenuItems() {
    addItem(NSMenuItem(title: "Start all", action:#selector(handleAll(_:)), keyEquivalent: ""))
    addItem(NSMenuItem(title: "Stop all", action:#selector(handleAll(_:)), keyEquivalent: ""))
    addItem(NSMenuItem(title: "Retart all", action:#selector(handleAll(_:)), keyEquivalent: ""))
  }
  
  // Populates the service menu items.
  func populateMenu(_ services: [Service]) {
    for service in services {
      addServiceMenuItems(service)
    }
    addItem(.separator())
    addStartStopAndRestartMenuItems()
    addQuitMenuItem()
  }
  
  // Runs a passed closure asynchrously in another thread.
  func runAsync(_ command: @escaping () -> [Service]) {
    DispatchQueue.global(qos: .userInitiated).async {
      self.services = command()
    }
  }
  
  // Quits the application.
  @objc func handleQuit(_ sender: NSMenuItem) {
    NSApp.terminate(nil)
  }
   
  // Start/Stop/Restart one service.
  @objc func handleOne(_ sender: NSMenuItem) {
    addLoadingMenuItem()
    runAsync({ () -> [Service] in
      let state = sender.isAlternate ? "restart" : sender.state == .on ? "stop" : "start"
      return self.commandRunner.run(args: ["services", state, sender.title])
    })
  }

  // Start/Stop/Restart all services.
  @objc func handleAll(_ sender: NSMenuItem) {
    addLoadingMenuItem()
    runAsync({ () -> [Service] in
      let state = sender.title == "Retart all" ? "restart" : sender.title == "Stop all" ? "stop" : "start"
      return self.commandRunner.run(args: ["services", state, "--all"])
    })
  }
  
}
