//
//  DependenciesManagerProtocol.swift
//  
//
//  Created by Andres Duque on 15/07/23.
//

import Foundation
import Combine

protocol DependenciesManagerProtocol {
    /// To register into the container a new abstraction and its corresponding implementations.
    /// - Parameters:
    ///   - abstraction: Generic type. The protocol to register as dependency.
    ///   - defaultDependency: The key to identify the implementation that will be injected.
    ///   - implementations: A dictionary that contains a unique key for every implementation and a closure which has the job to create a new instance of the given implementation ( classes that conforms to InjectableDependency protocol ).
    func register<Abstraction>(_ abstraction: Abstraction.Type, defaultDependency: String, implementations: [String: () -> Abstraction?])
    
    /// To register into the container a new abstraction and its corresponding implementation (Useful when only exists one implementation of the given abstraction).
    /// - Parameters:
    ///   - abstraction: Generic type. The protocol to register as dependency.
    ///   - key: The key to identify the implementation that will be injected.
    ///   - implementation: A closure which has the job to create a new instance of the given implementation ( classes that conforms to InjectableDependency protocol ).
    func register<Abstraction>(_ abstraction: Abstraction.Type, key: String, implementation initializer: @escaping () -> Abstraction?)
    
    /// To add into the container a new set of implementations of an already registered abstraction.
    /// - Parameters:
    ///   - abstraction: Generic type. The protocol to register as dependency.
    ///   - implementations: A dictionary that contains a unique key for every implementation and a closure which has the job to create a new instance of the given implementation ( classes that conforms to InjectableDependency protocol ).
    func add<Abstraction>(_ abstraction: Abstraction.Type, implementations: [String: () -> Abstraction?])
    
    /// To add into the container a new implementation of an already registered abstraction.
    /// - Parameters:
    ///   - abstraction: Generic type. The protocol to register as dependency.
    ///   - key: The key to identify the implementation that will be injected.
    ///   - initializer: A closure which has the job to create a new instance of the given implementation ( classes that conforms to InjectableDependency protocol ).
    func add<Abstraction>(_ abstraction: Abstraction.Type, key: String, implementation initializer: @escaping () -> Abstraction?)
    
    /// To change the default implementation injected for a given abstraction by changing the key used in the container.
    /// - Parameters:
    ///   - abstraction: Generic type. The protocol (already registered) to the one we want to change the injected implementation.
    ///   - newKey: A unique key that identifies the new implementation that will be injected by default.
    func updateDependencyKey<Abstraction>(of abstraction: Abstraction.Type, newKey: String)
    
    /// To reset a specific or all the instances of a singleton dependency stored in the container.
    /// - Parameters:
    ///   - abstraction: Generic type. The protocol (already registered) to the one we want to reset the implementation or implementations used as singletons.
    ///   - key: A unique key that identifies the specific implementation that will be reseted. Nil if we want to reset all the implementations registered for the given abstraction.
    func resetSingleton<Abstraction>(of abstraction: Abstraction.Type, key: String?)
    
    /// To extract a specific implementation from the container and make an upcasting to the abstraction data type.
    /// - Parameter injectionType: An enum that defines if the implementations that will be injected is going to be extracted as a singleton or as a regular dependency (a new instance).
    /// - Returns: An implementation wrapped as the especific abstraction define in the generic type of the function or nil in case something goes wrong in the process.
    func get<Abstraction>(with injectionType: InjectionType) -> Abstraction?
    
    /// To extract from the container the publisher that will send the new implementations to the subscribed injectors.
    /// - Parameter abstraction: Generic type. The protocol that was registered as dependency.
    /// - Returns: A publisher to listen the new implementations released.
    func getPublisher<Abstraction>(of abstraction: Abstraction.Type) -> AnyPublisher<ImplementationWrapper, InjectionErrors>?
    
    /// To request the publish of a new implementation of the given abstraction.
    /// - Parameters:
    ///   - abstraction: Generic type. The protocol that was registered as dependency.
    ///   - subscriber: An id to know if the publish will be released just for a specific subscriber or for all the subscribers.
    func requestPublisherUpdate<Abstraction>(of abstraction: Abstraction.Type, subscriber: String?)
    
    /// To remove all the registed implementations of a given abstraction and the abstraction itself.
    /// - Parameter abstraction: Generic type. The protocol that was registered as dependency.
    func remove<Abstraction>(_ abstraction: Abstraction.Type)
    
    /// To remove all the registered abstractions and implementations.
    func clear()
}
