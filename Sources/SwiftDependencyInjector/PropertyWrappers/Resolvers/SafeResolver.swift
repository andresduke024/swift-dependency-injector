//
//  SafeResolver.swift
//  
//
//  Created by Andres Duque on 21/05/24.
//

import Foundation

final class SafeResolver<Abstraction>: Resolver<Abstraction> {
    
    /// To obtain the specific implementation injected when we access to the property from outside.
    public var value: Abstraction? { dependency.unwrapValue() }
}
