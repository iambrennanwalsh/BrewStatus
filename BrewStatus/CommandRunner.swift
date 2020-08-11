//
//  CommandRunner.swift
//  BrewStatus
//
//  Created by Brennan Walsh
//  mail@brennanwal.sh
//  @iambrennanwalsh
//

import Foundation

class CommandRunner {
    
  let brew = "/usr/local/bin/brew"
  
  // Runs a shell command.
  func command(args: [String]) {
    let task = Process()
    task.launchPath = brew
    task.arguments = args
    task.launch()
    task.waitUntilExit()
  }
  
  // Runs a shell command, and returns standard output.
  func pipedCommand(args: [String]) -> String {
    let task = Process()
    let pipe = Pipe()
    task.launchPath = brew
    task.arguments = args
    task.standardOutput = pipe
    task.launch()
    task.waitUntilExit()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    return String(data: data, encoding: String.Encoding.utf8)!
  }
  
}
