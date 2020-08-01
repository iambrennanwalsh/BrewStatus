//
//  Service.swift
//  BrewStatus
//
//  Created by Brennan Walsh
//  mail@brennanwal.sh
//  @iambrennanwalsh
//

import Foundation

struct Service {
  let name: String
  var state: Status?
  
  enum Status{
    case running
    case stopped
  }
}
