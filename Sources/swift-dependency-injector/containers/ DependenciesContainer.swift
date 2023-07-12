//
//  DependenciesContainer.swift
//  
//
//  Created by Andres Duque on 5/07/23.
//

import Foundation

/// This class manage all the injection, registration and updating functionalities used in the processes related with abstractions and implementations
class DependenciesContainer {
    
    /// A singleton instance of the class
    static let shared = DependenciesContainer()
    
    private init() {}
    
    /// To store al the abstractions and its corresponding implementations wrapped inside of a 'ImplementationsContainer' class.
    /// The key used to idenfies each one its the abstraction's data type parsed as string
    private var container: [String: ImplementationsContainer] = [:]
    
    /// To register into the container a new abstraction and its corresponding implementations
    /// - Parameters:
    ///   - abstraction: Generic type. The protocol to register as dependency
    ///   - defaultDependency: The key to identify the implementation that is going to be injected
    ///   - implementations: A dictionary that contains a unique key for every implementation and a closure which has the job to create a new instance of the given implementation ( classes that conforms to InjectableDependency protocol )
    func register<Abstraction>(_ abstraction: Abstraction.Type, defaultDependency: String, implementations: [String: () -> Abstraction?]) {
        validate(abstraction: abstraction) { abstractionName in
            let mappedImplementations = implementations.mapValues { initializer in { initializer() as? AnyObject } }
            saveDependencies(abstractionName: abstractionName, key: defaultDependency, implementations: mappedImplementations)
        }
    }
    
    /// To register into the container a new abstraction and its corresponding implementation (Useful when only exists one implementation of the given abstraction)
    /// - Parameters:
    ///   - abstraction: Generic type. The protocol to register as dependency
    ///   - implementation: A closure which has the job to create a new instance of the given implementation ( classes that conforms to InjectableDependency protocol )
    func register<Abstraction>(_ abstraction: Abstraction.Type, implementation initializer: @escaping () -> Abstraction?) {
        validate(abstraction: abstraction) { abstractionName in
            let id = UUID().uuidString
            let implementations = [id : { initializer() as? AnyObject }]

            saveDependencies(abstractionName: abstractionName, key: id, implementations: implementations)
        }
    }
    
    /// To validate a new abstraction by checking if exists and handle possible throwed errors
    /// - Parameters:
    ///   - abstraction: Generic type. The protocol to register as dependency
    ///   - completion: A closure that handle the next steps of the register process. It use the abstraction name as parameter
    private func validate<Abstraction>(abstraction: Abstraction.Type, completion: (_ abstractionName: String) -> ()) {
        let abstractionName = String(describing: abstraction.self)
        
        do {
            try validateNewAbstraction(name: abstractionName)
            completion(abstractionName)
        } catch (let error){
            Logger.log(error)
        }
    }
    
    
    /// To validate if the given abstraction is already store into the container. Throws an 'InjectionErrors'.
    /// - Parameter name: The name (identifier) of the given abstraction
    private func validateNewAbstraction(name: String) throws {
        guard !Utils.isRunningOnTestTarget else { return }
        
        if container[name] != nil {
            throw InjectionErrors.abstractionAlreadyRegistered(abstractionName: name)
        }
    }
    
    /// To store an abstraction and its corresponding implementations into the container.
    /// - Parameters:
    ///   - abstractionName: The name (identifier) of the given abstraction
    ///   - key: The key that identifies the implementation that is going to be injected by default
    ///   - implementations: A dictionary that contains a unique key for every implementation and a closure which has the job to create a new instance of the given implementation ( classes that conforms to InjectableDependency protocol )
    private func saveDependencies(abstractionName: String, key: String, implementations: [String: () -> AnyObject?]) {
        let implementationsContainer = ImplementationsContainer(currentKey: key, implementations: implementations)
        container[abstractionName] = implementationsContainer
        
        Logger.log("'\(abstractionName)' abstraction registered succesfully with \(implementations.count) injectable implementations")
    }
    
    /// To change the default implementation injected for a given abstraction by changing the key used in the container
    /// - Parameters:
    ///   - abstraction: Generic type. The protocol (already registered) to the one we want to change the injected implementation
    ///   - newKey: A unique key that identifies the new implementation that is going to be injected by default
    func updateDependencyKey<Abstraction>(of abstraction: Abstraction.Type, newKey: String) {
        let abstractionName = String(describing: abstraction.self)
        guard let item = container[abstractionName] else {
            Logger.log(InjectionErrors.notAbstrationFound(abstractionName: abstractionName))
            return
        }
        
        item.setCurrentKey(newKey)
        Logger.log("The key '\(newKey)' was saved successfully for the new injections of '\(abstractionName)'")
    }
    
    /// To reset a specific or all the instances of a singleton dependency stored in the container
    /// - Parameters:
    ///   - abstraction: Generic type. The protocol (already registered) to the one we want to reset the implementation or implementations used as singletons
    ///   - key: A unique key that identifies the specific implementation that is going to be reseted. Nil if we want to reset all the implementations registered for the given abstraction
    func resetSingleton<Abstraction>(of abstraction: Abstraction.Type, key: String? = nil) {
        let abstractionName = String(describing: abstraction.self)
        guard let item = container[abstractionName] else {
            Logger.log(InjectionErrors.notAbstrationFound(abstractionName: abstractionName))
            return
        }
        
        item.removeSingleton(key: key)
        
        if let key {
            Logger.log("All singletons instances with key '\(key)' removed successfully for implementations of '\(abstractionName)'")
        } else {
            Logger.log("All singletons instances removed successfully for implementations of '\(abstractionName)'")
        }
    }
    
    /// To extract a specific implementation from the container and make an upcasting to the abstraction data type.
    /// - Parameter injectionType: An enum that defines if the implementations that is going to be injected is going to be extracted as a singleton or as a regular dependency (a new instance)
    /// - Returns: An implementation wrapped as the especific abstraction define in the generic type of the function or nil in case something goes wrong in the process.
    func get<Abstraction>(with injectionType: InjectionType) -> Abstraction? {
        let abstractionName = String(describing: Abstraction.self)
        guard let implementations = container[abstractionName] else { return nil }
        
        guard let implementation = implementations.get(with: injectionType) as? Abstraction else {
            Logger.log(InjectionErrors.implementationsCouldNotBeCasted(abstractionName: abstractionName))
            return nil
        }

        return implementation
    }
    
    /// To remove all the registed implementations of a given abstraction and the abstraction itself
    /// - Parameter abstraction: Generic type. The protocol that was registered as dependency
    func remove<Abstraction>(_ abstraction: Abstraction.Type) {
        let abstractionName = String(describing: Abstraction.self)
        container.removeValue(forKey: abstractionName)
        Logger.log("All registered implementations of '\(abstractionName)' abstraction were removed successfully from container")
    }
    
    /// To remove all the registered abstractions and implementations
    func clear() {
        container.removeAll()
        Logger.log("All registered abstractions and implementations were removed successfully from container")
    }
}
