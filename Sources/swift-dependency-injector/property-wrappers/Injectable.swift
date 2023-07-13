//
//  Injectable.swift
//  
//
//  Created by Andres Duque on 5/07/23.
//

import Foundation

/// The property wrapper used to mark a property as an injectable dependency
/// Generic value: <Value> used to define the abstraction that encapsulates the injected implemententations
@propertyWrapper
public struct Injectable<Value> {

    /// The specific implementation obtained from the container.
    /// This property will be used when the wrapped value will requested
    private let dependency: DependencyWrapper<Value>

    /// The value obtained when we access to the property from outside
    public var wrappedValue: Value? { dependency.unwrapValue() }
    
    /// To initialize the property wrapper. All parameters has a default value so it could be initialize with an empty constructor
    /// - Parameters:
    ///   - injectionType: The injection type used to obtain the dependency
    ///   - file: The name of the file where this property it's being used. It should not be defined outside, is initialized by default.
    ///   - line: The specific line of the file where this property it's being used. It should not be defined outside, is initialized by default.
    public init(
        injection injectionType: InjectionType = .regular,
        instantiation instantiationType: InstantiationType = .lazy,
        _ file: String = #file,
        _ line: Int = #line
    ) {
        self.dependency = RegularDependencyWrapper(injectionType, instantiationType, file, line)
    }
}

/// The property wrapper used to mark a property as an injectable dependency
/// Generic value: <Value> used to define the abstraction that encapsulates the injected implemententations
@propertyWrapper
public struct ObservedInjectable<Value> {

    /// The specific implementation obtained from the container.
    /// This property will be used when the wrapped value will requested
    private let dependency: DependencyWrapper<Value>

    /// The value obtained when we access to the property from outside
    public var wrappedValue: Value? { dependency.unwrapValue() }
    
    /// To initialize the property wrapper. All parameters has a default value so it could be initialize with an empty constructor
    /// - Parameters:
    ///   - file: The name of the file where this property it's being used. It should not be defined outside, is initialized by default.
    ///   - line: The specific line of the file where this property it's being used. It should not be defined outside, is initialized by default.
    public init(
        _ file: String = #file,
        _ line: Int = #line
    ) {
        self.dependency = ObservedDependencyWrapper(file, line)
    }
}
