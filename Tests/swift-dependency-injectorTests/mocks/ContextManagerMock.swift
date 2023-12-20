//
//  ContextManagerMock.swift
//  
//
//  Created by Andres Duque on 16/07/23.
//

import Foundation
@testable import swift_dependency_injector

class ContextManagerMock: ContextManagerProtocol {

    var validContext = InjectionContext.global
    var dependenciesManager = DependenciesManagerMock()

    var removeWassCall: Bool = false

    func get(_ context: InjectionContext) -> DependenciesManagerProtocol {
        dependenciesManager
    }

    func register(_ context: InjectionContext) -> DependenciesManagerProtocol {
        dependenciesManager
    }

    func remove(_ context: InjectionContext) {
        removeWassCall = true
    }

    func transformToValidContext(_ context: InjectionContext, file: String) -> InjectionContext {
        validContext
    }
}
