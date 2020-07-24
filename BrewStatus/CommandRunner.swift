//
//  CommandRunner.swift
//  BrewServices
//
//  Created by Brennan Walsh on 7/23/20.
//  Copyright © 2020 Brennan Walsh. All rights reserved.
//

import Cocoa

class CommandRunner {
    
    let brewExecutableKey = "brewExecutable"
    
    init() {
        UserDefaults.standard.register(defaults: [
            brewExecutableKey: "/usr/local/bin/brew"
        ])
    }
    
    func controlService(_ name:String, state:String) -> [Service] {
        let task = Process()
        task.launchPath = self.brewExecutable()
        task.arguments = ["services", state, name]

        task.launch()
        task.waitUntilExit()

        if task.terminationStatus != 0 {
            let alert = NSAlert.init()
            alert.alertStyle = .critical
            alert.messageText = "Could not \(state) \(name)"
            alert.informativeText = "You will need to manually resolve the issue."
            alert.runModal()
        }
        return self.serviceStates()
    }
    
    func serviceStates() -> [Service] {
        let launchPath = self.brewExecutable()
        if !FileManager.default.isExecutableFile(atPath: launchPath) {
            return []
        }
        let task = Process()
        let outpipe = Pipe()
        task.launchPath = launchPath
        task.arguments = ["services", "list"]
        task.standardOutput = outpipe

        task.launch()
        let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
        task.waitUntilExit()

        if task.terminationStatus != 0 {
            return []
        }

        if var string = String(data: outdata, encoding: String.Encoding.utf8) {
            string = string.trimmingCharacters(in: CharacterSet.newlines)
            return parseServiceList(string)
        }

        return []
    }

    func parseServiceList(_ raw: String) -> [Service] {
        let rawServices = raw.components(separatedBy: "\n")
        return rawServices[1..<rawServices.count].map(parseService)
    }

    func parseService(_ raw:String) -> Service {
        let parts = raw.components(separatedBy: " ").filter() { $0 != "" }
        return Service(
            name: parts[0],
            state: parts.count >= 2 ? parts[1] : "unknown",
            user: parts.count >= 3 ? parts[2] : ""
        )
    }
    
    func brewExecutable() -> String {
        return UserDefaults.standard.string(forKey: brewExecutableKey)!
    }
}
