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
        
        let newInstance = DependenciesManager()
        instance = newInstance
        return newInstance
    }
    
    private static var instance: DependenciesManagerProtocol?
    
    static func setManager(_ newManager: DependenciesManagerProtocol) {
        instance = newManager
    }
    
    private init() {}
}
