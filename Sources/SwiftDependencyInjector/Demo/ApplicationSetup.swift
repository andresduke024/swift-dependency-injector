//
//  File.swift
//  
//
//  Created by Andres Duque on 5/07/23.
//

import Foundation
import SwiftDependencyInjectorMacros

@DependenciesInjector(
    // Repositories
    LocalRepository.self,
    RemoteRepository.self,
    
    // DataSources
    DummyNetworkManager.self,
    
    // Services
    DummyService.self
)
struct ApplicationSetup {
    static let shared = ApplicationSetup()
    
    private init() {}
}
