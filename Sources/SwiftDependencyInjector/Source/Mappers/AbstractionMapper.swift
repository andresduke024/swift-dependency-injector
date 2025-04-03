//
//  AbstractionMapper.swift
//  
//
//  Created by Andres Duque on 13/07/23.
//

import Foundation

/// To map generic objects to specific 'Abstractions'.
struct AbstractionMapper {

    /// To map a generic implementation instance to a given abstraction upcasted instance.
    /// - Parameter implementation: The implementation that is going to be mapped.
    /// - Returns: A implementation instance wrapped as an instance of the given abstraction.
    static func map<Abstraction: Sendable>(
        _ implementation: AnyObject?
    ) -> Abstraction? {
        let abstractionName = String(describing: Abstraction.self)

        guard let implementation = implementation as? Abstraction else {
            Logger.log(InjectionErrors.implementationsCouldNotBeCasted(abstractionName))
            return nil
        }

        return implementation
    }
}
