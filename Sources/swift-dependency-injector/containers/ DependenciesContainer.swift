//
//  DependenciesContainer.swift
//  
//
//  Created by Andres Duque on 5/07/23.
//

import Foundation

class DependenciesContainer {
    static let shared = DependenciesContainer()
    
    private init() {}
    
    private var container: [String: ImplementationsContainer] = [:]
    
    func register<Abstraction>(_ abstraction: Abstraction.Type, defaultDependency: String, implementations: [String: () -> AnyObject?]) {
        register(abstraction: abstraction) { abstractionName in
            saveDependencies(abstractionName: abstractionName, key: defaultDependency, implementations: implementations)
        }
    }
    
    func register<Abstraction>(_ abstraction: Abstraction.Type, implementation: @escaping () -> AnyObject?) {
        register(abstraction: abstraction) { abstractionName in
            let id = UUID().uuidString
            let implementations = [id : implementation]

            saveDependencies(abstractionName: abstractionName, key: id, implementations: implementations)
        }
    }
    
    private func register<Abstraction>(abstraction: Abstraction.Type, completion: (_ abstractionName: String) -> ()) {
        let abstractionName = String(describing: abstraction.self)
        
        do {
            try validateNewAbstraction(name: abstractionName)
            completion(abstractionName)
        } catch (let error){
            Logger.log(error)
        }
    }
    private func validateNewAbstraction(name: String) throws {
        if container[name] != nil {
            throw InjectionErrors.abstractionAlreadyRegistered(abstractionName: name)
        }
    }

    private func saveDependencies(abstractionName: String, key: String, implementations: [String: () -> AnyObject?]) {
        let implementationsContainer = ImplementationsContainer(currentKey: key, implementations: implementations)
        container[abstractionName] = implementationsContainer
        
        Logger.log("'\(abstractionName)' abstraction registered succesfully with \(implementations.count) injectable implementations")
    }
    
    func updateDependencyKey<Abstraction>(of abstraction: Abstraction.Type, newKey: String) {
        let abstractionName = String(describing: abstraction.self)
        guard let item = container[abstractionName] else {
            Logger.log(InjectionErrors.notAbstrationFound(abstractionName: abstractionName))
            return
        }
        
        item.setCurrentKey(newKey)
        Logger.log("The key '\(newKey)' was saved successfully for the new injections of '\(abstractionName)'")
    }
    
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
    
    func get<Abstraction>(with injectionType: InjectionType) -> Abstraction? {
        let abstractionName = String(describing: Abstraction.self)
        guard let implementations = container[abstractionName] else { return nil }
        
        guard let implementation = implementations.get(with: injectionType) as? Abstraction else {
            Logger.log(InjectionErrors.implementationsCouldNotBeCasted(abstractionName: abstractionName))
            return nil
        }

        return implementation
    }
    
    func remove<Abstraction>(_ abstraction: Abstraction.Type) {
        let abstractionName = String(describing: Abstraction.self)
        container.removeValue(forKey: abstractionName)
        Logger.log("All registered implementations of '\(abstractionName)' abstraction were removed successfully from container")
    }
    
    func clear() {
        container.removeAll()
        Logger.log("All registered abstractions and implementations were removed successfully from container")
    }
}
