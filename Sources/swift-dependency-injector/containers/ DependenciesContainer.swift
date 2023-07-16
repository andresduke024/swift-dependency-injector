//
//  DependenciesContainer.swift
//  
//
//  Created by Andres Duque on 5/07/23.
//

import Foundation
import Combine

final class DependenciesContainer {
    
    /// A singleton instance of the class.
    static var shared: DependenciesManagerProtocol {
        if let instance {
            return instance
        }
        
        let newInstance = DependenciesManager(targetValidator: TargetValidator())
        instance = newInstance
        return newInstance
    }
    
    /// To store the current implementation of the manager
    private static var instance: DependenciesManagerProtocol?
    
    
    /// To change the current implementation of the manager
    /// - Parameter newManager: A new class that implements DependenciesManagerProtocol
    static func setManager(_ newManager: DependenciesManagerProtocol) {
        instance = newManager
    }
    
    private init() {}
}
