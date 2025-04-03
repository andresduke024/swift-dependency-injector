//
//  Injectable.swift
//  
//
//  Created by Andres Duque on 5/07/23.
//

import Foundation

/// The property wrapper used to mark a property as an injectable dependency.
/// Generic value: <Abstraction: Sendable> used to define the abstraction that encapsulates the injected implemententations.
///
/// It needs <Abstraction: Sendable> to be optional type.
@propertyWrapper
public struct Injectable<Abstraction: Sendable> {
    
    /// To resolve a concrete implementation of given abstraction.
    private let resolver: SafeResolver<Abstraction>

    /// To obtain the specific implementation injected when we access to the property from outside.
    public var wrappedValue: Abstraction? { resolver.value }

    /// To initialize the property wrapper. All parameters has a default value so it could be initialize with an empty constructor.
    /// - Parameters:
    ///   - injectionType: To define the injection type used to instantiate the dependency.
    ///   - file: The name of the file where this property is being used. It should not be defined outside, is initialized by default.
    ///   - line: The specific line of the file where this property is being used. It should not be defined outside, is initialized by default.
    ///   - context: To specific a special injection context to extract the implementation to inject from a isolated container.
    ///   - key: To constrain the injection to a specific key and ignore the key settled on the current context.
    public init(
        injection injectionType: InjectionType = .regular,
        _ file: String = #file,
        _ line: Int = #line,
        context: InjectionContext = .global,
        constrainedTo key: String? = nil
    ) {
        self.resolver = SafeResolver(
            injection: injectionType,
            file: file,
            line: line,
            context: context,
            constrainedTo: key
        )
    }
}
