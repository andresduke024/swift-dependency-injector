//
//  ForcedResolver.swift
//  
//
//  Created by Andres Duque on 21/05/24.
//

import Foundation

final class ForcedResolver<Abstraction>: Resolver<Abstraction> {
    
    /// To obtain the specific implementation injected when we access to the property from outside.
    ///
    /// A fatal error would be thrown if the specific implementation is not stored in the dependency container.
    public var value: Abstraction {
        if let instance = dependency.unwrapValue() {
            return instance
        }

        let error: InjectionErrors = .forcedInjectionFail(
            "\(Abstraction.self)",
            context: dependency.context,
            safePropertyEquivalent: "@ObservedInjectable"
        )
        
        fatalError(error.message)
    }
}
