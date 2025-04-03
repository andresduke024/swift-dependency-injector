//
//  DependenciesContainer.swift
//  
//
//  Created by Andres Duque on 5/07/23.
//

import Foundation

struct DependenciesContainer: Sendable {
    private init() {
        managers = ConcurrencySafeStorage(
            initialValues: [ "" : ContextManager() ]
        )
    }
    
    private let managers: ConcurrencySafeStorage<ContextManagerProtocol>
    
    static let instance = DependenciesContainer()
    
    static var global: ContextManagerProtocol {
        guard let context = instance.managers.first else {
            fatalError("Invalid global context for dependencies container.")
        }
        
        return context
    }

    static func add(_ key: String, _ manager: ContextManagerProtocol) {
        instance.managers.set(key: key, manager)
        Logger.log("New context manager set successfuly on DependenciesContainer with key: \(key)")
    }

    static func reset() {
        instance.managers.removeAll()
    }
}
