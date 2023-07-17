//
//  ContextManager.swift
//  
//
//  Created by Andres Duque on 16/07/23.
//

import Foundation

/// To handle the access to the different registered contexts.
final class ContextManager: ContextManagerProtocol {
    
    /// To store all the managers (contexts) that can be used to register and inject dependencies.
    private var managers: [String: DependenciesManagerProtocol] = [:]
    
    /// To perform validations about the current running target.
    private var targetValidator: TargetValidatorProtocol
    
    /// To know the amount of managers (contexts) registered.
    var count: Int { managers.count }
    
    init(targetValidator: TargetValidatorProtocol) {
        self.targetValidator = targetValidator
    }
    
    /// To get a manager (creates a new one if not exists) based on a specific context.
    /// - Parameter context: The context to identify and access to the especific manager.
    /// - Returns: An isolated instance of a manager to register, update and get dependencies.
    func get(_ context: InjectionContext) -> DependenciesManagerProtocol {
        if let manager = managers[context.id] {
            return manager
        }
        
        return register(context)
    }
    
    /// To create a manager and relate to a specific context.
    /// - Parameter context: The context to identify and access to the especific manager.
    /// - Returns: The new manager. Already stored into a container
    func register(_ context: InjectionContext) -> DependenciesManagerProtocol {
        let newInstance = DependenciesManager(targetValidator: targetValidator.copy())
        managers[context.id] = newInstance
        return newInstance
    }
    
    /// To delete a specific context and all its related content. This includes all the abstractions and implementations registered on it.
    /// - Parameter context: The context to delete.
    func remove(_ context: InjectionContext) {
        managers.removeValue(forKey: context.id)
    }
    
    /// To validate if a dependency will be injected from a test target and create a custom context (based on the original class file name) that isolates the injection if is the case.
    /// - Parameters:
    ///   - context: The original context from the one the dependency will be extracted.
    ///   - fileName: The name of the file where is define the class that contains the injectable properties.
    /// - Returns: The appropiate context to run the injections.
    func transformToValidContext(_ context: InjectionContext, fileName: String) -> InjectionContext {
        guard targetValidator.isRunningOnTestTarget, case .global = context else {
            return context
        }
        
        let newContext: InjectionContext = .tests(name: fileName)
        
        guard managers[newContext.id] != nil else {
            return .global
        }
        
        return newContext
    }
}
