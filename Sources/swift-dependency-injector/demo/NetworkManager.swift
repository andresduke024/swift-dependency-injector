//
//  NetworkManager.swift
//  
//
//  Created by Andres Duque on 5/07/23.
//

import Foundation

protocol NetworkManager {
    func validateConnection()
}

class DummyNetworkManager: NetworkManager, InjectableDependency {
    required init() {}
    
    func validateConnection() {
        let isNetworkAvailable = Bool.random()
        
        let repositoryImplementation: RepositoryType = isNetworkAvailable ? .remote : .local
        Injector.global.updateDependencyKey(of: Repository.self, newKey: repositoryImplementation.rawValue)
    }
}
