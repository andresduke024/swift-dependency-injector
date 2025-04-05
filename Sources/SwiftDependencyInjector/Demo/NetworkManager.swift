//
//  NetworkManager.swift
//  
//
//  Created by Andres Duque on 5/07/23.
//

import Foundation

protocol NetworkManager: Sendable {
    func validateConnection() async
}

actor DummyNetworkManager: NetworkManager  {
    func validateConnection() async {}
}
