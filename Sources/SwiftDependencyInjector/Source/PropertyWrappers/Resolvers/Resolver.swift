//
//  Resolver.swift
//
//
//  Created by Andres Duque on 20/05/24.
//

import Foundation

open class Resolver<Abstraction> {
    /// A wrapper that will manage the whole lyfecycle of the injected implementations.
    var dependency: DependencyWrapper<Abstraction>
    
    /// - Parameters:
    ///   - type: To define the dependency wrapper which will be use
    ///   - injectionType: To define the injection type used to instantiate the dependency.
    ///   - instantiationType: To define at which point the implementation will be instantiated and injected.
    ///   - file: The name of the file where this property is being used. It should not be defined outside, is initialized by default.
    ///   - line: The specific line of the file where this property is being used. It should not be defined outside, is initialized by default.
    ///   - context: To specific a special injection context to extract the implementation to inject from a isolated container.
    ///   - key: To constrain the injection to a specific key and ignore the key settled on the current context.
    init(
        type: DependencyWrapperType,
        injection injectionType: InjectionType = .regular,
        instantiation instantiationType: InstantiationType = .regular,
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
            instantiation: instantiationType,
            file: file,
            line: line,
            context: realContext,
            constrainedTo: key
        )
        
        switch type {
        case .regular:
            dependency = RegularDependencyWrapper(args: args)
        case .observed:
            dependency = ObservedDependencyWrapper(args: args)
        }
    }
}
