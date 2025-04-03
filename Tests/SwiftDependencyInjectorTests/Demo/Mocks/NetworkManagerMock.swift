//
//  NetworkManagerMock.swift
//
//
//  Created by Andres Duque on 5/07/23.
//

import Foundation
@testable import SwiftDependencyInjector

struct NetworkManagerMock: NetworkManager {
    func validateConnection() {}
}
