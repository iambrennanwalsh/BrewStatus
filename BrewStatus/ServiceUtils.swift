//
//  ServiceUtils.swift
//  BrewStatus
//
//  Created by Brennan Walsh
//  mail@brennanwal.sh
//  @iambrennanwalsh
//

import Foundation

class ServiceUtils {
  
  // Parses and hydrates and returns all services.
  // Should be passed stdout from a "brew services list" command.
  static func hydrateServices(data: String) -> [Service] {
    let string = data.trimmingCharacters(in: CharacterSet.newlines)
    let services = string.components(separatedBy: "\n")
    return services[1..<services.count].map({(service) -> Service in
      let parts = service.components(separatedBy: " ").filter() { $0 != "" }
      return Service(
        name: parts[0],
        state: parts.count == 4 ? Service.Status.running : Service.Status.stopped
      )
    })
  }
}
