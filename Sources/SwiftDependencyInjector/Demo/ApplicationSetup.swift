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
            RepositoryType.remote.rawValue: { RemoteRepository() },
            RepositoryType.local.rawValue: { LocalRepository() }
        ])

        Injector.global.register(NetworkManager.self, implementation: { DummyNetworkManager() })

        Injector.global.register(Service.self, implementation: { DummyService() })
    }
}
