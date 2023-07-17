//
//  File.swift
//  
//
//  Created by Andres Duque on 5/07/23.
//

import Foundation

class ApplicationSetup {
    static func start() {
        Injector.global.register(Repository.self, defaultDependency: RepositoryType.remote.rawValue, implementations: [
            RepositoryType.remote.rawValue : RemoteRepository.instance,
            RepositoryType.local.rawValue : LocalRepository.instance
        ])
        
        Injector.global.register(NetworkManager.self, implementation: DummyNetworkManager.instance)
        
        Injector.global.register(Service.self, implementation: DummyService.instance)
    }
}
