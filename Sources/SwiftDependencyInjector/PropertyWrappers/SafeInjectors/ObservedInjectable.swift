//
//  ObservedInjectable.swift
//  
//
//  Created by Andres Duque on 13/07/23.
//

import Foundation

/// The property wrapper used to mark a property as an injectable dependency which can be replaced at runtime several times.
/// Generic value: <Abstraction> used to define the abstraction that encapsulates the injected implemententations.
///
/// It needs <Abstraction> to be optional type.
@propertyWrapper
public struct ObservedInjectable<Abstraction> {
    
    /// To resolve a concrete implementation of given abstraction.
    private let resolver: SafeResolver<Abstraction>

    /// To obtain the specific implementation injected when we access to the property from outside.
    public var wrappedValue: Abstraction? { resolver.value }

    /// To initialize the property wrapper. All parameters has a default value so it could be initialize with an empty constructor
    /// - Parameters:
    ///   - file: The name of the file where this property is being used. It should not be defined outside, is initialized by default.
    ///   - line: The specific line of the file where this property is being used. It should not be defined outside, is initialized by default.
    ///   - context: To specific a special injection context to extract the implementation to inject from a isolated container.
    public init(
        _ file: String = #file,
        _ line: Int = #line,
        context: InjectionContext = .global
    ) {
        self.resolver = SafeResolver(
            type: .observed,
            file: file,
            line: line,
            context: context
        )
    }
}
