//
//  ContextManagerProtocol.swift
//  
//
//  Created by Andres Duque on 16/07/23.
//

import Foundation

/// To define the behavior to handle the access to the different registered contexts.
protocol ContextManagerProtocol {
    
    /// To get a manager (creates a new one if not exists) based on a specific context.
    /// - Parameter context: The context to identify and access to the especific manager.
    /// - Returns: An isolated instance of a manager to register, update and get dependencies.
    func get(_ context: InjectionContext) -> DependenciesManagerProtocol
    
    /// To create a manager and relate to a specific context.
    /// - Parameter context: The context to identify and access to the especific manager.
    /// - Returns: The new manager. Already stored into a container
    func register(_ context: InjectionContext) -> DependenciesManagerProtocol
    
    /// To delete a specific context and all its related content. This includes all the abstractions and implementations registered on it.
    /// - Parameter context: The context to delete.
    func remove(_ context: InjectionContext)
    
    /// To validate if a dependency will be injected from a test target and create a custom context (based on the original class file name) that isolates the injection if is the case.
    /// - Parameters:
    ///   - context: The original context from the one the dependency will be extracted.
    ///   - fileName: The name of the file where is define the class that contains the injectable properties.
    /// - Returns: The appropiate context to run the injections.
    func transformToValidContext(_ context: InjectionContext, fileName: String) -> InjectionContext
}
