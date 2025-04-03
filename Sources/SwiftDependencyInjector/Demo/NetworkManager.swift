//
//  NetworkManager.swift
//  
//
//  Created by Andres Duque on 5/07/23.
//

import Foundation

protocol NetworkManager: InjectableDependency {
    func validateConnection()
}

final class DummyNetworkManager: NetworkManager  {
    required init() {}

    func validateConnection() {}
}
