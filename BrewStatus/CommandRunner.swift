//
//  CommandRunner.swift
//  BrewStatus
//
//  Created by Brennan Walsh
//  mail@brennanwal.sh
//  @iambrennanwalsh
//

import Cocoa

class CommandRunner {
    
  let brew = "/usr/local/bin/brew"
  
  // Updates a service.
  func run(args: [String]) -> [Service] {
    let task = Process()
    task.launchPath = brew
    task.arguments = args
    task.launch()
    task.waitUntilExit()
    if task.terminationStatus != 0 {
      let alert = NSAlert.init()
      alert.alertStyle = .critical
      alert.messageText = "Could not \(args[1]) \(args[2])"
      alert.informativeText = "You will need to manually resolve the issue."
      alert.runModal()
      return []
    }
    return getServices()
  }
  
  // Runs brew services list.
  func getServices() -> [Service] {
    let launchPath = brew
    if FileManager.default.isExecutableFile(atPath: launchPath) {
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
        let rawServices = string.components(separatedBy: "\n")
        return rawServices[1..<rawServices.count].map(parseService)
      }
    }
    return []
  }

  // Parses the output of "brew services list" and returns an array of Services.
  func parseService(_ raw:String) -> Service {
    let parts = raw.components(separatedBy: " ").filter() { $0 != "" }
    return Service(
      name: parts[0],
      state: parts.count >= 2 && parts[1] == "started" ? Service.Status.running : parts[1] == "stopped" ? Service.Status.stopped : Service.Status.stopped
    )
  }
}
