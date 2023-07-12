//
//  InjectionErrors.swift
//  
//
//  Created by Andres Duque on 5/07/23.
//

import Foundation

/// Defines all the controlled errors that could be throw it in the package implementation
enum InjectionErrors: Error {
    
    /// When an abstraction is already store into the container.
    /// The container only allows to store one abstractions with one or many implementations
    case abstractionAlreadyRegistered(abstractionName: String)
    
    /// When an implementation is trying to be injected but it couldn't be casted as the specified abstraction data type
    case implementationsCouldNotBeCasted(abstractionName: String)
    
    /// When no registered abstraction was founded in the container with the given type
    case notAbstrationFound(abstractionName: String)
    
    /// When an abstraction that is supposed to was stored into the container couldn't be found to update its values.
    case abstractionNotFoundForUpdate(abstractionName: String)
    
    case undefinedRegistrationType(abstrationName: String) 
    
    /// A computed property to obtain a specific error message based on the current case
    var message: String {
        switch self {
        case .abstractionAlreadyRegistered(let abstractionName):
            return "'\(abstractionName)' it's already registered in container. The previously registered implementations can't be override, please make sure of register every abstraction just once"
        case .implementationsCouldNotBeCasted(let abstractionName):
            return "Something happened when trying to cast '\(abstractionName)'. Please make sure of register dependencies that successfully implement the '\(abstractionName)' protocol and make sure to add a valid dependency key"
        case .notAbstrationFound(let abstractionName):
            return "No registered abstraction found with the identifier '\(abstractionName)'"
        case .abstractionNotFoundForUpdate(let abstractionName):
            return "'\(abstractionName)' couldn't be found to update its values. Please make sure of register the abstraction into the container before trying to update its implementations"
        case .undefinedRegistrationType(let abstractionName):
            return "'\(abstractionName)' abstraction couldn't be registered (Undefined registration type)"
        }
    }
}
