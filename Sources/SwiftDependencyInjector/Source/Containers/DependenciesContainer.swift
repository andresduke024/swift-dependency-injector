//
//  DependenciesContainer.swift
//  
//
//  Created by Andres Duque on 5/07/23.
//

import Foundation

final class DependenciesContainer: Sendable {
    private struct GlobalContextManagerBuilder {
        let key: String = InjectionContext.global.description
        
        var manager: ContextManagerProtocol { ContextManager() }
    }
    
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

    static func reset(registerGlobalContextManager: Bool = true) {
        instance.managers.removeAll()
        
        guard registerGlobalContextManager else { return }
        
        instance.addGlobalContextManager()
    }
    
    private init() { addGlobalContextManager() }
    
    private let managers = ConcurrencySafeStorage<ContextManagerProtocol>()
    
    private func addGlobalContextManager() {
        let builder = GlobalContextManagerBuilder()
        
        managers.set(key: builder.key, builder.manager)
    }
}
