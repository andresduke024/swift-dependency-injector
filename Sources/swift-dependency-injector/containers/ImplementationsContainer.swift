//
//  ImplementationsContainer.swift
//  
//
//  Created by Andres Duque on 5/07/23.
//

import Foundation
import Combine

/// To wrap the definition of a generic implementations container.
typealias InitializersContainer = [String: () -> AnyObject?]

/// This class is used to store the a set of implementation of a given type and exposed the methods to access to them.
final class ImplementationsContainer {
    
    /// The name of the abstraction for which implementations will be stored in this container.
    private var abstractionName: String
    
    /// The key that identifies the implementation that will be injected in every injection attempt.
    private var currentKey: String
    
    /// To store the builder of each implementation.
    private let implementations: InitializersContainer
    
    /// To store the implementations that were requested to inject as singletons.
    private var singletons: [String: AnyObject?] = [:]

    /// To get the current amount of stored implementations.
    var count: Int { implementations.count }
    
    /// The publisher that will send the new implementations to the subscribed injectors.
    let publisher = PassthroughSubject<ImplementationWrapper, InjectionErrors>()
    
    init(abstraction: String, currentKey: String, implementations: InitializersContainer) {
        self.abstractionName = abstraction
        self.currentKey = currentKey
        self.implementations = implementations
    }
    
    private init(abstraction: String, currentKey: String, implementations: InitializersContainer, singletonsContainer: [String: AnyObject?]) {
        self.abstractionName = abstraction
        self.currentKey = currentKey
        self.implementations = implementations
        self.singletons = singletonsContainer
    }
    
    /// To get an instance of specific implementation base on the stored current key.
    /// - Parameter injectionType: An enum that defines if the instance of the implementation will be a new instance or an already created and stored instance.
    /// - Returns: An instance of the specific implementation.
    func get(with injectionType: InjectionType) -> AnyObject? {
        let implementation = implementations[currentKey]?()
        
        if injectionType == .regular {
            return implementation
        }
        
        if let singletonImpl = singletons[currentKey] {
            return singletonImpl
        }
        
        singletons[currentKey] = implementation
        return implementation
    }

    /// To set the new key that will be used to identify the specific implementation obtained with the 'get' method.
    /// - Parameter newKey: A key to identify a specific implementation.
    func setCurrentKey(_ newKey: String) {
        guard currentKey != newKey else {
            Logger.log(.equalDependecyKeyOnUpdate(abstractionName, newKey))
            return
        }
        
        self.currentKey = newKey
        Logger.log("The key '\(newKey)' was saved successfully for the new injections of '\(abstractionName)'")
        publishImplementation()
    }
    
    /// To send a new implementation of the given abstraction to the subscribed injectors.
    /// - Parameter subscriberId: An id that allow us to define if the implementation to be send has to be listenned just for one subscriber.
    func publishImplementation(justFor subscriberId: String? = nil) {
        guard let implementation = get(with: .regular) else {
            Logger.log(.noImplementationFoundForPublish(abstractionName))
            return
        }
        
        let implementationSubject = ImplementationWrapper(subscriberId: subscriberId, value: implementation)
        publisher.send(implementationSubject)
        
        if let subscriberId {
            Logger.log("New implementation of '\(abstractionName)' was published succesfully to subscriber with id: \(subscriberId)")
        } else {
            Logger.log("New implementation of '\(abstractionName)' was published succesfully to all subscribers")
        }
    }
    
    /// To remove an already created an stored instance from the singletons dictionary.
    /// - Parameter key: A key to identify the the instance that will be removed.
    func removeSingleton(key: String?) {
        if let key {
            singletons.removeValue(forKey: key)
            Logger.log("All singletons instances with key '\(key)' removed successfully for implementations of '\(abstractionName)'")
            return
        }
        
        singletons.removeAll()
        Logger.log("All singletons instances removed successfully for implementations of '\(abstractionName)'")
    }
    
    
    /// To build a copy of the current instance by adding new values to its attributes.
    /// - Parameters:
    ///   - currentKey: The key to identify the default implementation to be injected. If is nil will use the already saved key.
    ///   - implementations: The implementations to add/replace into the already stored container.
    /// - Returns: A new instances of itself.
    func copyWith(currentKey: String? = nil, implementations: InitializersContainer) -> ImplementationsContainer {
        var newContainer = self.implementations
        implementations.forEach { newContainer[$0] = $1 }
        
        return ImplementationsContainer(
            abstraction: self.abstractionName,
            currentKey: currentKey ?? self.currentKey,
            implementations: newContainer,
            singletonsContainer: self.singletons
        )
    }
}
