//
//  InjectionErrors.swift
//  
//
//  Created by Andres Duque on 5/07/23.
//

import Foundation

enum InjectionErrors: Error {
    case abstractionAlreadyRegistered(abstractionName: String)
    case implementationsCouldNotBeCasted(abstractionName: String)
    case notAbstrationFound(abstractionName: String)
    
    var message: String {
        switch self {
        case .abstractionAlreadyRegistered(let abstractionName):
            return "'\(abstractionName)' it's already registered in container. The previously registered implementations can't be override, please make sure of register every abstraction just once"
        case .implementationsCouldNotBeCasted(let abstractionName):
            return "Something happened when trying to cast '\(abstractionName)'. Please make sure of register dependencies that successfully implement the '\(abstractionName)' protocol and make sure to add a valid dependency key"
        case .notAbstrationFound(let abstractionName):
            return "No registered abstraction found with the identifier '\(abstractionName)'"
        }
    }
}
