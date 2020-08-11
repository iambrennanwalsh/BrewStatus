//
//  ServiceMenu.swift
//  BrewStatus
//
//  Created by Brennan Walsh
//  mail@brennanwal.sh
//  @iambrennanwalsh
//

import AppKit

class ServiceMenu: NSMenu {
  
  let commandRunner = CommandRunner()
    
  var services: [Service] = [] {
    willSet { // This property observer repopulates the menu, when the services array is repopulated.
      removeAllItems()
      addHomebrewServicesMenuItem()
      newValue.isEmpty ? addNoServicesMenuItem() : populateMenu(newValue)
    }
  }
  
  init() {
    super.init(title: "")
    addMenuItemToTop()
    addQuitMenuItem()
    runAsync({() -> Void in
      let response = self.commandRunner.pipedCommand(args: ["services", "list"])
      DispatchQueue.main.async {
        self.services = ServiceUtils.hydrateServices(data: response)
      }
    })
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // Overriden to easily ensure all menu items have a target.
  override func addItem(_ newItem: NSMenuItem) {
    newItem.target = self
    super.addItem(newItem)
  }
  
  // Adds a menu item at index 0.
  // Used for the loading/starting/stopping/restarting menu items.
  func addMenuItemToTop(_ title: String = "Loading...") {
    let loadItem = NSMenuItem.init(title: title, action: nil, keyEquivalent: "")
    loadItem.isEnabled = false
    addItem(.separator())
    insertItem(loadItem, at: 0)
  }
  
  // Adds the "Homebrew Services" menu item.
  func addHomebrewServicesMenuItem() {
    let brewItem = NSMenuItem.init(title: "Homebrew Services", action: nil, keyEquivalent: "")
    brewItem.isEnabled = false
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
    addItem(.separator())
    addItem(quitItem)
  }
  
  // Adds the "start/stop" service menu items.
  func addServiceMenuItems(_ service: Service) {
    let item = NSMenuItem(title: service.name, action: #selector(handleOne(_:)), keyEquivalent: "")
    item.state = service.state == .running ? .on : .off
    item.representedObject = service
    addItem(item)
    addServiceMenuAlternates(service, item)
  }
  
  // Adds the hidden "restart" service menu items.
  func addServiceMenuAlternates(_ service: Service, _ menuItem: NSMenuItem) {
    let altItem = NSMenuItem(title: "Restart \(service.name)", action: #selector(handleRestartOne(_:)), keyEquivalent: "")
    altItem.representedObject = service
    altItem.state = menuItem.state
    altItem.isAlternate = true
    altItem.isHidden = true
    altItem.keyEquivalentModifierMask = NSEvent.ModifierFlags.option
    addItem(altItem)
  }
  
  // Adds the "start/stop/restart all" menu items.
  func addStartStopAndRestartMenuItems() {
    addItem(NSMenuItem(title: "Start all", action:#selector(handleStartAll(_:)), keyEquivalent: ""))
    addItem(NSMenuItem(title: "Stop all", action:#selector(handleStopAll(_:)), keyEquivalent: ""))
    addItem(NSMenuItem(title: "Restart all", action:#selector(handleRestartAll(_:)), keyEquivalent: ""))
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
  
  // Runs a passed closure asynchrously by passing it off to another thread.
  // Code that updates the UI must be done on the main thread.
  // Use DispatchQueue.main.async {} to move back into the main thread.
  func runAsync(_ command: @escaping () -> Void) {
    DispatchQueue.global(qos: .userInitiated).async {
      command()
    }
  }
  
  // Quits the application.
  @objc func handleQuit(_ sender: NSMenuItem) {
    NSApp.terminate(nil)
  }
  
  // Restarts all services and repopulates the services array.
  @objc func handleRestartAll(_ sender: NSMenuItem) {
    addMenuItemToTop("Restarting all...")
    runAsync({ () -> Void in
      self.commandRunner.command(args: ["services", "restart", "--all"])
      let response = self.commandRunner.pipedCommand(args: ["services", "list"])
      DispatchQueue.main.async {
        self.services = ServiceUtils.hydrateServices(data: response)
      }
    })
  }
  
  // Restarts a service.
  @objc func handleRestartOne(_ sender: NSMenuItem) {
    let service = sender.representedObject as! Service
    addMenuItemToTop("Restarting \(service.name)...")
    runAsync({ () -> Void in
      self.commandRunner.command(args: ["services", "restart", service.name])
      DispatchQueue.main.async {
        self.removeItem(at: 0)
      }
    })
  }
  
  // Starts/Stops a service.
  @objc func handleOne(_ sender: NSMenuItem) {
    let state = sender.state == .on
      ? ["Stopping", "stop", NSControl.StateValue.off]
      : ["Starting", "start", NSControl.StateValue.on];
    addMenuItemToTop("\(state[0]) \(sender.title)...")
    runAsync({ () -> Void in
      self.commandRunner.command(args: ["services", state[1] as! String, sender.title])
      DispatchQueue.main.async {
        sender.state = state[2] as! NSControl.StateValue
        var service = sender.representedObject as! Service
        service.toggleState()
        self.removeItem(at: 0)
      }
    })
  }

  // Starts all services and repopulates the services array.
  @objc func handleStartAll(_ sender: NSMenuItem) {
    addMenuItemToTop("Starting all...")
    runAsync({ () -> Void in
      self.commandRunner.command(args: ["services", "start", "--all"])
      let response = self.commandRunner.pipedCommand(args: ["services", "list"])
      DispatchQueue.main.async {
        self.services = ServiceUtils.hydrateServices(data: response)
      }
    })
  }
  
  // Stops all services and repopulates the services array.
  @objc func handleStopAll(_ sender: NSMenuItem) {
    addMenuItemToTop("Stopping all...")
    runAsync({ () -> Void in
      self.commandRunner.command(args: ["services", "stop", "--all"])
      let response = self.commandRunner.pipedCommand(args: ["services", "list"])
      DispatchQueue.main.async {
        self.services = ServiceUtils.hydrateServices(data: response)
      }
    })
  }
  
}
