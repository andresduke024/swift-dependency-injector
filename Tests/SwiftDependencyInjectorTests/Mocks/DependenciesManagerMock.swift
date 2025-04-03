//
//  File.swift
//  
//
//  Created by Andres Duque on 16/07/23.
//

import Foundation
@testable import SwiftDependencyInjector

class DependenciesManagerMock: DependenciesManagerProtocol {

    var registerManyImplementationsWasCall: Bool = false
    var registerOneImplementationWasCall: Bool = false
    var addManyImplementationsWasCall: Bool = false
    var addOneImplementationWasCall: Bool = false
    var resetSingletonWasCall: Bool = false
    var getWasCall: Bool = false
    var removeWasCall: Bool = false
    var clearWasCall: Bool = false

    func register<Abstraction: Sendable>(_ abstraction: Abstraction.Type, defaultDependency: String, implementations: [String: () -> Abstraction?]) {
        registerManyImplementationsWasCall = true
    }

    func register<Abstraction: Sendable>(_ abstraction: Abstraction.Type, key: String, implementation initializer: @escaping () -> Abstraction?) {
        registerOneImplementationWasCall = true
    }

    func add<Abstraction: Sendable>(_ abstraction: Abstraction.Type, implementations: [String: () -> Abstraction?]) {
        addManyImplementationsWasCall = true
    }

    func add<Abstraction: Sendable>(_ abstraction: Abstraction.Type, key: String, implementation initializer: @escaping () -> Abstraction?) {
        addOneImplementationWasCall = true
    }

    func resetSingleton<Abstraction: Sendable>(of abstraction: Abstraction.Type, key: String?) {
        resetSingletonWasCall = true
    }

    func get<Abstraction: Sendable>(with injectionType: InjectionType, key: String?) -> Abstraction? {
        getWasCall = true
        return nil
    }

    func remove<Abstraction: Sendable>(_ abstraction: Abstraction.Type) {
        removeWasCall = true
    }

    func clear() {
        clearWasCall = true
    }
}
