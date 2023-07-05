//
//  ImplementationsContainer.swift
//  
//
//  Created by Andres Duque on 5/07/23.
//

import Foundation

class ImplementationsContainer {
    private var currentKey: String
    private var implementations: [String: () -> AnyObject?]
    private var singleton: [String: AnyObject?] = [:]
    
    init(currentKey: String, implementations: [String : () -> AnyObject?]) {
        self.currentKey = currentKey
        self.implementations = implementations
    }
    
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
    
    func setCurrentKey(_ newKey: String) {
        self.currentKey = newKey
    }
    
    func removeSingleton(key: String?) {
        if let key {
            singleton.removeValue(forKey: key)
            return
        }
        
        singleton.removeAll()
    }
}
