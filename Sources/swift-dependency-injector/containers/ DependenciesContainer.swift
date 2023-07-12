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
        createRegistrationContext(abstraction: abstraction, initialRegistrationType: .create) { abstractionName, registrationType in
            let mappedImplementations = InitializersContainerMapper.map(implementations)
            saveDependencies(abstractionName: abstractionName, key: defaultDependency, implementations: mappedImplementations, registrationType)
        }
    }
    
    /// To register into the container a new abstraction and its corresponding implementation (Useful when only exists one implementation of the given abstraction)
    /// - Parameters:
    ///   - abstraction: Generic type. The protocol to register as dependency
    ///   - key: The key to identify the implementation that is going to be injected
    ///   - implementation: A closure which has the job to create a new instance of the given implementation ( classes that conforms to InjectableDependency protocol )
    func register<Abstraction>(_ abstraction: Abstraction.Type, key: String, implementation initializer: @escaping () -> Abstraction?) {
        createRegistrationContext(abstraction: abstraction, initialRegistrationType: .create) { abstractionName, registrationType in
            let implementations = InitializersContainerMapper.map(key, initializer)
            saveDependencies(abstractionName: abstractionName, key: key, implementations: implementations, registrationType)
        }
    }
    
    /// To add into the container a new set of implementations of an already registered abstraction
    /// - Parameters:
    ///   - abstraction: Generic type. The protocol to register as dependency
    ///   - implementations: A dictionary that contains a unique key for every implementation and a closure which has the job to create a new instance of the given implementation ( classes that conforms to InjectableDependency protocol )
    func add<Abstraction>(_ abstraction: Abstraction.Type, implementations: [String: () -> Abstraction?]) {
        createRegistrationContext(abstraction: abstraction, initialRegistrationType: .update) { abstractionName, registrationType in
            let mappedImplementations = InitializersContainerMapper.map(implementations)
            saveDependencies(abstractionName: abstractionName, implementations: mappedImplementations, registrationType)
        }
    }
    
    /// To add into the container a new implementation of an already registered abstraction
    /// - Parameters:
    ///   - abstraction: Generic type. The protocol to register as dependency
    ///   - key: The key to identify the implementation that is going to be injected
    ///   - initializer: A closure which has the job to create a new instance of the given implementation ( classes that conforms to InjectableDependency protocol )
    func add<Abstraction>(_ abstraction: Abstraction.Type, key: String, implementation initializer: @escaping () -> Abstraction?) {
        createRegistrationContext(abstraction: abstraction, initialRegistrationType: .update) { abstractionName, registrationType in
            let implementations = InitializersContainerMapper.map(key, initializer)
            saveDependencies(abstractionName: abstractionName, implementations: implementations, registrationType)
        }
    }
    
    /// To obtain the abstraction name and the registration type that it's going to be used to store it into the container
    /// - Parameters:
    ///   - abstraction: Generic type. The protocol to register as dependency
    ///   - initialRegistrationType: The original registration type. Depends it the user is trying to update or register abstrabtions
    ///   - completion: A closure that provides the abstraction name as String and the registration type
    private func createRegistrationContext<Abstraction>(abstraction: Abstraction.Type, initialRegistrationType: RegistrationType, completion: (_ abstractionName: String, _ registrationType: RegistrationType) -> ()) {
        let abstractionName = String(describing: abstraction.self)

        guard !Utils.isRunningOnTestTarget else {
            completion(abstractionName, .updateOrCreate)
            return
        }

        if initialRegistrationType == .update {
            completion(abstractionName, .update)
            return
        }
        
        guard initialRegistrationType == .create else {
            Logger.log(InjectionErrors.undefinedRegistrationType(abstrationName: abstractionName))
            return
        }
        
        do {
            try validateNewAbstraction(name: abstractionName)
            completion(abstractionName, .create)
        } catch (let error){
            Logger.log(error)
        }
    }
    
    /// To validate if the given abstraction is already store into the container. Throws an 'InjectionErrors'.
    /// - Parameter name: The name (identifier) of the given abstraction
    private func validateNewAbstraction(name: String) throws {
        if container[name] != nil {
            throw InjectionErrors.abstractionAlreadyRegistered(abstractionName: name)
        }
    }
    
    /// To handle the registration of the new dependencies based on the provided registration type.
    /// - Parameters:
    ///   - abstractionName: The name (identifier) of the given abstraction
    ///   - key: The key that identifies the implementation that is going to be injected by default
    ///   - implementations: A dictionary that contains a unique key for every implementation and a closure which has the job to create a new instance of the given implementation ( classes that conforms to InjectableDependency protocol )
    ///   - registrationType: An enum value to know the kind of registration to perform
    private func saveDependencies(abstractionName: String, key: String = "", implementations: InitializersContainer, _ registrationType: RegistrationType) {
        switch registrationType {
        case .create:
            create(abstractionName: abstractionName, key: key, implementations: implementations)
        case .update:
            update(abstractionName: abstractionName, implementations: implementations)
        case .updateOrCreate:
            updateOrCreate(abstractionName: abstractionName, key: key, implementations: implementations)
        }
    }
    
    
    /// To update an already stored abstraction and its new corresponding implementations into the container.
    /// - Parameters:
    ///   - abstractionName: The name (identifier) of the given abstraction
    ///   - key: The key that identifies the implementation that is going to be injected by default
    ///   - implementations: A dictionary that contains a unique key for every implementation and a closure which has the job to create a new instance of the given implementation ( classes that conforms to InjectableDependency protocol )
    private func update(abstractionName: String, implementations: InitializersContainer) {
        guard let implementationsContainer = container[abstractionName] else {
            Logger.log(InjectionErrors.abstractionNotFoundForUpdate(abstractionName: abstractionName))
            return
        }
        
        let newImplementationsContainer = implementationsContainer.copyWith(implementations: implementations)
        container[abstractionName] = newImplementationsContainer
        Logger.log("'\(abstractionName)' abstraction updated succesfully with \(implementations.count) injectable implementations. \(newImplementationsContainer.count) Implementations registered in total")
    }
    
    
    /// To store an abstraction and its corresponding implementations into the container.
    /// - Parameters:
    ///   - abstractionName: The name (identifier) of the given abstraction
    ///   - key: The key that identifies the implementation that is going to be injected by default
    ///   - implementations: A dictionary that contains a unique key for every implementation and a closure which has the job to create a new instance of the given implementation ( classes that conforms to InjectableDependency protocol )
    private func create(abstractionName: String, key: String, implementations: InitializersContainer) {
        let implementationsContainer = ImplementationsContainer(currentKey: key, implementations: implementations)
        container[abstractionName] = implementationsContainer
        
        Logger.log("'\(abstractionName)' abstraction registered succesfully with \(implementations.count) injectable implementations")
    }
        
    /// To store or update an abstraction and its corresponding implementations into the container (Useful when application runs on Tests Target).
    /// - Parameters:
    ///   - abstractionName: The name (identifier) of the given abstraction
    ///   - key: The key that identifies the implementation that is going to be injected by default
    ///   - implementations: A dictionary that contains a unique key for every implementation and a closure which has the job to create a new instance of the given implementation ( classes that conforms to InjectableDependency protocol )
    private func updateOrCreate(abstractionName: String, key: String, implementations: InitializersContainer) {
        if container[abstractionName] == nil {
            create(abstractionName: abstractionName, key: key, implementations: implementations)
            return
        }
        
        update(abstractionName: abstractionName, implementations: implementations)
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
