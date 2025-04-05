//
//  Resolver.swift
//
//
//  Created by Andres Duque on 20/05/24.
//

import Foundation

struct Resolver<Abstraction: Sendable> {
    /// A wrapper that will manage the whole lyfecycle of the injected implementations.
    private let dependency: DependencyWrapper<Abstraction>
    
    /// - Parameters:
    ///   - injectionType: To define the injection type used to instantiate the dependency.
    ///   - file: The name of the file where this property is being used. It should not be defined outside, is initialized by default.
    ///   - line: The specific line of the file where this property is being used. It should not be defined outside, is initialized by default.
    ///   - context: To specific a special injection context to extract the implementation to inject from a isolated container.
    ///   - key: To constrain the injection to a specific key and ignore the key settled on the current context.
    init(
        injection injectionType: InjectionType = .regular,
        file: String,
        line: Int,
        context: InjectionContext,
        constrainedTo key: String? = nil
    ) {
        let realContext = DependenciesContainer
            .global
            .transformToValidContext(context, file: file)
        
        let args = DependencyWrapperArgs(
            injection: injectionType,
            file: file,
            line: line,
            context: realContext,
            constrainedTo: key
        )
        
        dependency = DependencyWrapper(args: args)
    }
    
    /// To obtain the specific implementation injected when we access to the property from outside.
    ///
    /// A fatal error would be thrown if the specific implementation is not stored in the dependency container.
    public var value: Abstraction {
        if let instance = dependency.unwrapValue() {
            return instance
        }

        let error: InjectionErrors = .forcedInjectionFail(
            "\(Abstraction.self)",
            context: dependency.context
        )
        
        fatalError(error.message)
    }
}
