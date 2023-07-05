//
//  Logger.swift
//
//
//  Created by Andres Duque on 5/07/23.
//

import Foundation

public struct Injector {
    
    public static func register<Abstraction>(_ abstraction: Abstraction.Type, defaultDependency: String, implementations: [String: () -> AnyObject?]) {
        DependenciesContainer.shared.register(abstraction, defaultDependency: defaultDependency, implementations: implementations)
    }
    
    public static func register<Abstraction>(_ abstraction: Abstraction.Type, implementation: @escaping () -> AnyObject?) {
        DependenciesContainer.shared.register(abstraction, implementation: implementation)
    }
    
    public static func updateDependencyKey<Abstraction>(of abstraction: Abstraction.Type, newKey: String) {
        DependenciesContainer.shared.updateDependencyKey(of: abstraction, newKey: newKey)
    }
    
    public static func resetSingleton<Abstraction>(of abstraction: Abstraction.Type, key: String? = nil) {
        DependenciesContainer.shared.resetSingleton(of: abstraction, key: key)
    }
    
    public static func remove<Abstraction>(_ abstraction: Abstraction.Type) {
        DependenciesContainer.shared.remove(abstraction)
    }
    
    public static func clear() {
        DependenciesContainer.shared.clear()
    }
    
    public static func turnOffLogger() {
        Logger.informationLogsAreActive = false
    }
    
    public static func turnOnLogger() {
        Logger.informationLogsAreActive = true
    }
}
