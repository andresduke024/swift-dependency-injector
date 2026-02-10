//
//  Injector.swift
//
//
//  Created by Andres Duque on 5/07/23.
//

import Foundation

/// This class can be used as middleware to access to the injection and registration functionalities implemented in the package
public struct Injector: Sendable {

    /// A default instance of the injector class builded to run in a global injection context
    public static let global: Injector = build(context: .global)

    /// To create a new instance of this class which runs on a isolated context.
    /// - Parameter context: The new injection context that will be registered and use later to access to the dependencies container.
    /// - Returns: A new instance of itself
    public static func build(context: InjectionContext) -> Injector {
        .init(injectionContext: context)
    }

    /// The current injection context. Used to access to the dependencies container
    private let context: InjectionContext

    private init(
        injectionContext: InjectionContext
    ) {
        self.context = injectionContext
    }
    
    private var dependenciesManager: DependenciesManagerProtocol {
        DependenciesContainer.global.get(context)
    }

    /// To register into the dependencies container a new abstraction and its corresponding implementations.
    /// - Parameters:
    ///   - abstraction: Generic type. The protocol to register as dependency.
    ///   - defaultDependency: The key to identify the implementation that will be injected.
    ///   - implementations: A dictionary that contains a unique key for every implementation and a closure which has the job to create a new instance of the given implementation ( classes that conforms to InjectableDependency protocol ).
    public func register<Abstraction: Sendable>(
        _ abstraction: Abstraction.Type,
        defaultDependency: String,
        implementations: [String: @Sendable () -> Abstraction?]
    ) {
        dependenciesManager.register(abstraction, defaultDependency: defaultDependency, implementations: implementations)
    }

    /// To register into the dependencies container a new abstraction and its corresponding implementation (Useful when only exists one implementation of the given abstraction).
    /// - Parameters:
    ///   - abstraction: Generic type. The protocol to register as dependency.
    ///   - key: The key to identify the implementation that will be injected. Can be omitted if you're sure this is the only implementations for the given abstraction.
    ///   - implementation: A closure which has the job to create a new instance of the given implementation ( classes that conforms to InjectableDependency protocol ).
    public func register<Abstraction: Sendable>(
        _ abstraction: Abstraction.Type,
        key: String = "",
        implementation: @Sendable @escaping () -> Abstraction?
    ) {
        dependenciesManager.register(abstraction, key: key, implementation: implementation)
    }

    /// To add into the container a new set of implementations of an already registered abstraction.
    /// - Parameters:
    ///   - abstraction: Generic type. The protocol to register as dependency.
    ///   - implementations: A dictionary that contains a unique key for every implementation and a closure which has the job to create a new instance of the given implementation ( classes that conforms to InjectableDependency protocol ).
    public func add<Abstraction: Sendable>(
        _ abstraction: Abstraction.Type,
        implementations: [String: @Sendable () -> Abstraction?]
    ) {
        dependenciesManager.add(abstraction, implementations: implementations)
    }

    /// To add into the container a new implementation of an already registered abstraction.
    /// - Parameters:
    ///   - abstraction: Generic type. The protocol to register as dependency.
    ///   - key: The key to identify the implementation that will be injected.
    ///   - implementation: A closure which has the job to create a new instance of the given implementation ( classes that conforms to InjectableDependency protocol ).
    public func add<Abstraction: Sendable>(
        _ abstraction: Abstraction.Type,
        key: String,
        implementation: @Sendable @escaping () -> Abstraction?
    ) {
        dependenciesManager.add(abstraction, key: key, implementation: implementation)
    }
    
    /// To add into the container a new set of implementations or register them if not exists.
    /// - Parameters:
    ///   - abstraction: Generic type. The protocol to register as dependency.
    ///   - implementations: A dictionary that contains a unique key for every implementation and a closure which has the job to create a new instance of the given implementation ( classes that conforms to InjectableDependency protocol ).
    public func addOrRegister<Abstraction: Sendable>(
        _ abstraction: Abstraction.Type,
        implementations: [String: @Sendable () -> Abstraction?]
    ) {
        dependenciesManager.addOrRegister(abstraction, implementations: implementations)
    }

    /// To add into the container a new implementation or register it if not exists.
    /// - Parameters:
    ///   - abstraction: Generic type. The protocol to register as dependency.
    ///   - key: The key to identify the implementation that will be injected.
    ///   - initializer: A closure which has the job to create a new instance of the given implementation ( classes that conforms to InjectableDependency protocol ).
    public func addOrRegister<Abstraction: Sendable>(
        _ abstraction: Abstraction.Type,
        key: String = "",
        implementation: @Sendable @escaping () -> Abstraction?
    ) {
        dependenciesManager.addOrRegister(abstraction, key: key, implementation: implementation)
    }

    /// To reset a specific or all the instances of a singleton dependency stored in the container.
    /// - Parameters:
    ///   - abstraction: Generic type. The protocol (already registered) to the one we want to reset the implementation or implementations used as singletons.
    ///   - key: A unique key that identifies the specific implementation that will be reseted. Nil if we want to reset all the implementations registered for the given abstraction.
    public func resetSingleton<Abstraction: Sendable>(
        of abstraction: Abstraction.Type,
        key: String? = nil
    ) {
        dependenciesManager.resetSingleton(of: abstraction, key: key)
    }

    /// To remove all the registed implementations of a given abstraction and the abstraction itself.
    /// - Parameter abstraction: Generic type. The protocol that was registered as dependency.
    public func remove<Abstraction: Sendable>(
        _ abstraction: Abstraction.Type
    ) {
        dependenciesManager.remove(abstraction)
    }

    /// To remove all the registered abstractions and implementations.
    public func clear() {
        dependenciesManager.clear()
    }

    /// To turn off the messages logged by the injector.
    /// - Parameter forced: To know if error messages will be disabled too. False by default.
    public func turnOffLogger(
        forced: Bool = false
    ) {
        Properties.informationLogsAreActive = false
        if forced { Properties.informationLogsAreActive = false }
    }

    /// To turn on all the information and error messages logged by the injector.
    public func turnOnLogger() {
        Properties.isLoggerActive = true
        Properties.informationLogsAreActive = true
    }

    /// To remove the current context from the dependencies container.
    public func destroy() {
        DependenciesContainer.global.remove(context)
    }
    
    /// To get a previously injected abstraction (Could throws fatal errors)
    ///
    /// - Parameters:
    ///   - file: The name of the file where this property is being used. It should not be defined outside, is initialized by default.
    ///   - line: The specific line of the file where this property is being used. It should not be defined outside, is initialized by default.
    ///   - injectionType: To define the injection type used to instantiate the dependency.
    ///   - instantiationType: To define at which point the implementation will be instantiated and injected.
    ///   - key: To constrain the injection to a specific key and ignore the key settled on the current context.
    public func get<Abstraction: Sendable>(
        _ file: String = #file,
        _ line: Int = #line,
        injectionType: InjectionType = .regular,
        constrainedTo key: String? = nil
    ) -> Abstraction {
        let resolver: Resolver<Abstraction> = Resolver(
            injection: injectionType,
            file: file,
            line: line,
            context: context,
            constrainedTo: key
        )
        
        return resolver.value
    }
}
