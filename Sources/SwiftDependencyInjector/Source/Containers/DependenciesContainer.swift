//
//  DependenciesContainer.swift
//  
//
//  Created by Andres Duque on 5/07/23.
//

import Foundation
import Combine

final class DependenciesContainer {
    static let defaultInstance: ContextManagerProtocol = ContextManager(targetValidator: TargetValidator())
    static private(set) var global: ContextManagerProtocol = defaultInstance

    static func setContextManager(_ manager: ContextManagerProtocol) {
        self.global = manager
        Logger.log("New context manager set successfuly on DependenciesContainer")
    }

    static func reset() {
        global = defaultInstance
    }
}
