//
//  File.swift
//  
//
//  Created by Andres Duque on 5/07/23.
//

import Foundation

class ApplicationSetup {
    static func start() {
        Injector.register(Repository.self, defaultDependency: RepositoryType.remote.rawValue, implementations: [
            RepositoryType.remote.rawValue : RemoteRepository.instance,
            RepositoryType.local.rawValue : LocalRepository.instance
        ])
        
        Injector.register(NetworkManager.self, implementation: DummyNetworkManager.instance)
        
        Injector.register(Service.self, implementation: DummyService.instance)
    }
}
