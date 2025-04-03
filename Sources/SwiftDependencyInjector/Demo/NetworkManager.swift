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

    func validateConnection() {}
}
