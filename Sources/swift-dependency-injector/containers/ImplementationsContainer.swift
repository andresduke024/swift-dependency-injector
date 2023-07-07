//
//  ImplementationsContainer.swift
//  
//
//  Created by Andres Duque on 5/07/23.
//

import Foundation

/// This class is used to store the a set of implementation of a given type and exposed the methods to access to them
class ImplementationsContainer {
    
    /// The key that identifies the implementation that is going to be injected in every injection attempt
    private var currentKey: String
    
    /// To store the builder of each implementation
    private let implementations: [String: () -> AnyObject?]
    
    /// To store the implementations that were requested to inject as singletons
    private var singleton: [String: AnyObject?] = [:]
    
    init(currentKey: String, implementations: [String : () -> AnyObject?]) {
        self.currentKey = currentKey
        self.implementations = implementations
    }
    
    /// To get an instance of specific implementation base on the stored current key
    /// - Parameter injectionType: An enum that defines if the instance of the implementation is going to be a new instance or an already created and stored instance
    func get(with injectionType: InjectionType) -> AnyObject? {
        let implementation = implementations[currentKey]?()
        
        if injectionType == .regular {
            return implementation
        }
        
        if let singletonImpl = singleton[currentKey] {
            return singletonImpl
        }
        
        singleton[currentKey] = implementation
        return implementation
    }
    
    /// To set the new key that is going to be used to identify the specific implementation obtained with the 'get' method
    /// - Parameter newKey: A key to identify a specific implementation
    func setCurrentKey(_ newKey: String) {
        self.currentKey = newKey
    }
    
    /// To remove an already created an stored instance from the singletons dictionary.
    /// - Parameter key: A key to identify the the instance that is going to be removed
    func removeSingleton(key: String?) {
        if let key {
            singleton.removeValue(forKey: key)
            return
        }
        
        singleton.removeAll()
    }
}
