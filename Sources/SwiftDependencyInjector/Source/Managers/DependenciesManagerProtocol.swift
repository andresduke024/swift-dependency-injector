//
//  DependenciesManagerProtocol.swift
//  
//
//  Created by Andres Duque on 15/07/23.
//

import Foundation

/// To define the behavior to manage all the injection, registration and updating functionalities used in the processes related with abstractions and implementations.
protocol DependenciesManagerProtocol {

    /// To register into the container a new abstraction and its corresponding implementations.
    /// - Parameters:
    ///   - abstraction: Generic type. The protocol to register as dependency.
    ///   - defaultDependency: The key to identify the implementation that will be injected.
    ///   - implementations: A dictionary that contains a unique key for every implementation and a closure which has the job to create a new instance of the given implementation ( classes that conforms to InjectableDependency protocol ).
    func register<Abstraction>(
        _ abstraction: Abstraction.Type,
        defaultDependency: String,
        implementations: [String: () -> Abstraction?]
    )

    /// To register into the container a new abstraction and its corresponding implementation (Useful when only exists one implementation of the given abstraction).
    /// - Parameters:
    ///   - abstraction: Generic type. The protocol to register as dependency.
    ///   - key: The key to identify the implementation that will be injected.
    ///   - implementation: A closure which has the job to create a new instance of the given implementation ( classes that conforms to InjectableDependency protocol ).
    func register<Abstraction>(
        _ abstraction: Abstraction.Type,
        key: String,
        implementation initializer: @escaping () -> Abstraction?
    )

    /// To add into the container a new set of implementations of an already registered abstraction.
    /// - Parameters:
    ///   - abstraction: Generic type. The protocol to register as dependency.
    ///   - implementations: A dictionary that contains a unique key for every implementation and a closure which has the job to create a new instance of the given implementation ( classes that conforms to InjectableDependency protocol ).
    func add<Abstraction>(
        _ abstraction: Abstraction.Type,
        implementations: [String: () -> Abstraction?]
    )

    /// To add into the container a new implementation of an already registered abstraction.
    /// - Parameters:
    ///   - abstraction: Generic type. The protocol to register as dependency.
    ///   - key: The key to identify the implementation that will be injected.
    ///   - initializer: A closure which has the job to create a new instance of the given implementation ( classes that conforms to InjectableDependency protocol ).
    func add<Abstraction>(
        _ abstraction: Abstraction.Type,
        key: String,
        implementation initializer: @escaping () -> Abstraction?
    )
    /// To reset a specific or all the instances of a singleton dependency stored in the container.
    /// - Parameters:
    ///   - abstraction: Generic type. The protocol (already registered) to the one we want to reset the implementation or implementations used as singletons.
    ///   - key: A unique key that identifies the specific implementation that will be reseted. Nil if we want to reset all the implementations registered for the given abstraction.
    func resetSingleton<Abstraction>(
        of abstraction: Abstraction.Type,
        key: String?
    )

    /// To extract a specific implementation from the container and make an upcasting to the abstraction data type.
    /// - Parameters:
    ///   - injectionType: An enum that defines if the implementations that will be injected is going to be extracted as a singleton or as a regular dependency (a new instance).
    ///   - key: To extract a implementation based on a specific key and ignoring the current one.
    /// - Returns: An implementation wrapped as the especific abstraction define in the generic type of the function or nil in case something goes wrong in the process.
    func get<Abstraction>(
        with injectionType: InjectionType,
        key: String?
    ) -> Abstraction?

    /// To remove all the registed implementations of a given abstraction and the abstraction itself.
    /// - Parameter abstraction: Generic type. The protocol that was registered as dependency.
    func remove<Abstraction>(
        _ abstraction: Abstraction.Type
    )

    /// To remove all the registered abstractions and implementations.
    func clear()
}
