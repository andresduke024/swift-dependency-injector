//
//  NetworkManagerMock.swift
//
//
//  Created by Andres Duque on 5/07/23.
//

import Foundation
@testable import swift_dependency_injector

class NetworkManagerMock: NetworkManager, InjectableDependency {
    required init() {}
    
    func validateConnection() {}
}
