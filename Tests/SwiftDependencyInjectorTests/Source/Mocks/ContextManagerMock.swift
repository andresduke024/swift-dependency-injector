//
//  ContextManagerMock.swift
//  
//
//  Created by Andres Duque on 16/07/23.
//

import Foundation
@testable import SwiftDependencyInjector

class ContextManagerMockProperties {
    var validContext = InjectionContext.global
    var dependenciesManager = DependenciesManagerMock()
    var removeWassCall: Bool = false
}

class ContextManagerMock: @unchecked Sendable, ContextManagerProtocol {

    let properties = ContextManagerMockProperties()
    
    func get(_ context: InjectionContext) -> DependenciesManagerProtocol {
        properties.dependenciesManager
    }

    func register(_ context: InjectionContext) -> DependenciesManagerProtocol {
        properties.dependenciesManager
    }

    func remove(_ context: InjectionContext) {
        properties.removeWassCall = true
    }

    func transformToValidContext(_ context: InjectionContext, file: String) -> InjectionContext {
        properties.validContext
    }
}
