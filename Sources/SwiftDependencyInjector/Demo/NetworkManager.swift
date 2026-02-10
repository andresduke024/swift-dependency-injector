//
//  NetworkManager.swift
//  
//
//  Created by Andres Duque on 5/07/23.
//

import Foundation
import SwiftDependencyInjectorMacros

protocol NetworkManager: Sendable {
    func validateConnection() async
}

@InjectableDependency(of: NetworkManager.self)
actor DummyNetworkManager: NetworkManager  {
    func validateConnection() async {}
}
