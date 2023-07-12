//
//  Logger.swift
//
//
//  Created by Andres Duque on 5/07/23.
//

import Foundation

/// This class can be used as middleware to access to the injection and registration functionalities implemented in the package
public struct Injector {
    
    /// To register into the dependencies container a new abstraction and its corresponding implementations
    /// - Parameters:
    ///   - abstraction: Generic type. The protocol to register as dependency
    ///   - defaultDependency: The key to identify the implementation that is going to be injected
    ///   - implementations: A dictionary that contains a unique key for every implementation and a closure which has the job to create a new instance of the given implementation ( classes that conforms to InjectableDependency protocol )
    public static func register<Abstraction>(_ abstraction: Abstraction.Type, defaultDependency: String, implementations: [String: () -> Abstraction?]) {
        DependenciesContainer.shared.register(abstraction, defaultDependency: defaultDependency, implementations: implementations)
    }
    
    /// To register into the dependencies container a new abstraction and its corresponding implementation (Useful when only exists one implementation of the given abstraction)
    /// - Parameters:
    ///   - abstraction: Generic type. The protocol to register as dependency
    ///   - key: The key to identify the implementation that is going to be injected. Can be omitted if you're sure this is the only implementations for the given abstraction
    ///   - implementation: A closure which has the job to create a new instance of the given implementation ( classes that conforms to InjectableDependency protocol )
    public static func register<Abstraction>(_ abstraction: Abstraction.Type, key: String = "", implementation: @escaping () -> Abstraction?) {
        DependenciesContainer.shared.register(abstraction, key: key, implementation: implementation)
    }
    
    /// To add into the container a new set of implementations of an already registered abstraction
    /// - Parameters:
    ///   - abstraction: Generic type. The protocol to register as dependency
    ///   - implementations: A dictionary that contains a unique key for every implementation and a closure which has the job to create a new instance of the given implementation ( classes that conforms to InjectableDependency protocol )
    public static func add<Abstraction>(_ abstraction: Abstraction.Type, implementations: [String: () -> Abstraction?]) {
        DependenciesContainer.shared.add(abstraction, implementations: implementations)
    }
    
    /// To add into the container a new implementation of an already registered abstraction
    /// - Parameters:
    ///   - abstraction: Generic type. The protocol to register as dependency
    ///   - key: The key to identify the implementation that is going to be injected
    ///   - implementation: A closure which has the job to create a new instance of the given implementation ( classes that conforms to InjectableDependency protocol )
    public static func add<Abstraction>(_ abstraction: Abstraction.Type, key: String, implementation: @escaping () -> Abstraction?) {
        DependenciesContainer.shared.add(abstraction, key: key, implementation: implementation)
    }
    
    /// To change the default implementation injected for a given abstraction by changing the key used in the container
    /// - Parameters:
    ///   - abstraction: Generic type. The protocol (already registered) to the one we want to change the injected implementation
    ///   - newKey: A unique key that identifies the new implementation that is going to be injected by default
    public static func updateDependencyKey<Abstraction>(of abstraction: Abstraction.Type, newKey: String) {
        DependenciesContainer.shared.updateDependencyKey(of: abstraction, newKey: newKey)
    }
    
    /// To reset a specific or all the instances of a singleton dependency stored in the container
    /// - Parameters:
    ///   - abstraction: Generic type. The protocol (already registered) to the one we want to reset the implementation or implementations used as singletons
    ///   - key: A unique key that identifies the specific implementation that is going to be reseted. Nil if we want to reset all the implementations registered for the given abstraction
    public static func resetSingleton<Abstraction>(of abstraction: Abstraction.Type, key: String? = nil) {
        DependenciesContainer.shared.resetSingleton(of: abstraction, key: key)
    }
    
    /// To remove all the registed implementations of a given abstraction and the abstraction itself
    /// - Parameter abstraction: Generic type. The protocol that was registered as dependency
    public static func remove<Abstraction>(_ abstraction: Abstraction.Type) {
        DependenciesContainer.shared.remove(abstraction)
    }
    
    /// To remove all the registered abstractions and implementations
    public static func clear() {
        DependenciesContainer.shared.clear()
    }
    
    /// To turn off all the information messages logged by the injector ( It don't affect the error messages )
    public static func turnOffLogger() {
        Logger.informationLogsAreActive = false
    }
    
    /// To turn on all the information messages logged by the injector ( It don't affect the error messages )
    public static func turnOnLogger() {
        Logger.informationLogsAreActive = true
    }
}
