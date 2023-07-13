//
//  ImplementationsContainer.swift
//  
//
//  Created by Andres Duque on 5/07/23.
//

import Foundation
import Combine

typealias InitializersContainer = [String: () -> AnyObject?]

/// This class is used to store the a set of implementation of a given type and exposed the methods to access to them
final class ImplementationsContainer {
    
    /// The key that identifies the implementation that is going to be injected in every injection attempt
    private var currentKey: String
    
    /// To store the builder of each implementation
    private let implementations: InitializersContainer
    
    /// To store the implementations that were requested to inject as singletons
    private var singletons: [String: AnyObject?] = [:]

    /// To get the current amount of stored implementations
    var count: Int { implementations.count }
    
    internal let publisher = PassthroughSubject<ImplementationWrapper, InjectionErrors>()
    
    init(currentKey: String, implementations: InitializersContainer) {
        self.currentKey = currentKey
        self.implementations = implementations
        publishImplementation()
    }
    
    private init(currentKey: String, implementations: InitializersContainer, singletonsContainer: [String: AnyObject?]) {
        self.currentKey = currentKey
        self.implementations = implementations
        self.singletons = singletonsContainer
        publishImplementation()
    }
    
    
    /// To get an instance of specific implementation base on the stored current key.
    /// - Parameter injectionType: An enum that defines if the instance of the implementation is going to be a new instance or an already created and stored instance.
    /// - Returns: An instance of the specific implementation
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

    /// To set the new key that is going to be used to identify the specific implementation obtained with the 'get' method
    /// - Parameter newKey: A key to identify a specific implementation
    func setCurrentKey(_ newKey: String) {
        self.currentKey = newKey
        publishImplementation()
    }
    
    func publishImplementation(_ observerId: UUID? = nil) {
        guard let implementation = get(with: .regular) else {
            // TODO: Publish an error and log
            return
        }
        
        let implementationSubject = ImplementationWrapper(observerId: observerId, value: implementation)
        publisher.send(implementationSubject)
    }
    
    /// To remove an already created an stored instance from the singletons dictionary.
    /// - Parameter key: A key to identify the the instance that is going to be removed
    func removeSingleton(key: String?) {
        if let key {
            singletons.removeValue(forKey: key)
            return
        }
        
        singletons.removeAll()
    }
    
    
    /// To build a copy of the current instance by adding new values to its attributes.
    /// - Parameters:
    ///   - currentKey: The key to identify the default implementation to be injected. If is nil is going to use the already saved key.
    ///   - implementations: The implementations to add/replace into the already stored container.
    /// - Returns: A new instances of itself.
    func copyWith(currentKey: String? = nil, implementations: InitializersContainer) -> ImplementationsContainer {
        var newContainer = self.implementations
        implementations.forEach { newContainer[$0] = $1 }
        
        return ImplementationsContainer(
            currentKey: currentKey ?? self.currentKey,
            implementations: newContainer,
            singletonsContainer: self.singletons
        )
    }
}
