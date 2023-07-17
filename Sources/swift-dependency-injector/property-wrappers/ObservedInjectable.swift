//
//  ObservedInjectable.swift
//  
//
//  Created by Andres Duque on 13/07/23.
//

import Foundation

/// The property wrapper used to mark a property as an injectable dependency which can be replaced at runtime several times.
/// Generic value: <Abstraction> used to define the abstraction that encapsulates the injected implemententations.
@propertyWrapper
public struct ObservedInjectable<Abstraction> {

    /// A wrapper that will manage the whole lyfecycle of the injected implementations.
    private let dependency: DependencyWrapper<Abstraction>

    /// To obtain the specific implementation injected when we access to the property from outside.
    public var wrappedValue: Abstraction? { dependency.unwrapValue() }
    
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
        let realContext = DependenciesContainer.global.transformToValidContext(context, fileName: Utils.extractFileName(of: file, withExtension: false))
        self.dependency = ObservedDependencyWrapper(file, line, realContext)
    }
}
