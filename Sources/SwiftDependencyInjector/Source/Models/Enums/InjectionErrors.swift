//
//  InjectionErrors.swift
//  
//
//  Created by Andres Duque on 5/07/23.
//

import Foundation

/// Defines all the controlled errors that could be throw it in the package implementation.
enum InjectionErrors: Error, Sendable {

    /// When an abstraction is already store into the container.
    /// The container only allows to store one abstractions with one or many implementations.
    case abstractionAlreadyRegistered(_ abstractionName: String, _ context: InjectionContext)

    /// When an implementation is trying to be injected but it couldn't be casted as the specified abstraction data type.
    case implementationsCouldNotBeCasted(_ abstractionName: String)

    /// When no registered abstraction was founded in the container with the given type.
    case notAbstrationFound(_ abstractionName: String, context: InjectionContext)

    /// When an abstraction that is supposed to was stored into the container couldn't be found to update its values.
    case abstractionNotFoundForUpdate(_ abstractionName: String)

    /// When an abstraction is trying to be registered into the container with a registration type that is not handle yet.
    case undefinedRegistrationType(_ abstrationName: String)

    /// When an implementation could not be injected into the wrapper, which means the current value of the wrapper is nil.
    case noImplementationFoundOnInjection(_ abstrationName: String, file: String)

    /// When in the attempt to update the default dependency key of a specific abstraction the key thats already stored is equal to the new key.
    case equalDependecyKeyOnUpdate(_ abstractionName: String, _ key: String)

    /// When no registered abstraction was founded in the container with the given type and it was requested from a forced injection.
    /// It produces a fatal error (Application crash).
    case forcedInjectionFail(_ abstractionName: String, context: InjectionContext, safePropertyEquivalent: String? = nil)

    // swiftlint:disable line_length
    /// A computed property to obtain a specific error message based on the current case.
    var message: String {
        switch self {
        case .abstractionAlreadyRegistered(let abstractionName, let context):
            return "'\(abstractionName)' it's already registered in container of context with identifier \(context.description). The previously registered implementations can't be override, please make sure of register every abstraction just once."
        case .implementationsCouldNotBeCasted(let abstractionName):
            return "Something happened when trying to cast '\(abstractionName)'. Please make sure of register dependencies that successfully implement the '\(abstractionName)' protocol and make sure to add a valid dependency key."
        case .notAbstrationFound(let abstractionName, let context):
            return "No registered abstraction found with the identifier '\(abstractionName)' in context with identifier \(context.description)."
        case .abstractionNotFoundForUpdate(let abstractionName):
            return "'\(abstractionName)' couldn't be found to update its values. Please make sure of register the abstraction into the container before trying to update its implementations."
        case .undefinedRegistrationType(let abstractionName):
            return "'\(abstractionName)' abstraction couldn't be registered (Undefined registration type)."
        case .noImplementationFoundOnInjection(let abstractionName, let file):
            return "Not implementation found for '\(abstractionName)' injection. File: \(file)"
        case .equalDependecyKeyOnUpdate(let abstractionName, let key):
            return "The dependency key '\(key)' for '\(abstractionName)' abstraction is already stored. Try to set a new one to make real changes to the injected implementations."
        case .forcedInjectionFail(let abstractionName, let context, let safePropertyEquivalent):
            let baseMessage = "No implementation found for abstraction of type \(abstractionName) in context with identifier \(context.description)."
            let safePropertyEquivalentMessage = "Use \(safePropertyEquivalent ?? "") instead if a you want to achieve an optional dependency injection."

            return safePropertyEquivalent == nil
                ? baseMessage
                : "\(baseMessage) \(safePropertyEquivalentMessage)"
        }
    }
    // swiftlint:enable line_length

    /// A computed property to obtain an error name description
    var name: String {
        switch self {
        case .abstractionAlreadyRegistered:
            return "AbstractionAlreadyRegistered"
        case .implementationsCouldNotBeCasted:
            return "ImplementationsCouldNotBeCasted"
        case .notAbstrationFound:
            return "NotAbstrationFound"
        case .abstractionNotFoundForUpdate:
            return "AbstractionNotFoundForUpdate"
        case .undefinedRegistrationType:
            return "UndefinedRegistrationType"
        case .noImplementationFoundOnInjection:
            return "NoImplementationFoundOnInjection"
        case .equalDependecyKeyOnUpdate:
            return "EqualDependecyKeyOnUpdate"
        case .forcedInjectionFail:
            return "ForcedInjectionFail"
        }
    }
}
