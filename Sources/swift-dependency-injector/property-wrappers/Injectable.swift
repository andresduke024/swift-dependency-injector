//
//  Injectable.swift
//  
//
//  Created by Andres Duque on 5/07/23.
//

import Foundation

/// The property wrapper used to mark a property as an injectable dependency.
/// Generic value: <Abstraction> used to define the abstraction that encapsulates the injected implemententations.
@propertyWrapper
public struct Injectable<Abstraction> {

    /// A wrapper that will manage the whole lyfecycle of the injected implementation.
    private let dependency: DependencyWrapper<Abstraction>

    /// To obtain the specific implementation injected when we access to the property from outside.
    public var wrappedValue: Abstraction? { dependency.unwrapValue() }
    
    /// To initialize the property wrapper. All parameters has a default value so it could be initialize with an empty constructor.
    /// - Parameters:
    ///   - injectionType: To define the injection type used to instantiate the dependency.
    ///   - instantiationType: To define at which point the implementation will be instantiated and injected.
    ///   - file: The name of the file where this property is being used. It should not be defined outside, is initialized by default.
    ///   - line: The specific line of the file where this property is being used. It should not be defined outside, is initialized by default.
    public init(
        injection injectionType: InjectionType = .regular,
        instantiation instantiationType: InstantiationType = .lazy,
        _ file: String = #file,
        _ line: Int = #line
    ) {
        self.dependency = RegularDependencyWrapper(injectionType, instantiationType, file, line)
    }
}
