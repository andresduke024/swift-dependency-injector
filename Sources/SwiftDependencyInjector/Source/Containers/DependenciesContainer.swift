//
//  DependenciesContainer.swift
//  
//
//  Created by Andres Duque on 5/07/23.
//

import Foundation

struct DependenciesContainer: Sendable {
    static let instance = DependenciesContainer()
    
    private init() {}
    
    private let managers = ConcurrencySafeStorage<ContextManagerProtocol>()
    
    static var global: ContextManagerProtocol {
        // TODO: Check this
        instance.managers.first!
    }

    static func add(_ key: String, _ manager: ContextManagerProtocol) {
        instance.managers.set(key: key, manager)
        Logger.log("New context manager set successfuly on DependenciesContainer with key: \(key)")
    }

    static func reset() {
        instance.managers.removeAll()
    }
}
