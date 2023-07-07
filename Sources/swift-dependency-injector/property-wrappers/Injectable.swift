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
    private let dependency: Value?
    
    /// To define the type of injection that we are going to use when try to get an implementation from the container
    private let injectionType: InjectionType
    
    private let line: Int
    private let file: String

    /// The value obtained when we access to the property from outside
    public var wrappedValue: Value? { dependency }
    
    /// The value obtained when we access to the property from outside with the '$' sign.
    /// This value is going to be obtained in real time on every attempt to access to this property.
    /// That means that we can 'listen' the changes making in the container to update the implementations injection of a given abstraction.
    public var projectedValue: Value? {
        let dependency: Value? = DependenciesContainer.shared.get(with: injectionType)
        checkInjectionError(dependency)
        return dependency
    }
    
    /// To initialize the property wrapper. All parameters has a default value so it could be initialize with an empty constructor
    /// - Parameters:
    ///   - injectionType: The injection type used to obtain the dependency
    ///   - file: The name of the file where this property it's being used. It should not be defined outside, is initialized by default.
    ///   - line: The specific line of the file where this property it's being used. It should not be defined outside, is initialized by default.
    public init(_ injectionType: InjectionType = .regular, file: String = #file, line: Int = #line) {
        self.dependency = DependenciesContainer.shared.get(with: injectionType)
        self.injectionType = injectionType
        self.file = file
        self.line = line
        
        checkInjectionError(self.dependency)
    }
    
    /// To validate if an injection was completed successfully
    /// - Parameter dependency: the obtained implementation of the given abstraction (Value)
    private func checkInjectionError(_ dependency: Value?) {
        guard dependency == nil else { return }
        
        let message = "Not implementation found for '\(Value.self)' injection.\n File: \(file) \(line)"
        Logger.log(message, addErrorPrefix: true)
    }
}
