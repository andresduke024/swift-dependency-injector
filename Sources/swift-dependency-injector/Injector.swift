//
//  Logger.swift
//
//
//  Created by Andres Duque on 5/07/23.
//

import Foundation



/// This class can be used as middleware to access to the injection and registration functionalities implemented in the package
public struct Injector {
    
    /// A default instance of the injector class builded to run in a global injection context
    private(set) static var global: Injector = build(context: .global)
    
    /// To create a new instance of this class which runs on a isolated context.
    /// - Parameter context: The new injection context that will be registered and use later to access to the dependencies container.
    /// - Returns: A new instance of itself
    public static func build(context: InjectionContext) -> Injector {
        .init(injectionContext: context)
    }
    
    /// The current injection context. Used to access to the dependencies container
    private let context: InjectionContext
    
    private init(injectionContext: InjectionContext) {
        self.context = injectionContext
    }
    
    /// To register into the dependencies container a new abstraction and its corresponding implementations.
    /// - Parameters:
    ///   - abstraction: Generic type. The protocol to register as dependency.
    ///   - defaultDependency: The key to identify the implementation that will be injected.
    ///   - implementations: A dictionary that contains a unique key for every implementation and a closure which has the job to create a new instance of the given implementation ( classes that conforms to InjectableDependency protocol ).
    public func register<Abstraction>(_ abstraction: Abstraction.Type, defaultDependency: String, implementations: [String: () -> Abstraction?]) {
        DependenciesContainer.global.get(context).register(abstraction, defaultDependency: defaultDependency, implementations: implementations)
    }
    
    /// To register into the dependencies container a new abstraction and its corresponding implementation (Useful when only exists one implementation of the given abstraction).
    /// - Parameters:
    ///   - abstraction: Generic type. The protocol to register as dependency.
    ///   - key: The key to identify the implementation that will be injected. Can be omitted if you're sure this is the only implementations for the given abstraction.
    ///   - implementation: A closure which has the job to create a new instance of the given implementation ( classes that conforms to InjectableDependency protocol ).
    public func register<Abstraction>(_ abstraction: Abstraction.Type, key: String = "", implementation: @escaping () -> Abstraction?) {
        DependenciesContainer.global.get(context).register(abstraction, key: key, implementation: implementation)
    }
    
    /// To add into the container a new set of implementations of an already registered abstraction.
    /// - Parameters:
    ///   - abstraction: Generic type. The protocol to register as dependency.
    ///   - implementations: A dictionary that contains a unique key for every implementation and a closure which has the job to create a new instance of the given implementation ( classes that conforms to InjectableDependency protocol ).
    public func add<Abstraction>(_ abstraction: Abstraction.Type, implementations: [String: () -> Abstraction?]) {
        DependenciesContainer.global.get(context).add(abstraction, implementations: implementations)
    }
    
    /// To add into the container a new implementation of an already registered abstraction.
    /// - Parameters:
    ///   - abstraction: Generic type. The protocol to register as dependency.
    ///   - key: The key to identify the implementation that will be injected.
    ///   - implementation: A closure which has the job to create a new instance of the given implementation ( classes that conforms to InjectableDependency protocol ).
    public func add<Abstraction>(_ abstraction: Abstraction.Type, key: String, implementation: @escaping () -> Abstraction?) {
        DependenciesContainer.global.get(context).add(abstraction, key: key, implementation: implementation)
    }
    
    /// To change the default implementation injected for a given abstraction by changing the key used in the container.
    /// - Parameters:
    ///   - abstraction: Generic type. The protocol (already registered) to the one we want to change the injected implementation.
    ///   - newKey: A unique key that identifies the new implementation that will be injected by default.
    public func updateDependencyKey<Abstraction>(of abstraction: Abstraction.Type, newKey: String) {
        DependenciesContainer.global.get(context).updateDependencyKey(of: abstraction, newKey: newKey)
    }
    
    /// To reset a specific or all the instances of a singleton dependency stored in the container.
    /// - Parameters:
    ///   - abstraction: Generic type. The protocol (already registered) to the one we want to reset the implementation or implementations used as singletons.
    ///   - key: A unique key that identifies the specific implementation that will be reseted. Nil if we want to reset all the implementations registered for the given abstraction.
    public func resetSingleton<Abstraction>(of abstraction: Abstraction.Type, key: String? = nil) {
        DependenciesContainer.global.get(context).resetSingleton(of: abstraction, key: key)
    }
    
    /// To remove all the registed implementations of a given abstraction and the abstraction itself.
    /// - Parameter abstraction: Generic type. The protocol that was registered as dependency.
    public func remove<Abstraction>(_ abstraction: Abstraction.Type) {
        DependenciesContainer.global.get(context).remove(abstraction)
    }
    
    /// To remove all the registered abstractions and implementations.
    public func clear() {
        DependenciesContainer.global.get(context).clear()
    }
    
    /// To turn off the messages logged by the injector.
    /// - Parameter forced: To know if error messages will be disabled too. False by default.
    public func turnOffLogger(forced: Bool = false) {
        Logger.informationLogsAreActive = false
        if forced { Logger.isActive = false }
    }
    
    /// To turn on all the information and error messages logged by the injector.
    public func turnOnLogger() {
        Logger.isActive = true
        Logger.informationLogsAreActive = true
    }
    
    /// To remove the current context from the dependencies container.
    public func destroy() {
        DependenciesContainer.global.remove(context)
    }
}
