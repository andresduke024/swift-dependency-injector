//
//  DependenciesManagerMock.swift
//
//
//  Created by Andres Duque on 16/07/23.
//

import Foundation
@testable import SwiftDependencyInjector

class DependenciesManagerMockProperties {
    var registerManyImplementationsWasCall: Bool = false
    var registerOneImplementationWasCall: Bool = false
    var addManyImplementationsWasCall: Bool = false
    var addOneImplementationWasCall: Bool = false
    var resetSingletonWasCall: Bool = false
    var getWasCall: Bool = false
    var removeWasCall: Bool = false
    var clearWasCall: Bool = false
}

class DependenciesManagerMock: @unchecked Sendable, DependenciesManagerProtocol {
    
    let properties: DependenciesManagerMockProperties = .init()
    
    func register<Abstraction: Sendable>(
        _ abstraction: Abstraction.Type,
        defaultDependency: String,
        implementations: [String: @Sendable () -> Abstraction?]
    ) {
        properties.registerManyImplementationsWasCall = true
    }
    
    func register<Abstraction: Sendable>(
        _ abstraction: Abstraction.Type,
        key: String,
        implementation initializer: @escaping () -> Abstraction?
    ) {
        properties.registerOneImplementationWasCall = true
    }
    
    func add<Abstraction: Sendable>(
        _ abstraction: Abstraction.Type,
        implementations: [String: @Sendable () -> Abstraction?]
    ) {
        properties.addManyImplementationsWasCall = true
    }
    
    func add<Abstraction: Sendable>(
        _ abstraction: Abstraction.Type,
        key: String,
        implementation initializer: @escaping () -> Abstraction?
    ) {
        properties.addOneImplementationWasCall = true
    }
    
    func resetSingleton<Abstraction: Sendable>(
        of abstraction: Abstraction.Type,
        key: String?
    ) {
        properties.resetSingletonWasCall = true
    }
    
    func get<Abstraction: Sendable>(
        with injectionType: InjectionType,
        key: String?
    ) -> Abstraction? {
        properties.getWasCall = true
        return nil
    }
    
    func remove<Abstraction: Sendable>(
        _ abstraction: Abstraction.Type
    ) {
        properties.removeWasCall = true
    }
    
    func clear() {
        properties.clearWasCall = true
    }
}
