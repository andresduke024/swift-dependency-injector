//
//  File.swift
//  
//
//  Created by Andres Duque on 16/07/23.
//

import Foundation
import Combine
@testable import SwiftDependencyInjector

class DependenciesManagerMock: DependenciesManagerProtocol {

    var publisher = PassthroughSubject<ImplementationWrapper, InjectionErrors>()

    var registerManyImplementationsWasCall: Bool = false
    var registerOneImplementationWasCall: Bool = false
    var addManyImplementationsWasCall: Bool = false
    var addOneImplementationWasCall: Bool = false
    var updateDependencyKeyWasCall: Bool = false
    var resetSingletonWasCall: Bool = false
    var getWasCall: Bool = false
    var getPublisherWasCall: Bool = false
    var requestPublisherUpdateWasCall: Bool = false
    var removeWasCall: Bool = false
    var clearWasCall: Bool = false
    var getCurrentKeyWasCall: Bool = false

    func register<Abstraction>(_ abstraction: Abstraction.Type, defaultDependency: String, implementations: [String: () -> Abstraction?]) {
        registerManyImplementationsWasCall = true
    }

    func register<Abstraction>(_ abstraction: Abstraction.Type, key: String, implementation initializer: @escaping () -> Abstraction?) {
        registerOneImplementationWasCall = true
    }

    func add<Abstraction>(_ abstraction: Abstraction.Type, implementations: [String: () -> Abstraction?]) {
        addManyImplementationsWasCall = true
    }

    func add<Abstraction>(_ abstraction: Abstraction.Type, key: String, implementation initializer: @escaping () -> Abstraction?) {
        addOneImplementationWasCall = true
    }

    func updateDependencyKey<Abstraction>(of abstraction: Abstraction.Type, newKey: String) {
        updateDependencyKeyWasCall = true
    }

    func resetSingleton<Abstraction>(of abstraction: Abstraction.Type, key: String?) {
        resetSingletonWasCall = true
    }

    func get<Abstraction>(with injectionType: InjectionType, key: String?) -> Abstraction? {
        getWasCall = true
        return nil
    }

    func getPublisher<Abstraction>(of abstraction: Abstraction.Type) -> AnyPublisher<ImplementationWrapper, InjectionErrors>? {
        getPublisherWasCall = true
        return publisher.eraseToAnyPublisher()
    }

    func requestPublisherUpdate<Abstraction>(of abstraction: Abstraction.Type, subscriber: String?) {
        requestPublisherUpdateWasCall = true
    }

    func remove<Abstraction>(_ abstraction: Abstraction.Type) {
        removeWasCall = true
    }

    func clear() {
        clearWasCall = true
    }

    func getCurrentKey<Abstraction>(of abstraction: Abstraction.Type) -> String? {
        getCurrentKeyWasCall = true
        return "mock"
    }
}
