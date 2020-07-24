//
//  AppDelegate.swift
//  BrewStatus
//
//  Created by Brennan Walsh
//  mail@brennanwal.sh
//  @iambrennanwalsh
//

import Cocoa

class ServiceMenu: NSMenu {
    
    let commandRunner = CommandRunner()
    var services: [Service]?
    
    init() {
        super.init(title: "")
        populateMenu(refresh: true)
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                sleep(3)
                self.services = self.commandRunner.serviceStates()
            }
            DispatchQueue.main.async {
                self.populateMenu(refresh: false)
            }
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func addItem(_ newItem: NSMenuItem) {
        newItem.target = self
        super.addItem(newItem)
    }
    
    func refreshMenuItem() {
        addItem(.separator())
        let item = NSMenuItem.init(title: "Refreshing...", action: nil, keyEquivalent: "")
        item.isEnabled = false
        item.onStateImage = NSImage(named: "statusAvailableName")
        addItem(item)
    }
    
    func quitMenuItem() {
        addItem(.separator())
        let quit = NSMenuItem(title: "Quit", action: #selector(handleQuit(_:)), keyEquivalent: "q")
        addItem(quit)
    }
    
    func serviceMenuItems() {
        if let services = services {
            for service in services {
                let item = NSMenuItem.init(title: service.name, action: nil, keyEquivalent: "")
                item.state = service.state == "started" ? .on : service.state == "stopped" ? .off : .mixed
                if item.state == .mixed || service.user != "" && service.user != NSUserName() {
                    item.isEnabled = false
                } else {
                    item.action = #selector(handleOne(_:))
                }
                item.tag = 99
                addItem(item)
                let altItem = NSMenuItem.init(title: "Restart "+service.name, action: #selector(handleRestartOne(_:)), keyEquivalent: "")
                altItem.representedObject = service
                altItem.state = item.state
                altItem.isEnabled = item.isEnabled
                altItem.isAlternate = true
                altItem.isHidden = true
                altItem.keyEquivalentModifierMask = NSEvent.ModifierFlags.option
                addItem(altItem)
            }
            if services.count == 0 {
                let item = NSMenuItem.init(title: "No services available", action: nil, keyEquivalent: "")
                item.isEnabled = false
                addItem(item)
            } else {
                addItem(.separator())
                addItem(.init(title: "Start all", action:#selector(handleAll(_:)), keyEquivalent: "s"))
                addItem(.init(title: "Stop all", action:#selector(handleAll(_:)), keyEquivalent: "x"))
                addItem(.init(title: "Restart all", action:#selector(handleRestartAll(_:)), keyEquivalent: "r"))
            }
        }
    }
    
    func populateMenu(refresh: Bool) {
        removeAllItems()
        if refresh {
            refreshMenuItem()
            quitMenuItem()
        } else {
            serviceMenuItems()
            quitMenuItem()
        }
    }
    
    func runAsync(_ commandOne: @escaping () -> [Service]) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.services = commandOne()
            DispatchQueue.main.async {
                self.populateMenu(refresh: false)
            }
        }
    }
    
    @objc func handleQuit(_ sender: NSMenuItem) {
        NSApp.terminate(nil)
    }
    
    @objc func handleOne(_ sender: NSMenuItem) {
        runAsync { () -> [Service] in
            sender.state = sender.state == .on ? .off : .on
            let state = sender.state == .on ? "start" : "stop"
            return self.commandRunner.controlService(sender.title, state: state)
        }
    }

    @objc func handleRestartOne(_ sender: NSMenuItem) {
        runAsync { () -> [Service] in
            let service = sender.representedObject as! Service
            return self.commandRunner.controlService(service.name, state: "restart")
        }
    }

    @objc func handleAll(_ sender: NSMenuItem) {
        let state: [NSControl.StateValue] = sender.title == "Start all" ? [.off, .on] : [.on, .off]
        let stringState = state[0] == .off ? "start" : "stop"
        for item in self.items {
            if item.tag == 99 && item.state == state[0] || item.isAlternate {
                item.state = state[1]
            }
        }
        runAsync { () -> [Service] in
            return self.commandRunner.controlService("--all", state: stringState)
        }
    }

    @objc func handleRestartAll(_ sender: NSMenuItem) {
        runAsync { () -> [Service] in
            return self.commandRunner.controlService("--all", state: "restart")
        }
    }
    
}
