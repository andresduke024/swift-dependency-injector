//
//  Inject.swift
//  
//
//  Created by Andres Duque on 13/12/23.
//

import Foundation

/// The property wrapper used to mark a property as an injectable dependency.
/// Generic value: <Abstraction> used to define the abstraction that encapsulates the injected implemententations.
///
/// This property wrapper avoid usage of optional abstractions but can throw a fatal error
/// if the corresponding implementation haven't been registered.
@propertyWrapper
public struct Inject<Abstraction> {

    /// To resolve a concrete implementation of given abstraction. Could throw fatal errors
    private let resolver: ForcedResolver<Abstraction>

    /// To obtain the specific implementation injected when we access to the property from outside.
    public var wrappedValue: Abstraction {
        resolver.value
    }

    /// To initialize the property wrapper. All parameters has a default value so it could be initialize with an empty constructor.
    /// - Parameters:
    ///   - injectionType: To define the injection type used to instantiate the dependency.
    ///   - instantiationType: To define at which point the implementation will be instantiated and injected.
    ///   - file: The name of the file where this property is being used. It should not be defined outside, is initialized by default.
    ///   - line: The specific line of the file where this property is being used. It should not be defined outside, is initialized by default.
    ///   - context: To specific a special injection context to extract the implementation to inject from a isolated container.
    ///   - key: To constrain the injection to a specific key and ignore the key settled on the current context.
    public init(
        injection injectionType: InjectionType = .regular,
        instantiation instantiationType: InstantiationType = .lazy,
        _ file: String = #file,
        _ line: Int = #line,
        context: InjectionContext = .global,
        constrainedTo key: String? = nil
    ) {
        self.resolver = ForcedResolver(
            type: .regular,
            injection: injectionType,
            instantiation: instantiationType,
            file: file,
            line: line,
            context: context,
            constrainedTo: key
        )
    }
}
